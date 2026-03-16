<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

class ContentController extends Controller
{
    public function aboutApp(): JsonResponse
    {
        return response()->json([
            'data' => [
                'slug' => 'about-app',
                'title' => 'عن التطبيق',
                'body' => 'منصة تساعد الطلبة على الوصول إلى فرص التدريب الميداني، متابعة الطلبات، التواصل مع المشرفين، ورفع التقارير الأكاديمية بسهولة.',
            ],
        ]);
    }

    public function terms(): JsonResponse
    {
        return response()->json([
            'data' => [
                'slug' => 'terms',
                'title' => 'الشروط والأحكام',
                'body' => 'الشروط والأحكام الخاصة باستخدام تطبيق Waslaa.',
            ],
        ]);
    }

    public function privacy(): JsonResponse
    {
        return response()->json([
            'data' => [
                'slug' => 'privacy',
                'title' => 'سياسة الخصوصية',
                'body' => 'سياسة الخصوصية الخاصة بتطبيق Waslaa.',
            ],
        ]);
    }

    public function aboutUs(): JsonResponse
    {
        return response()->json([
            'data' => [
                'slug' => 'about-us',
                'title' => 'من نحن',
                'body' => 'فريق Waslaa يعمل على ربط الطالب بفرص التدريب الميداني.',
            ],
        ]);
    }
}
