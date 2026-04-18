<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Services\PublicMediaUrl;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RegisteredCompanyController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Company::where('status', 'approved')
            ->withCount('internships');

        if ($search = $request->input('search')) {
            $query->where('name', 'like', "%{$search}%");
        }

        if ($specialization = $request->input('specialization')) {
            $query->whereHas('opportunities.specialization', function ($q) use ($specialization) {
                $q->where('name', 'like', "%{$specialization}%");
            });
        }

        $companies = $query->latest()->get();

        $data = $companies->map(function ($company) {
            return [
                'id' => $company->id,
                'name' => $company->name,
                'city' => $company->city,
                'address' => $company->address,
                'email' => $company->email,
                'phone' => $company->phone,
                'logo_url' => PublicMediaUrl::forPath($company->logo_path),
                'website_url' => $company->website_url,
                'description' => $company->description,
                'internships_count' => $company->internships_count,
                'is_active' => $company->is_active,
            ];
        });

        return response()->json([
            'data' => $data,
        ]);
    }

    public function show(Company $company): JsonResponse
    {
        $company->load([
            'opportunities.specialization',
            'supervisors',
        ]);

        $activeInternships = $company->internships()
            ->with(['student.studentProfile.specialization'])
            ->where('status', 'active')
            ->get();

        return response()->json([
            'data' => [
                'id' => $company->id,
                'name' => $company->name,
                'city' => $company->city,
                'address' => $company->address,
                'email' => $company->email,
                'phone' => $company->phone,
                'logo_url' => PublicMediaUrl::forPath($company->logo_path),
                'website_url' => $company->website_url,
                'description' => $company->description,
                'is_active' => $company->is_active,
                'status' => $company->status,
                'opportunities' => $company->opportunities->map(fn($o) => [
                    'id' => $o->id,
                    'title' => $o->title,
                    'specialization' => $o->specialization?->name,
                    'seats_count' => $o->seats_count,
                    'status' => $o->status,
                    'start_date' => $o->start_date?->toDateString(),
                    'end_date' => $o->end_date?->toDateString(),
                ]),
                'students' => $activeInternships->map(fn($i) => [
                    'id' => $i->student_id,
                    'name' => $i->student?->name,
                    'student_number' => $i->student?->studentProfile?->student_number,
                    'specialization' => $i->student?->studentProfile?->specialization?->name,
                    'start_date' => $i->start_date?->toDateString(),
                    'status' => $i->status,
                ]),
                'supervisors' => $company->supervisors->map(fn($s) => [
                    'id' => $s->id,
                    'name' => $s->name,
                    'email' => $s->email,
                    'phone' => $s->phone,
                    'department' => $s->department,
                    'is_active' => $s->is_active,
                ]),
            ],
        ]);
    }
}
