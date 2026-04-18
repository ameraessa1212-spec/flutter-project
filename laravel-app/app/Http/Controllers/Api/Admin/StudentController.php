<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\Admin\AdminStudentResource;
use App\Models\EligibleStudent;
use App\Models\StudentProfile;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class StudentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = User::where('role', 'student')
            ->with('studentProfile.specialization');

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('username', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%")
                    ->orWhereHas('studentProfile', function ($q) use ($search) {
                        $q->where('student_number', 'like', "%{$search}%");
                    });
            });
        }

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        if ($specialization = $request->input('specialization_id')) {
            $query->whereHas('studentProfile', function ($q) use ($specialization) {
                $q->where('specialization_id', $specialization);
            });
        }

        $students = $query->latest()->paginate($request->input('per_page', 20));

        return response()->json([
            'data' => AdminStudentResource::collection($students),
            'meta' => [
                'current_page' => $students->currentPage(),
                'last_page' => $students->lastPage(),
                'total' => $students->total(),
            ],
        ]);
    }

    public function show(User $user): JsonResponse
    {
        $user->load('studentProfile.specialization');

        return response()->json([
            'data' => AdminStudentResource::make($user),
        ]);
    }

    public function update(Request $request, User $user): JsonResponse
    {
        $validated = $request->validate([
            'first_name' => ['sometimes', 'string', 'max:255'],
            'last_name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'email', 'unique:users,email,' . $user->id],
            'phone' => ['sometimes', 'string', 'max:20'],
            'status' => ['sometimes', 'string', 'in:active,inactive,pending'],
        ]);

        if (isset($validated['first_name']) || isset($validated['last_name'])) {
            $validated['name'] = trim(($validated['first_name'] ?? $user->first_name) . ' ' . ($validated['last_name'] ?? $user->last_name));
        }

        $user->update($validated);

        return response()->json([
            'message' => 'تم تحديث بيانات الطالب بنجاح.',
            'data' => AdminStudentResource::make($user->fresh('studentProfile.specialization')),
        ]);
    }

    public function updatePassword(Request $request, User $user): JsonResponse
    {
        $request->validate([
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $user->update(['password' => $request->password]);

        return response()->json([
            'message' => 'تم تغيير كلمة المرور بنجاح.',
        ]);
    }

    public function toggleStatus(User $user): JsonResponse
    {
        $newStatus = $user->status === 'active' ? 'inactive' : 'active';
        $user->update(['status' => $newStatus]);

        return response()->json([
            'message' => $newStatus === 'active' ? 'تم تفعيل الحساب.' : 'تم إيقاف الحساب.',
            'data' => ['status' => $newStatus],
        ]);
    }

    public function destroy(User $user): JsonResponse
    {
        $user->tokens()->delete();
        $user->delete();

        return response()->json([
            'message' => 'تم حذف حساب الطالب.',
        ]);
    }

    public function upload(Request $request): JsonResponse
    {
        $request->validate([
            'students' => ['required', 'array', 'min:1'],
            'students.*.student_number' => ['required', 'string'],
            'students.*.name' => ['required', 'string'],
        ]);

        $rows = $request->input('students');

        $created = 0;
        $skipped = 0;

        foreach ($rows as $row) {

            $row['student_number'] = preg_replace('/\D/', '', $row['student_number']);

            $exists = User::whereHas('studentProfile', function ($q) use ($row) {
                $q->where('student_number', $row['student_number']);
            })->exists();

            if ($exists) {
                $skipped++;
                continue;
            }


            EligibleStudent::firstOrCreate(
                ['student_number' => $row['student_number']],
                ['name' => $row['name']]
            );


            $created++;
        }

        return response()->json([
            'message' => "تم رفع الملف بنجاح. تم إنشاء {$created} حساب، وتم تخطي {$skipped}.",
            'data' => [
                'created' => $created,
                'skipped' => $skipped,
                'total' => count($rows),
            ],
        ]);
    }
}
