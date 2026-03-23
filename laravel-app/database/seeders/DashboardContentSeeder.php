<?php

namespace Database\Seeders;

use App\Models\DashboardContent;
use Illuminate\Database\Seeder;

class DashboardContentSeeder extends Seeder
{
    public function run(): void
    {
        $items = [
            [
                'type' => 'slider',
                'title' => 'اكتشف فرص التدريب الجديدة',
                'subtitle' => 'تابع أحدث الفرص المتاحة في الشركات المحلية حسب تخصصك.',
                'image_asset' => 'assets/images/madar.JPG',
                'sort_order' => 10,
            ],
            [
                'type' => 'slider',
                'title' => 'استعد لتجربتك الميدانية',
                'subtitle' => 'جهز سيرتك الذاتية وابدأ التقديم على الفرص المناسبة لك.',
                'image_asset' => 'assets/images/libyana.JPG',
                'sort_order' => 20,
            ],
            [
                'type' => 'tip',
                'title' => 'جهز سيرتك الذاتية',
                'subtitle' => 'احرص على تحديث الـ CV قبل التقديم على أي فرصة تدريب.',
                'icon_key' => 'article',
                'sort_order' => 10,
            ],
            [
                'type' => 'tip',
                'title' => 'تابع حالة طلبك',
                'subtitle' => 'تحقق باستمرار من الطلبات المرسلة وحالة القبول أو الرفض.',
                'icon_key' => 'track_changes',
                'sort_order' => 20,
            ],
            [
                'type' => 'tip',
                'title' => 'التزم بمواعيد التقرير',
                'subtitle' => 'رفع التقرير في الوقت المحدد يساعدك على إنهاء التدريب بنجاح.',
                'icon_key' => 'schedule',
                'sort_order' => 30,
            ],
            [
                'type' => 'announcement',
                'title' => 'تنبيه مهم',
                'subtitle' => 'الفرص الأكثر طلباً يتم إغلاقها بسرعة، لذلك تابع الصفحة الرئيسية بشكل يومي.',
                'badge' => 'جديد',
                'icon_key' => 'campaign',
                'sort_order' => 10,
            ],
            [
                'type' => 'announcement',
                'title' => 'تحديثات التدريب',
                'subtitle' => 'يمكنك الآن متابعة التدريب الحالي، التقارير، والمحادثة مع المشرف من مكان واحد.',
                'badge' => 'مهم',
                'icon_key' => 'notifications',
                'sort_order' => 20,
            ],
        ];

        foreach ($items as $item) {
            DashboardContent::query()->updateOrCreate(
                [
                    'type' => $item['type'],
                    'title' => $item['title'],
                ],
                [
                    'subtitle' => $item['subtitle'] ?? null,
                    'image_asset' => $item['image_asset'] ?? null,
                    'icon_key' => $item['icon_key'] ?? null,
                    'badge' => $item['badge'] ?? null,
                    'sort_order' => $item['sort_order'],
                    'is_active' => true,
                ],
            );
        }
    }
}