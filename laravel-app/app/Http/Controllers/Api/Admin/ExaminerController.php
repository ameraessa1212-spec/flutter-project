<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Mail\ExaminerCredentialsMail;
use App\Models\DiscussionEvaluation;
use App\Models\ExaminerDiscussion;
use App\Models\Report;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ExaminerController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = User::where('role', 'examiner');

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%");
            });
        }

        $examiners = $query->latest()->get()->map(function ($examiner) {
            return [
                'id' => $examiner->id,
                'name' => $examiner->name,
                'email' => $examiner->email,
                'phone' => $examiner->phone,
                'status' => $examiner->status,
                'assigned_students' => ExaminerDiscussion::where('examiner_id', $examiner->id)->count(),
                'pending_evaluations' => ExaminerDiscussion::where('examiner_id', $examiner->id)
                    ->whereDoesntHave('evaluation')
                    ->count(),
            ];
        });

        return response()->json(['data' => $examiners]);
    }

    public function toggleStatus(User $user): JsonResponse
    {
        $newStatus = $user->status === 'active' ? 'inactive' : 'active';
        $user->update(['status' => $newStatus]);

        return response()->json([
            'message' => $newStatus === 'active' ? 'تم تفعيل الحساب.' : 'تم تعطيل الحساب.',
            'data' => ['status' => $newStatus],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:20', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:6'],
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'] ?? null,
            'password' => Hash::make($validated['password']),
            'role' => 'examiner',
            'status' => 'active',
        ]);

        // Send credentials email to the new examiner
        Mail::to($user->email)->send(new ExaminerCredentialsMail(
            examinerName: $user->name,
            email: $user->email,
            password: $validated['password'],
        ));

        return response()->json([
            'message' => 'تم إنشاء حساب الممتحن بنجاح.',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'status' => $user->status,
            ],
        ], 201);
    }

    public function update(Request $request, User $user): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'email', Rule::unique('users')->ignore($user->id)],
            'phone' => ['nullable', 'string', 'max:20', Rule::unique('users')->ignore($user->id)],
            'password' => ['nullable', 'string', 'min:6'],
        ]);

        $updateData = collect($validated)->except('password')->filter()->all();
        if (!empty($validated['password'])) {
            $updateData['password'] = Hash::make($validated['password']);
        }

        $user->update($updateData);

        return response()->json([
            'message' => 'تم تحديث بيانات الممتحن.',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'status' => $user->status,
            ],
        ]);
    }

    public function destroy(User $user): JsonResponse
    {
        $activeDiscussions = ExaminerDiscussion::where('examiner_id', $user->id)
            ->whereDoesntHave('evaluation')
            ->count();

        if ($activeDiscussions > 0) {
            return response()->json([
                'message' => "لا يمكن حذف الممتحن لديه {$activeDiscussions} تقييم معلق.",
            ], 422);
        }

        $user->update(['status' => 'inactive']);

        return response()->json(['message' => 'تم تعطيل حساب الممتحن.']);
    }

    public function reports(Request $request, User $examiner): JsonResponse
    {
        $query = ExaminerDiscussion::where('examiner_id', $examiner->id)
            ->whereHas('internship', fn($q) => $q->where('status', 'active'));

        if ($search = $request->input('search')) {
            $query->whereHas('student', fn($q) => $q->where('name', 'like', "%{$search}%"));
        }

        $discussions = $query->with(['internship.reports.student', 'student'])->get();

        $reports = $discussions->flatMap(function ($discussion) {
            return $discussion->internship?->reports?->map(function ($report) use ($discussion) {
                return [
                    'id' => $report->id,
                    'student_name' => $discussion->student?->name ?? $report->student?->name,
                    'student_number' => $report->student?->studentProfile?->student_number,
                    'report_type' => $report->report_type,
                    'title' => $report->title,
                    'submitted_at' => $report->submitted_at?->toDateString(),
                    'download_url' => $report->file_path ? Storage::disk('public')->url($report->file_path) : null,
                ];
            }) ?? collect();
        });

        return response()->json(['data' => $reports->values()]);
    }

    public function students(Request $request): JsonResponse
    {
        $examinerId = $request->user()->id;

        $query = ExaminerDiscussion::where('examiner_id', $examinerId);

        if ($search = $request->input('search')) {
            $query->whereHas('student', fn($q) => $q->where('name', 'like', "%{$search}%"));
        }

        $discussions = $query->with(['student.studentProfile', 'evaluation'])->get();

        $data = $discussions->map(function ($discussion) {
            $hasEvaluation = $discussion->evaluation !== null;

            return [
                'id' => $discussion->id,
                'student_id' => $discussion->student_id,
                'student_name' => $discussion->student?->name,
                'student_number' => $discussion->student?->studentProfile?->student_number,
                'status' => $hasEvaluation
                    ? "تم التقييم ({$discussion->evaluation->total_score}/70)"
                    : 'لم يتم التقييم',
                'has_evaluation' => $hasEvaluation,
                'total_score' => $discussion->evaluation?->total_score,
            ];
        });

        return response()->json(['data' => $data]);
    }

    public function storeGrade(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'examiner_discussion_id' => ['required', 'exists:examiner_discussions,id'],
            'rubric_scores' => ['required', 'array'],
            'rubric_scores.*' => ['required', 'numeric', 'min:0', 'max:5'],
            'total_score' => ['required', 'numeric', 'min:0', 'max:70'],
            'decision' => ['required', 'string', 'in:pass,fail,conditional_pass'],
            'notes' => ['nullable', 'string'],
        ]);

        $discussion = ExaminerDiscussion::findOrFail($validated['examiner_discussion_id']);

        $evaluation = DiscussionEvaluation::updateOrCreate(
            ['examiner_discussion_id' => $discussion->id],
            [
                'internship_id' => $discussion->internship_id,
                'student_id' => $discussion->student_id,
                'examiner_id' => $request->user()->id,
                'rubric_scores' => $validated['rubric_scores'],
                'total_score' => $validated['total_score'],
                'decision' => $validated['decision'],
                'notes' => $validated['notes'] ?? null,
                'submitted_at' => now(),
                'visible_to_supervisor' => true,
                'visible_to_company' => true,
                'visible_to_student' => true,
            ]
        );

        return response()->json([
            'message' => "تم حفظ التقييم بنجاح: {$validated['total_score']}/70",
            'data' => $evaluation,
        ]);
    }
}
