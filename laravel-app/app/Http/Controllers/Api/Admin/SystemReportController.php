<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\ExaminerDiscussion;
use App\Models\Internship;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SystemReportController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $type = $request->input('reportType', 'students');
        $dept = $request->input('dept', 'all');

        return match ($type) {
            'students' => $this->studentsReport($dept),
            'companies' => $this->companiesReport(),
            'examiners' => $this->examinersReport($dept),
            default => response()->json(['data' => []]),
        };
    }

    private function studentsReport(string $dept): JsonResponse
    {
        $query = Internship::with([
            'student.studentProfile.specialization',
            'company',
        ]);

        if ($dept !== 'all') {
            $query->whereHas('student.studentProfile.specialization', function ($q) use ($dept) {
                $q->where('name', 'like', "%{$dept}%");
            });
        }

        $data = $query->get()->map(function ($internship) {
            return [
                'student_number' => $internship->student?->studentProfile?->student_number,
                'student_name' => $internship->student?->name,
                'specialization' => $internship->student?->studentProfile?->specialization?->name,
                'company' => $internship->company?->name,
                'status' => $internship->status === 'active' ? 'نشط' : $internship->status,
            ];
        });

        return response()->json([
            'data' => $data,
            'columns' => ['رقم القيد', 'اسم الطالب', 'التخصص', 'جهة التدريب', 'الحالة'],
        ]);
    }

    private function companiesReport(): JsonResponse
    {
        $data = Company::where('is_active', true)
            ->withCount(['internships', 'opportunities'])
            ->get()
            ->map(function ($company) {
                return [
                    'name' => $company->name,
                    'internships_count' => $company->internships_count . ' طالب',
                    'opportunities_count' => $company->opportunities_count,
                    'status' => $company->is_active ? 'نشط' : 'غير نشط',
                ];
            });

        return response()->json([
            'data' => $data,
            'columns' => ['اسم الشركة', 'عدد الطلاب', 'السعة', 'الحالة'],
        ]);
    }

    private function examinersReport(string $dept): JsonResponse
    {
        $query = User::where('role', 'examiner')
            ->where('status', 'active');

        $examiners = $query->get()->map(function ($examiner) {
            $count = ExaminerDiscussion::where('examiner_id', $examiner->id)->count();

            return [
                'name' => $examiner->name,
                'students_count' => $count . ' طالب',
            ];
        });

        return response()->json([
            'data' => $examiners,
            'columns' => ['اسم الممتحن', 'عدد الطلاب'],
        ]);
    }
}
