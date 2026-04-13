<?php

namespace Database\Seeders;

use App\Models\Application;
use App\Models\ChatThread;
use App\Models\Company;
use App\Models\DiscussionEvaluation;
use App\Models\ExaminerDiscussion;
use App\Models\Internship;
use App\Models\InternshipOpportunity;
use App\Models\Message;
use App\Models\Report;
use App\Models\StudentProfile;
use App\Models\Supervisor;
use App\Models\User;
use App\Models\UserNotification;
use App\Models\UserSetting;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DataSeeder extends Seeder
{
    public function run(): void
    {
        $now = Carbon::now();
        $password = Hash::make('Password@123');

        // ════════════════════════════════════════════════════════════════
        //  1. ADMIN / OPERATIONS / CONTENT MANAGER USERS
        // ════════════════════════════════════════════════════════════════

        $operationsAdmin = User::query()->firstOrCreate(
            ['email' => 'operations@waslaa.local'],
            [
                'first_name' => 'أحمد',
                'last_name' => 'الطرابلسي',
                'name' => 'أحمد الطرابلسي',
                'username' => 'ahmed_ops',
                'phone' => '0911000001',
                'password' => $password,
                'role' => 'operations',
                'status' => 'active',
                'email_verified_at' => $now,
                'phone_verified_at' => $now,
            ]
        );
        $operationsAdmin->assignRole('operations');

        $contentManager = User::query()->firstOrCreate(
            ['email' => 'content@waslaa.local'],
            [
                'first_name' => 'سارة',
                'last_name' => 'المصراتي',
                'name' => 'سارة المصراتي',
                'username' => 'sara_content',
                'phone' => '0911000002',
                'password' => $password,
                'role' => 'content_manager',
                'status' => 'active',
                'email_verified_at' => $now,
                'phone_verified_at' => $now,
            ]
        );
        $contentManager->assignRole('content_manager');

        $supportUser = User::query()->firstOrCreate(
            ['email' => 'support@waslaa.local'],
            [
                'first_name' => 'خالد',
                'last_name' => 'الزنتاني',
                'name' => 'خالد الزنتاني',
                'username' => 'khaled_support',
                'phone' => '0911000003',
                'password' => $password,
                'role' => 'support',
                'status' => 'active',
                'email_verified_at' => $now,
                'phone_verified_at' => $now,
            ]
        );
        $supportUser->assignRole('support');

        // ════════════════════════════════════════════════════════════════
        //  2. EXAMINER USERS
        // ════════════════════════════════════════════════════════════════

        $examinersData = [
            [
                'first_name' => 'عبدالرحمن',
                'last_name' => 'بوزيد',
                'name' => 'د. عبدالرحمن بوزيد',
                'username' => 'dr_abdelrahman',
                'email' => 'abdelrahman@waslaa.local',
                'phone' => '0922000001',
            ],
            [
                'first_name' => 'فاطمة',
                'last_name' => 'الشريف',
                'name' => 'د. فاطمة الشريف',
                'username' => 'dr_fatima',
                'email' => 'fatima@waslaa.local',
                'phone' => '0922000002',
            ],
            [
                'first_name' => 'محمد',
                'last_name' => 'العريبي',
                'name' => 'د. محمد العريبي',
                'username' => 'dr_mohammed',
                'email' => 'mohammed.aribi@waslaa.local',
                'phone' => '0922000003',
            ],
        ];

        $examiners = [];
        foreach ($examinersData as $data) {
            $examiner = User::query()->firstOrCreate(
                ['email' => $data['email']],
                array_merge($data, [
                    'password' => $password,
                    'role' => 'examiner',
                    'status' => 'active',
                    'email_verified_at' => $now,
                    'phone_verified_at' => $now,
                ])
            );
            $examiner->assignRole('examiner');
            $examiners[] = $examiner;
        }

        // ════════════════════════════════════════════════════════════════
        //  3. COMPANY USERS & COMPANIES
        // ════════════════════════════════════════════════════════════════

        $companiesData = [
            [
                'user' => ['first_name' => 'إدارة', 'last_name' => 'الواحة', 'username' => 'waha_oil', 'email' => 'info@wahaoil.ly', 'phone' => '0912345001'],
                'company' => [
                    'name' => 'شركة الواحة للنفط',
                    'slug' => 'waha-oil',
                    'description' => 'شركة الواحة للنفط هي واحدة من أكبر شركات إنتاج النفط في ليبيا، تأسست عام 1956 ومقرها الرئيسي في طرابلس. تعمل الشركة في مجال استكشاف وإنتاج النفط والغاز الطبيعي وتساهم بشكل كبير في الاقتصاد الوطني الليبي.',
                    'logo_path' => 'companies/waha.png',
                    'website_url' => 'https://www.wahaoil.ly',
                    'city' => 'طرابلس',
                    'address' => 'شارع الجمهورية، طرابلس',
                    'phone' => '021-3614141',
                    'email' => 'info@wahaoil.ly',
                ],
                'logo_asset' => 'Waha.png',
            ],
            [
                'user' => ['first_name' => 'إدارة', 'last_name' => 'مليتة', 'username' => 'mellitah', 'email' => 'info@mellitah.ly', 'phone' => '0912345002'],
                'company' => [
                    'name' => 'شركة مليتة للنفط والغاز',
                    'slug' => 'mellitah-oil',
                    'description' => 'شركة مليتة للنفط والغاز هي شركة مشتركة بين المؤسسة الوطنية للنفط وشركة إيني الإيطالية. تعمل في مجال استكشاف وإنتاج ونقل النفط والغاز في الحوض الغربي الليبي.',
                    'logo_path' => 'companies/mellitah.png',
                    'website_url' => 'https://www.mellitah.ly',
                    'city' => 'طرابلس',
                    'address' => 'طريق الشط، طرابلس',
                    'phone' => '021-4870101',
                    'email' => 'info@mellitah.ly',
                ],
                'logo_asset' => 'mellitah.png',
            ],
            [
                'user' => ['first_name' => 'إدارة', 'last_name' => 'ليبيانا', 'username' => 'libyana', 'email' => 'info@libyana.ly', 'phone' => '0912345003'],
                'company' => [
                    'name' => 'ليبيانا للهاتف المحمول',
                    'slug' => 'libyana-mobile',
                    'description' => 'ليبيانا هي إحدى شركتي الاتصالات الرائدتين في ليبيا، تقدم خدمات الهاتف المحمول والإنترنت لملايين المشتركين في جميع أنحاء البلاد. تتميز بتغطية واسعة وخدمات رقمية متطورة.',
                    'logo_path' => 'companies/libyana.jpg',
                    'website_url' => 'https://www.libyana.ly',
                    'city' => 'طرابلس',
                    'address' => 'شارع النصر، طرابلس',
                    'phone' => '021-7200000',
                    'email' => 'info@libyana.ly',
                ],
                'logo_asset' => 'libyana.JPG',
            ],
            [
                'user' => ['first_name' => 'إدارة', 'last_name' => 'المدار', 'username' => 'almadar', 'email' => 'info@almadar.ly', 'phone' => '0912345004'],
                'company' => [
                    'name' => 'شركة المدار الجديد للتقنية',
                    'slug' => 'almadar-aljadid',
                    'description' => 'المدار الجديد هي شركة اتصالات ليبية رائدة تأسست عام 1997. تقدم خدمات الهاتف المحمول والإنترنت عالي السرعة والحلول الرقمية للأفراد والشركات في ليبيا.',
                    'logo_path' => 'companies/madar.jpg',
                    'website_url' => 'https://www.almadar.ly',
                    'city' => 'طرابلس',
                    'address' => 'شارع أول سبتمبر، طرابلس',
                    'phone' => '021-3400400',
                    'email' => 'info@almadar.ly',
                ],
                'logo_asset' => 'madar.JPG',
            ],
            [
                'user' => ['first_name' => 'إدارة', 'last_name' => 'الجمهورية', 'username' => 'jumhoria_bank', 'email' => 'info@jumhoria.ly', 'phone' => '0912345005'],
                'company' => [
                    'name' => 'مصرف الجمهورية',
                    'slug' => 'jumhoria-bank',
                    'description' => 'مصرف الجمهورية هو أحد أكبر المصارف التجارية في ليبيا، يقدم مجموعة شاملة من الخدمات المصرفية والمالية للأفراد والشركات. يمتلك شبكة واسعة من الفروع في جميع المدن الليبية.',
                    'logo_path' => 'companies/jumhoria.png',
                    'website_url' => 'https://www.jumhoria.ly',
                    'city' => 'طرابلس',
                    'address' => 'شارع عمر المختار، طرابلس',
                    'phone' => '021-3338080',
                    'email' => 'info@jumhoria.ly',
                ],
                'logo_asset' => 'jumhoria.png',
            ],
            [
                'user' => ['first_name' => 'إدارة', 'last_name' => 'الكهرباء', 'username' => 'gecol', 'email' => 'info@gecol.ly', 'phone' => '0912345006'],
                'company' => [
                    'name' => 'الشركة العامة للكهرباء',
                    'slug' => 'gecol',
                    'description' => 'الشركة العامة للكهرباء هي المسؤولة عن توليد ونقل وتوزيع الطاقة الكهربائية في ليبيا. تعمل على تطوير البنية التحتية الكهربائية وتوفير الطاقة لجميع المناطق الليبية.',
                    'logo_path' => 'companies/gecol.jpg',
                    'website_url' => 'https://www.gecol.ly',
                    'city' => 'طرابلس',
                    'address' => 'شارع الزاوية، طرابلس',
                    'phone' => '021-3401500',
                    'email' => 'info@gecol.ly',
                ],
                'logo_asset' => 'oil.JPG',
            ],
            [
                'user' => ['first_name' => 'إدارة', 'last_name' => 'الوحدة', 'username' => 'wahda_bank', 'email' => 'info@wahdabank.ly', 'phone' => '0912345007'],
                'company' => [
                    'name' => 'مصرف الوحدة',
                    'slug' => 'wahda-bank',
                    'description' => 'مصرف الوحدة هو مصرف تجاري ليبي يقدم خدمات مصرفية متنوعة تشمل الحسابات الجارية والتوفير والقروض والتحويلات المالية. يمتلك فروعاً في معظم المدن الليبية.',
                    'logo_path' => 'companies/bank.jpg',
                    'website_url' => 'https://www.wahdabank.ly',
                    'city' => 'بنغازي',
                    'address' => 'شارع جمال عبدالناصر، بنغازي',
                    'phone' => '061-2234567',
                    'email' => 'info@wahdabank.ly',
                ],
                'logo_asset' => 'bank.jpg',
            ],
            [
                'user' => ['first_name' => 'إدارة', 'last_name' => 'الأكاديمية', 'username' => 'academy_ly', 'email' => 'info@academy.ly', 'phone' => '0912345008'],
                'company' => [
                    'name' => 'الأكاديمية الليبية للاتصالات والمعلوماتية',
                    'slug' => 'libyan-academy-ict',
                    'description' => 'الأكاديمية الليبية للاتصالات والمعلوماتية هي مؤسسة تعليمية وتدريبية متخصصة في مجال تقنية المعلومات والاتصالات. تقدم برامج تدريبية وشهادات مهنية معتمدة.',
                    'logo_path' => 'companies/gapda.png',
                    'website_url' => 'https://www.academy.ly',
                    'city' => 'طرابلس',
                    'address' => 'طريق المطار، طرابلس',
                    'map_url' => 'https://maps.app.goo.gl/6rE3qRCiWwfx1ebJ8',
                    'phone' => '021-4780000',
                    'email' => 'info@academy.ly',
                ],
                'logo_asset' => 'gapda.png',
            ],
        ];

        $companies = [];
        $companyUserModels = [];

        foreach ($companiesData as $cd) {
            $companyUser = User::query()->firstOrCreate(
                ['email' => $cd['user']['email']],
                array_merge($cd['user'], [
                    'name' => $cd['user']['first_name'] . ' ' . $cd['user']['last_name'],
                    'password' => $password,
                    'role' => 'company',
                    'status' => 'active',
                    'email_verified_at' => $now,
                    'phone_verified_at' => $now,
                ])
            );

            $company = Company::query()->firstOrCreate(
                ['slug' => $cd['company']['slug']],
                array_merge($cd['company'], [
                    'user_id' => $companyUser->id,
                    'is_active' => true,
                    'status' => 'approved',
                ])
            );

            $companies[] = $company;
            $companyUserModels[] = $companyUser;

            // Copy logo asset to storage
            $this->copyCompanyLogo($cd['logo_asset'], $cd['company']['logo_path']);
        }

        // ════════════════════════════════════════════════════════════════
        //  4. SUPERVISOR USERS & SUPERVISORS
        // ════════════════════════════════════════════════════════════════

        $supervisorsData = [
            ['first_name' => 'عمر', 'last_name' => 'الحاسي', 'username' => 'omar_supervisor', 'email' => 'omar@wahaoil.ly', 'phone' => '0923000001', 'department' => 'قسم تقنية المعلومات', 'company_index' => 0],
            ['first_name' => 'نورة', 'last_name' => 'الفقيه', 'username' => 'noura_supervisor', 'email' => 'noura@mellitah.ly', 'phone' => '0923000002', 'department' => 'قسم الهندسة', 'company_index' => 1],
            ['first_name' => 'يوسف', 'last_name' => 'المبروك', 'username' => 'yousef_supervisor', 'email' => 'yousef@libyana.ly', 'phone' => '0923000003', 'department' => 'قسم التطوير', 'company_index' => 2],
            ['first_name' => 'آمنة', 'last_name' => 'الغرياني', 'username' => 'amna_supervisor', 'email' => 'amna@almadar.ly', 'phone' => '0923000004', 'department' => 'قسم الشبكات', 'company_index' => 3],
            ['first_name' => 'مصطفى', 'last_name' => 'الورفلي', 'username' => 'mustafa_supervisor', 'email' => 'mustafa@jumhoria.ly', 'phone' => '0923000005', 'department' => 'قسم البرمجيات', 'company_index' => 4],
            ['first_name' => 'هاجر', 'last_name' => 'البوعيشي', 'username' => 'hajer_supervisor', 'email' => 'hajer@gecol.ly', 'phone' => '0923000006', 'department' => 'قسم الأنظمة', 'company_index' => 5],
            ['first_name' => 'إبراهيم', 'last_name' => 'السنوسي', 'username' => 'ibrahim_supervisor', 'email' => 'ibrahim@wahdabank.ly', 'phone' => '0923000007', 'department' => 'قسم تقنية المعلومات', 'company_index' => 6],
            ['first_name' => 'ليلى', 'last_name' => 'القماطي', 'username' => 'layla_supervisor', 'email' => 'layla@academy.ly', 'phone' => '0923000008', 'department' => 'قسم التدريب', 'company_index' => 7],
        ];

        $supervisors = [];
        $supervisorUsers = [];

        foreach ($supervisorsData as $sd) {
            $supervisorUser = User::query()->firstOrCreate(
                ['email' => $sd['email']],
                [
                    'first_name' => $sd['first_name'],
                    'last_name' => $sd['last_name'],
                    'name' => $sd['first_name'] . ' ' . $sd['last_name'],
                    'username' => $sd['username'],
                    'phone' => $sd['phone'],
                    'password' => $password,
                    'role' => 'supervisor',
                    'status' => 'active',
                    'email_verified_at' => $now,
                    'phone_verified_at' => $now,
                ]
            );
            $supervisorUser->assignRole('supervisor');
            $supervisorUsers[] = $supervisorUser;

            $supervisor = Supervisor::query()->firstOrCreate(
                ['user_id' => $supervisorUser->id],
                [
                    'company_id' => $companies[$sd['company_index']]->id,
                    'name' => $sd['first_name'] . ' ' . $sd['last_name'],
                    'phone' => $sd['phone'],
                    'email' => $sd['email'],
                    'type' => 'company',
                    'department' => $sd['department'],
                    'is_active' => true,
                ]
            );
            $supervisors[] = $supervisor;
        }

        // ════════════════════════════════════════════════════════════════
        //  5. STUDENT USERS & PROFILES
        // ════════════════════════════════════════════════════════════════

        $studentsData = [
            [
                'first_name' => 'علي',
                'last_name' => 'الساعدي',
                'username' => 'ali_student',
                'email' => 'ali@student.ly',
                'phone' => '0945000001',
                'university_name' => 'جامعة طرابلس',
                'student_number' => 'TU-2022-001',
                'study_level' => 'سنة رابعة',
                'bio' => 'طالب في قسم هندسة الحاسوب، مهتم بتطوير تطبيقات الموبايل والذكاء الاصطناعي.',
                'specialization_id' => 1, // حاسب آلي
                'expected_graduation_at' => '2026-09-15',
            ],
            [
                'first_name' => 'مريم',
                'last_name' => 'الكيلاني',
                'username' => 'mariam_student',
                'email' => 'mariam@student.ly',
                'phone' => '0945000002',
                'university_name' => 'جامعة طرابلس',
                'student_number' => 'TU-2022-002',
                'study_level' => 'سنة رابعة',
                'bio' => 'طالبة في قسم هندسة الاتصالات، أسعى لاكتساب خبرة عملية في مجال الشبكات.',
                'specialization_id' => 3, // اتصالات
                'expected_graduation_at' => '2026-09-15',
            ],
            [
                'first_name' => 'عبدالله',
                'last_name' => 'الزوي',
                'username' => 'abdullah_student',
                'email' => 'abdullah@student.ly',
                'phone' => '0945000003',
                'university_name' => 'جامعة بنغازي',
                'student_number' => 'BU-2022-003',
                'study_level' => 'سنة ثالثة',
                'bio' => 'طالب في قسم التحكم الآلي، مهتم بأنظمة التحكم الصناعي وبرمجة المتحكمات.',
                'specialization_id' => 2, // تحكم
                'expected_graduation_at' => '2027-06-15',
            ],
            [
                'first_name' => 'هدى',
                'last_name' => 'العبيدي',
                'username' => 'huda_student',
                'email' => 'huda@student.ly',
                'phone' => '0945000004',
                'university_name' => 'جامعة مصراتة',
                'student_number' => 'MU-2022-004',
                'study_level' => 'سنة رابعة',
                'bio' => 'طالبة في قسم علوم الحاسوب، شغوفة بتطوير الويب وقواعد البيانات.',
                'specialization_id' => 1, // حاسب آلي
                'expected_graduation_at' => '2026-09-15',
            ],
            [
                'first_name' => 'أنس',
                'last_name' => 'الفيتوري',
                'username' => 'anas_student',
                'email' => 'anas@student.ly',
                'phone' => '0945000005',
                'university_name' => 'جامعة طرابلس',
                'student_number' => 'TU-2023-005',
                'study_level' => 'سنة ثالثة',
                'bio' => 'طالب في قسم هندسة الاتصالات، مهتم بتقنيات الجيل الخامس وأمن الشبكات.',
                'specialization_id' => 3, // اتصالات
                'expected_graduation_at' => '2027-06-15',
            ],
            [
                'first_name' => 'أسماء',
                'last_name' => 'الحداد',
                'username' => 'asmaa_student',
                'email' => 'asmaa@student.ly',
                'phone' => '0945000006',
                'university_name' => 'جامعة بنغازي',
                'student_number' => 'BU-2023-006',
                'study_level' => 'سنة رابعة',
                'bio' => 'طالبة في قسم هندسة التحكم، أطمح للعمل في مجال الأتمتة الصناعية.',
                'specialization_id' => 2, // تحكم
                'expected_graduation_at' => '2026-09-15',
            ],
        ];

        $students = [];

        foreach ($studentsData as $sd) {
            $studentUser = User::query()->firstOrCreate(
                ['email' => $sd['email']],
                [
                    'first_name' => $sd['first_name'],
                    'last_name' => $sd['last_name'],
                    'name' => $sd['first_name'] . ' ' . $sd['last_name'],
                    'username' => $sd['username'],
                    'phone' => $sd['phone'],
                    'password' => $password,
                    'role' => 'student',
                    'status' => 'active',
                    'email_verified_at' => $now,
                    'phone_verified_at' => $now,
                ]
            );

            StudentProfile::query()->firstOrCreate(
                ['user_id' => $studentUser->id],
                [
                    'specialization_id' => $sd['specialization_id'],
                    'university_name' => $sd['university_name'],
                    'student_number' => $sd['student_number'],
                    'study_level' => $sd['study_level'],
                    'bio' => $sd['bio'],
                    'expected_graduation_at' => $sd['expected_graduation_at'],
                ]
            );

            UserSetting::query()->firstOrCreate(
                ['user_id' => $studentUser->id],
                [
                    'language' => 'ar',
                    'push_notifications_enabled' => true,
                    'email_notifications_enabled' => true,
                    'chat_notifications_enabled' => true,
                    'theme' => 'light',
                ]
            );

            $students[] = $studentUser;
        }

        // ════════════════════════════════════════════════════════════════
        //  6. INTERNSHIP OPPORTUNITIES (OFFERS)
        // ════════════════════════════════════════════════════════════════

        $opportunitiesData = [
            // شركة الواحة للنفط
            [
                'company_index' => 0,
                'specialization_id' => 1,
                'title' => 'تدريب في تطوير أنظمة إدارة البيانات النفطية',
                'description' => 'فرصة تدريب عملي في قسم تقنية المعلومات بشركة الواحة للنفط. سيتعلم المتدرب تصميم وتطوير أنظمة إدارة قواعد البيانات المستخدمة في عمليات الإنتاج والتكرير. يشمل التدريب العمل على أنظمة Oracle وSQL Server وتطوير واجهات المستخدم.',
                'city' => 'طرابلس',
                'location_text' => 'المقر الرئيسي - شارع الجمهورية',
                'duration_text' => '3 أشهر',
                'duration_days' => 90,
                'seats_count' => 3,
                'status' => 'published',
                'start_date' => '2026-05-01',
                'end_date' => '2026-07-31',
                'application_deadline' => '2026-04-25',
                'image_path' => 'companies/waha.png',
            ],
            [
                'company_index' => 0,
                'specialization_id' => 2,
                'title' => 'تدريب في أنظمة التحكم الصناعي (SCADA)',
                'description' => 'تدريب متخصص في أنظمة التحكم الإشرافي وتجميع البيانات (SCADA) المستخدمة في حقول النفط. يتضمن التدريب التعرف على أنظمة PLC وأنظمة المراقبة والتحكم عن بُعد في منشآت الإنتاج.',
                'city' => 'طرابلس',
                'location_text' => 'مركز العمليات - طرابلس',
                'duration_text' => '3 أشهر',
                'duration_days' => 90,
                'seats_count' => 2,
                'status' => 'published',
                'start_date' => '2026-05-01',
                'end_date' => '2026-07-31',
                'application_deadline' => '2026-04-25',
                'image_path' => 'companies/waha.png',
            ],
            // شركة مليتة للنفط والغاز
            [
                'company_index' => 1,
                'specialization_id' => 1,
                'title' => 'تدريب في تطوير تطبيقات الويب الداخلية',
                'description' => 'فرصة تدريب في قسم تقنية المعلومات لتطوير تطبيقات الويب الداخلية للشركة. يشمل العمل على تقنيات Laravel وVue.js وتطوير لوحات تحكم إدارية لمتابعة عمليات الإنتاج.',
                'city' => 'طرابلس',
                'location_text' => 'المقر الرئيسي - طريق الشط',
                'duration_text' => 'شهرين',
                'duration_days' => 60,
                'seats_count' => 2,
                'status' => 'published',
                'start_date' => '2026-05-15',
                'end_date' => '2026-07-15',
                'application_deadline' => '2026-05-01',
                'image_path' => 'companies/mellitah.png',
            ],
            // ليبيانا
            [
                'company_index' => 2,
                'specialization_id' => 3,
                'title' => 'تدريب في هندسة شبكات الاتصالات المتنقلة',
                'description' => 'تدريب عملي في قسم هندسة الشبكات بشركة ليبيانا. يتضمن التعرف على بنية شبكات 4G/5G وتخطيط التغطية وتحليل الأداء وصيانة محطات القاعدة. فرصة للعمل مع أحدث تقنيات الاتصالات.',
                'city' => 'طرابلس',
                'location_text' => 'المقر الرئيسي - شارع النصر',
                'duration_text' => '3 أشهر',
                'duration_days' => 90,
                'seats_count' => 4,
                'status' => 'published',
                'start_date' => '2026-06-01',
                'end_date' => '2026-08-31',
                'application_deadline' => '2026-05-15',
                'image_path' => 'companies/libyana.jpg',
            ],
            [
                'company_index' => 2,
                'specialization_id' => 1,
                'title' => 'تدريب في تطوير تطبيقات الهاتف المحمول',
                'description' => 'فرصة تدريب في فريق تطوير تطبيقات الموبايل بشركة ليبيانا. سيعمل المتدرب على تطوير تطبيقات Flutter للعملاء وتحسين تجربة المستخدم في التطبيقات الحالية.',
                'city' => 'طرابلس',
                'location_text' => 'مركز التطوير - طرابلس',
                'duration_text' => 'شهرين',
                'duration_days' => 60,
                'seats_count' => 3,
                'status' => 'published',
                'start_date' => '2026-05-01',
                'end_date' => '2026-06-30',
                'application_deadline' => '2026-04-20',
                'image_path' => 'companies/libyana.jpg',
            ],
            // المدار الجديد
            [
                'company_index' => 3,
                'specialization_id' => 3,
                'title' => 'تدريب في تخطيط وتصميم الشبكات',
                'description' => 'تدريب في قسم تخطيط الشبكات بشركة المدار. يتضمن التعرف على أدوات تخطيط التغطية الشبكية وتحليل البيانات وتصميم حلول الربط بين المواقع.',
                'city' => 'طرابلس',
                'location_text' => 'المقر الرئيسي - شارع أول سبتمبر',
                'duration_text' => '3 أشهر',
                'duration_days' => 90,
                'seats_count' => 3,
                'status' => 'published',
                'start_date' => '2026-05-01',
                'end_date' => '2026-07-31',
                'application_deadline' => '2026-04-20',
                'image_path' => 'companies/madar.jpg',
            ],
            [
                'company_index' => 3,
                'specialization_id' => 1,
                'title' => 'تدريب في أمن المعلومات والأمن السيبراني',
                'description' => 'فرصة تدريب في فريق أمن المعلومات بشركة المدار. يتضمن التعرف على أساسيات الأمن السيبراني واختبار الاختراق وحماية البنية التحتية للشبكات.',
                'city' => 'طرابلس',
                'location_text' => 'مركز العمليات الأمنية - طرابلس',
                'duration_text' => 'شهرين',
                'duration_days' => 60,
                'seats_count' => 2,
                'status' => 'published',
                'start_date' => '2026-06-01',
                'end_date' => '2026-07-31',
                'application_deadline' => '2026-05-15',
                'image_path' => 'companies/madar.jpg',
            ],
            // مصرف الجمهورية
            [
                'company_index' => 4,
                'specialization_id' => 1,
                'title' => 'تدريب في تطوير الأنظمة المصرفية الإلكترونية',
                'description' => 'تدريب عملي في قسم تقنية المعلومات بمصرف الجمهورية. يشمل التعرف على أنظمة الخدمات المصرفية الإلكترونية وتطوير واجهات برمجة التطبيقات وأنظمة الدفع الإلكتروني.',
                'city' => 'طرابلس',
                'location_text' => 'الإدارة العامة - شارع عمر المختار',
                'duration_text' => '3 أشهر',
                'duration_days' => 90,
                'seats_count' => 2,
                'status' => 'published',
                'start_date' => '2026-05-01',
                'end_date' => '2026-07-31',
                'application_deadline' => '2026-04-25',
                'image_path' => 'companies/jumhoria.png',
            ],
            // الشركة العامة للكهرباء
            [
                'company_index' => 5,
                'specialization_id' => 2,
                'title' => 'تدريب في أنظمة التحكم في محطات التوليد',
                'description' => 'تدريب ميداني في محطات توليد الكهرباء. يشمل التعرف على أنظمة التحكم والحماية المستخدمة في المحطات وصيانة الأجهزة الكهربائية والإلكترونية.',
                'city' => 'طرابلس',
                'location_text' => 'محطة غرب طرابلس',
                'duration_text' => '3 أشهر',
                'duration_days' => 90,
                'seats_count' => 3,
                'status' => 'published',
                'start_date' => '2026-05-15',
                'end_date' => '2026-08-15',
                'application_deadline' => '2026-05-01',
                'image_path' => 'companies/gecol.jpg',
            ],
            // مصرف الوحدة
            [
                'company_index' => 6,
                'specialization_id' => 1,
                'title' => 'تدريب في إدارة قواعد البيانات المصرفية',
                'description' => 'فرصة تدريب في قسم تقنية المعلومات بمصرف الوحدة في بنغازي. يتضمن التعرف على إدارة قواعد البيانات وتطوير التقارير المالية وصيانة الأنظمة المصرفية.',
                'city' => 'بنغازي',
                'location_text' => 'الإدارة العامة - شارع جمال عبدالناصر',
                'duration_text' => 'شهرين',
                'duration_days' => 60,
                'seats_count' => 2,
                'status' => 'published',
                'start_date' => '2026-05-01',
                'end_date' => '2026-06-30',
                'application_deadline' => '2026-04-20',
                'image_path' => 'companies/bank.jpg',
            ],
            // الأكاديمية الليبية
            [
                'company_index' => 7,
                'specialization_id' => 1,
                'title' => 'تدريب في تطوير منصات التعليم الإلكتروني',
                'description' => 'فرصة تدريب في الأكاديمية الليبية للعمل على تطوير منصات التعليم الإلكتروني وأنظمة إدارة المحتوى التعليمي باستخدام تقنيات الويب الحديثة.',
                'city' => 'طرابلس',
                'location_text' => 'الأكاديمية الليبية - طريق المطار',
                'duration_text' => '3 أشهر',
                'duration_days' => 90,
                'seats_count' => 4,
                'status' => 'published',
                'start_date' => '2026-05-01',
                'end_date' => '2026-07-31',
                'application_deadline' => '2026-04-25',
                'image_path' => 'companies/gapda.png',
            ],
            [
                'company_index' => 7,
                'specialization_id' => 3,
                'title' => 'تدريب في صيانة وتشغيل شبكات الألياف الضوئية',
                'description' => 'تدريب تطبيقي على تركيب وصيانة شبكات الألياف الضوئية وأجهزة الربط والتحويل. يشمل التدريب على أجهزة القياس المتخصصة وبروتوكولات الشبكات.',
                'city' => 'طرابلس',
                'location_text' => 'مختبرات الأكاديمية - طريق المطار',
                'duration_text' => 'شهرين',
                'duration_days' => 60,
                'seats_count' => 3,
                'status' => 'published',
                'start_date' => '2026-06-01',
                'end_date' => '2026-07-31',
                'application_deadline' => '2026-05-20',
                'image_path' => 'companies/gapda.png',
            ],
        ];

        $opportunities = [];

        foreach ($opportunitiesData as $od) {
            $opportunity = InternshipOpportunity::query()->firstOrCreate(
                [
                    'company_id' => $companies[$od['company_index']]->id,
                    'title' => $od['title'],
                ],
                [
                    'specialization_id' => $od['specialization_id'],
                    'description' => $od['description'],
                    'city' => $od['city'],
                    'location_text' => $od['location_text'],
                    'duration_text' => $od['duration_text'],
                    'duration_days' => $od['duration_days'],
                    'seats_count' => $od['seats_count'],
                    'is_available' => true,
                    'status' => $od['status'],
                    'start_date' => $od['start_date'],
                    'end_date' => $od['end_date'],
                    'application_deadline' => $od['application_deadline'],
                    'image_path' => $od['image_path'],
                ]
            );
            $opportunities[] = $opportunity;
        }

        // ════════════════════════════════════════════════════════════════
        //  7. APPLICATIONS
        // ════════════════════════════════════════════════════════════════

        // Student 0 (علي - حاسب) -> Opportunity 0 (الواحة - بيانات) => accepted
        // Student 1 (مريم - اتصالات) -> Opportunity 3 (ليبيانا - شبكات) => accepted
        // Student 2 (عبدالله - تحكم) -> Opportunity 8 (الكهرباء - تحكم) => accepted
        // Student 3 (هدى - حاسب) -> Opportunity 4 (ليبيانا - موبايل) => accepted
        // Student 4 (أنس - اتصالات) -> Opportunity 5 (المدار - شبكات) => pending
        // Student 5 (أسماء - تحكم) -> Opportunity 1 (الواحة - SCADA) => pending

        $applicationsData = [
            [
                'student_index' => 0, 'opportunity_index' => 0,
                'status' => 'accepted', 'reviewed_at' => $now->copy()->subDays(10),
                'review_notes' => 'مرشح ممتاز، خبرة سابقة في قواعد البيانات.',
            ],
            [
                'student_index' => 1, 'opportunity_index' => 3,
                'status' => 'accepted', 'reviewed_at' => $now->copy()->subDays(8),
                'review_notes' => 'طالبة متميزة في مجال الاتصالات.',
            ],
            [
                'student_index' => 2, 'opportunity_index' => 8,
                'status' => 'accepted', 'reviewed_at' => $now->copy()->subDays(7),
                'review_notes' => 'خلفية جيدة في أنظمة التحكم الصناعي.',
            ],
            [
                'student_index' => 3, 'opportunity_index' => 4,
                'status' => 'accepted', 'reviewed_at' => $now->copy()->subDays(9),
                'review_notes' => 'مهارات برمجة ممتازة في Flutter وDart.',
            ],
            [
                'student_index' => 4, 'opportunity_index' => 5,
                'status' => 'pending', 'reviewed_at' => null,
                'review_notes' => null,
            ],
            [
                'student_index' => 5, 'opportunity_index' => 1,
                'status' => 'pending', 'reviewed_at' => null,
                'review_notes' => null,
            ],
            // Extra applications - rejected
            [
                'student_index' => 4, 'opportunity_index' => 3,
                'status' => 'rejected', 'reviewed_at' => $now->copy()->subDays(5),
                'review_notes' => 'عدد المقاعد اكتمل، ننصح بالتقديم على الفرص الأخرى.',
            ],
            [
                'student_index' => 5, 'opportunity_index' => 8,
                'status' => 'rejected', 'reviewed_at' => $now->copy()->subDays(4),
                'review_notes' => 'التخصص غير مطابق تماماً لمتطلبات الفرصة.',
            ],
        ];

        $applications = [];

        foreach ($applicationsData as $ad) {
            $student = $students[$ad['student_index']];
            $opportunity = $opportunities[$ad['opportunity_index']];
            $profile = $student->studentProfile;

            $application = Application::query()->firstOrCreate(
                [
                    'student_id' => $student->id,
                    'opportunity_id' => $opportunity->id,
                ],
                [
                    'company_id' => $opportunity->company_id,
                    'full_name_snapshot' => $student->name,
                    'phone_snapshot' => $student->phone,
                    'email_snapshot' => $student->email,
                    'university_snapshot' => $profile?->university_name,
                    'major_snapshot' => $profile?->specialization?->name ?? 'حاسب آلي',
                    'level_snapshot' => $profile?->study_level,
                    'notes' => 'أرغب في اكتساب خبرة عملية في هذا المجال.',
                    'status' => $ad['status'],
                    'submitted_at' => $now->copy()->subDays(15),
                    'reviewed_at' => $ad['reviewed_at'],
                    'reviewed_by' => $ad['reviewed_at'] ? $operationsAdmin->id : null,
                    'review_notes' => $ad['review_notes'],
                ]
            );
            $applications[] = $application;
        }

        // ════════════════════════════════════════════════════════════════
        //  8. INTERNSHIPS (from accepted applications)
        // ════════════════════════════════════════════════════════════════

        $internshipsData = [
            [
                'application_index' => 0, 'student_index' => 0, 'opportunity_index' => 0,
                'supervisor_index' => 0, // عمر - الواحة
                'title' => 'تدريب في تطوير أنظمة إدارة البيانات النفطية',
                'status' => 'active',
                'start_date' => '2026-05-01', 'end_date' => '2026-07-31', 'report_due_date' => '2026-07-25',
                'notes' => 'التدريب يتم في المقر الرئيسي لشركة الواحة، الحضور من 8 صباحاً إلى 2 ظهراً.',
            ],
            [
                'application_index' => 1, 'student_index' => 1, 'opportunity_index' => 3,
                'supervisor_index' => 2, // يوسف - ليبيانا
                'title' => 'تدريب في هندسة شبكات الاتصالات المتنقلة',
                'status' => 'active',
                'start_date' => '2026-06-01', 'end_date' => '2026-08-31', 'report_due_date' => '2026-08-25',
                'notes' => 'يشمل التدريب زيارات ميدانية لمحطات القاعدة.',
            ],
            [
                'application_index' => 2, 'student_index' => 2, 'opportunity_index' => 8,
                'supervisor_index' => 5, // هاجر - الكهرباء
                'title' => 'تدريب في أنظمة التحكم في محطات التوليد',
                'status' => 'active',
                'start_date' => '2026-05-15', 'end_date' => '2026-08-15', 'report_due_date' => '2026-08-10',
                'notes' => 'يجب الالتزام بإجراءات السلامة في المحطة.',
            ],
            [
                'application_index' => 3, 'student_index' => 3, 'opportunity_index' => 4,
                'supervisor_index' => 2, // يوسف - ليبيانا
                'title' => 'تدريب في تطوير تطبيقات الهاتف المحمول',
                'status' => 'active',
                'start_date' => '2026-05-01', 'end_date' => '2026-06-30', 'report_due_date' => '2026-06-25',
                'notes' => 'العمل ضمن فريق Agile باستخدام Flutter.',
            ],
        ];

        $internships = [];

        foreach ($internshipsData as $id) {
            $internship = Internship::query()->firstOrCreate(
                ['application_id' => $applications[$id['application_index']]->id],
                [
                    'student_id' => $students[$id['student_index']]->id,
                    'company_id' => $opportunities[$id['opportunity_index']]->company_id,
                    'opportunity_id' => $opportunities[$id['opportunity_index']]->id,
                    'supervisor_id' => $supervisors[$id['supervisor_index']]->id,
                    'title' => $id['title'],
                    'status' => $id['status'],
                    'start_date' => $id['start_date'],
                    'end_date' => $id['end_date'],
                    'report_due_date' => $id['report_due_date'],
                    'notes' => $id['notes'],
                ]
            );
            $internships[] = $internship;
        }

        // ════════════════════════════════════════════════════════════════
        //  9. CHAT THREADS & MESSAGES
        // ════════════════════════════════════════════════════════════════

        $chatConversations = [
            // Thread 1: علي <-> عمر (الواحة)
            [
                'internship_index' => 0,
                'student_index' => 0,
                'supervisor_index' => 0,
                'messages' => [
                    ['sender' => 'supervisor', 'body' => 'السلام عليكم علي، أهلاً بك في شركة الواحة للنفط. أنا المهندس عمر الحاسي وسأكون مشرفك خلال فترة التدريب.', 'minutes_ago' => 4320],
                    ['sender' => 'student', 'body' => 'وعليكم السلام ورحمة الله، شكراً لك مهندس عمر. أنا متحمس جداً لبدء التدريب.', 'minutes_ago' => 4310],
                    ['sender' => 'supervisor', 'body' => 'ممتاز! يوم الأحد القادم ستبدأ معنا في قسم تقنية المعلومات. الحضور الساعة 8 صباحاً. أحضر معك بطاقتك الجامعية.', 'minutes_ago' => 4300],
                    ['sender' => 'student', 'body' => 'تمام، إن شاء الله سأكون موجود في الموعد. هل هناك أي متطلبات أخرى يجب تجهيزها؟', 'minutes_ago' => 4290],
                    ['sender' => 'supervisor', 'body' => 'لا، فقط احرص على تثبيت Oracle SQL Developer على جهازك اللابتوب. سنحتاجه من أول يوم.', 'minutes_ago' => 4280],
                    ['sender' => 'student', 'body' => 'تم تثبيته. شكراً لك مهندس عمر، نراكم يوم الأحد إن شاء الله.', 'minutes_ago' => 4270],
                    ['sender' => 'supervisor', 'body' => 'كيف حالك مع مشروع قاعدة البيانات؟ هل تحتاج أي مساعدة؟', 'minutes_ago' => 1440],
                    ['sender' => 'student', 'body' => 'الحمد لله، انتهيت من تصميم الجداول الأساسية. عندي سؤال بخصوص العلاقات بين جدول الإنتاج وجدول المخزون.', 'minutes_ago' => 1430],
                    ['sender' => 'supervisor', 'body' => 'أحسنت! تعال لمكتبي بعد صلاة الظهر ونراجع التصميم مع بعض.', 'minutes_ago' => 1420],
                    ['sender' => 'student', 'body' => 'إن شاء الله، شكراً لك.', 'minutes_ago' => 1410],
                ],
            ],
            // Thread 2: مريم <-> يوسف (ليبيانا)
            [
                'internship_index' => 1,
                'student_index' => 1,
                'supervisor_index' => 2,
                'messages' => [
                    ['sender' => 'supervisor', 'body' => 'مرحباً مريم، أنا المهندس يوسف المبروك، مشرفك في قسم هندسة الشبكات بشركة ليبيانا.', 'minutes_ago' => 2880],
                    ['sender' => 'student', 'body' => 'أهلاً مهندس يوسف، تشرفنا. متى نبدأ التدريب؟', 'minutes_ago' => 2870],
                    ['sender' => 'supervisor', 'body' => 'نبدأ يوم 1 يونيو إن شاء الله. أول أسبوع سيكون تعريفي بالشركة وأقسامها. بعدها ندخل في الجزء التقني.', 'minutes_ago' => 2860],
                    ['sender' => 'student', 'body' => 'ممتاز، هل سنتعامل مع أجهزة حقيقية أم محاكاة؟', 'minutes_ago' => 2850],
                    ['sender' => 'supervisor', 'body' => 'الاثنين! سنبدأ بالمحاكاة ثم ننتقل للعمل الميداني. سنزور بعض محطات القاعدة في طرابلس.', 'minutes_ago' => 2840],
                    ['sender' => 'student', 'body' => 'رائع جداً! أنا متحمسة للتجربة الميدانية. شكراً لك مهندس يوسف.', 'minutes_ago' => 2830],
                ],
            ],
            // Thread 3: عبدالله <-> هاجر (الكهرباء)
            [
                'internship_index' => 2,
                'student_index' => 2,
                'supervisor_index' => 5,
                'messages' => [
                    ['sender' => 'supervisor', 'body' => 'أهلاً عبدالله، أنا المهندسة هاجر البوعيشي من الشركة العامة للكهرباء. مرحباً بك في فريق التدريب.', 'minutes_ago' => 2160],
                    ['sender' => 'student', 'body' => 'شكراً مهندسة هاجر، سعيد بالانضمام للفريق.', 'minutes_ago' => 2150],
                    ['sender' => 'supervisor', 'body' => 'مهم جداً: قبل بدء التدريب في المحطة، يجب عليك حضور دورة السلامة المهنية. ستكون يوم الأحد القادم.', 'minutes_ago' => 2140],
                    ['sender' => 'student', 'body' => 'بالتأكيد، هل أحتاج لجلب أي معدات خاصة؟', 'minutes_ago' => 2130],
                    ['sender' => 'supervisor', 'body' => 'ستوفر لك الشركة كل معدات السلامة. فقط احرص على ارتداء أحذية مغلقة وملابس مناسبة للعمل الميداني.', 'minutes_ago' => 2120],
                    ['sender' => 'student', 'body' => 'فهمت، شكراً لك على التوضيح.', 'minutes_ago' => 2110],
                    ['sender' => 'supervisor', 'body' => 'عبدالله، كيف كانت تجربتك في غرفة التحكم اليوم؟', 'minutes_ago' => 720],
                    ['sender' => 'student', 'body' => 'كانت تجربة ممتازة! تعرفت على نظام SCADA المستخدم في المحطة وكيفية مراقبة مؤشرات الأداء.', 'minutes_ago' => 710],
                    ['sender' => 'supervisor', 'body' => 'أحسنت! غداً سنبدأ في الجزء العملي. جهز أسئلتك.', 'minutes_ago' => 700],
                ],
            ],
            // Thread 4: هدى <-> يوسف (ليبيانا)
            [
                'internship_index' => 3,
                'student_index' => 3,
                'supervisor_index' => 2,
                'messages' => [
                    ['sender' => 'supervisor', 'body' => 'أهلاً هدى، أنا المهندس يوسف. مرحباً بك في فريق تطوير التطبيقات.', 'minutes_ago' => 3600],
                    ['sender' => 'student', 'body' => 'شكراً مهندس يوسف! أنا متحمسة جداً للعمل على مشاريع Flutter.', 'minutes_ago' => 3590],
                    ['sender' => 'supervisor', 'body' => 'ممتاز! ستعملين مع الفريق على تحسين تطبيق ليبيانا للعملاء. هل عندك خبرة في State Management؟', 'minutes_ago' => 3580],
                    ['sender' => 'student', 'body' => 'نعم، استخدمت Provider وRiverpod في مشاريع جامعية. وكمان عندي خبرة بسيطة في BLoC.', 'minutes_ago' => 3570],
                    ['sender' => 'supervisor', 'body' => 'ممتاز! نحن نستخدم Provider هنا. ستكونين مرتاحة. أرسلي لي رابط GitHub الخاص بك لو ممكن.', 'minutes_ago' => 3560],
                    ['sender' => 'student', 'body' => 'بالتأكيد، سأرسله لك حالاً. شكراً مهندس يوسف.', 'minutes_ago' => 3550],
                    ['sender' => 'supervisor', 'body' => 'هدى، تقريرك الأسبوعي كان ممتاز. أحسنتي في تنظيم المهام وتوثيق الكود.', 'minutes_ago' => 360],
                    ['sender' => 'student', 'body' => 'شكراً جزيلاً! استفدت كثيراً من ملاحظاتكم على الكود. هل هناك تحسينات إضافية تنصح بها؟', 'minutes_ago' => 350],
                    ['sender' => 'supervisor', 'body' => 'حاولي تكتبي Unit Tests للـ Repository Layer. هذا شي مهم في أي مشروع حقيقي.', 'minutes_ago' => 340],
                    ['sender' => 'student', 'body' => 'تمام، سأبدأ في كتابة الاختبارات من اليوم. شكراً على النصيحة!', 'minutes_ago' => 330],
                ],
            ],
        ];

        foreach ($chatConversations as $cc) {
            $internship = $internships[$cc['internship_index']];
            $student = $students[$cc['student_index']];
            $supervisor = $supervisors[$cc['supervisor_index']];

            $lastMessageTime = $now->copy()->subMinutes(collect($cc['messages'])->min('minutes_ago'));

            $thread = ChatThread::query()->firstOrCreate(
                [
                    'internship_id' => $internship->id,
                    'student_id' => $student->id,
                    'supervisor_id' => $supervisor->id,
                ],
                [
                    'last_message_at' => $lastMessageTime,
                    'status' => 'open',
                ]
            );

            foreach ($cc['messages'] as $msg) {
                $senderId = $msg['sender'] === 'student'
                    ? $student->id
                    : $supervisor->user_id;

                $sentAt = $now->copy()->subMinutes($msg['minutes_ago']);

                Message::query()->firstOrCreate(
                    [
                        'thread_id' => $thread->id,
                        'sender_id' => $senderId,
                        'body' => $msg['body'],
                    ],
                    [
                        'message_type' => 'text',
                        'sent_at' => $sentAt,
                        'read_at' => $sentAt->copy()->addMinutes(5),
                    ]
                );
            }
        }

        // ════════════════════════════════════════════════════════════════
        //  10. REPORTS
        // ════════════════════════════════════════════════════════════════

        $reportsData = [
            // علي - تقرير أولي
            [
                'internship_index' => 0, 'student_index' => 0,
                'report_type' => 'initial',
                'title' => 'التقرير الأولي - تدريب إدارة البيانات النفطية',
                'file_name' => 'تقرير_أولي_علي_الساعدي.pdf',
                'file_extension' => 'pdf',
                'file_size' => 2457600,
                'status' => 'approved',
                'submitted_at' => $now->copy()->subDays(20),
                'reviewed_at' => $now->copy()->subDays(18),
                'review_notes' => 'تقرير ممتاز ومنظم. يوضح فهماً جيداً لبيئة العمل.',
            ],
            // علي - تقرير نصفي
            [
                'internship_index' => 0, 'student_index' => 0,
                'report_type' => 'midterm',
                'title' => 'التقرير النصفي - تدريب إدارة البيانات النفطية',
                'file_name' => 'تقرير_نصفي_علي_الساعدي.pdf',
                'file_extension' => 'pdf',
                'file_size' => 3145728,
                'status' => 'submitted',
                'submitted_at' => $now->copy()->subDays(3),
                'reviewed_at' => null,
                'review_notes' => null,
            ],
            // مريم - تقرير أولي
            [
                'internship_index' => 1, 'student_index' => 1,
                'report_type' => 'initial',
                'title' => 'التقرير الأولي - تدريب هندسة الشبكات',
                'file_name' => 'تقرير_أولي_مريم_الكيلاني.pdf',
                'file_extension' => 'pdf',
                'file_size' => 1843200,
                'status' => 'approved',
                'submitted_at' => $now->copy()->subDays(15),
                'reviewed_at' => $now->copy()->subDays(13),
                'review_notes' => 'تقرير جيد. يُرجى إضافة مزيد من التفاصيل التقنية في التقرير القادم.',
            ],
            // عبدالله - تقرير أولي
            [
                'internship_index' => 2, 'student_index' => 2,
                'report_type' => 'initial',
                'title' => 'التقرير الأولي - تدريب أنظمة التحكم',
                'file_name' => 'تقرير_أولي_عبدالله_الزوي.pdf',
                'file_extension' => 'pdf',
                'file_size' => 2097152,
                'status' => 'revision_required',
                'submitted_at' => $now->copy()->subDays(12),
                'reviewed_at' => $now->copy()->subDays(10),
                'review_notes' => 'يحتاج التقرير لتحسين قسم الأهداف وإضافة مخطط زمني للمهام.',
            ],
            // هدى - تقرير أولي
            [
                'internship_index' => 3, 'student_index' => 3,
                'report_type' => 'initial',
                'title' => 'التقرير الأولي - تدريب تطوير تطبيقات الموبايل',
                'file_name' => 'تقرير_أولي_هدى_العبيدي.pdf',
                'file_extension' => 'pdf',
                'file_size' => 2621440,
                'status' => 'approved',
                'submitted_at' => $now->copy()->subDays(18),
                'reviewed_at' => $now->copy()->subDays(16),
                'review_notes' => 'تقرير ممتاز ومفصل. يوضح تقدماً ملحوظاً في المهام المطلوبة.',
            ],
            // هدى - تقرير نصفي
            [
                'internship_index' => 3, 'student_index' => 3,
                'report_type' => 'midterm',
                'title' => 'التقرير النصفي - تدريب تطوير تطبيقات الموبايل',
                'file_name' => 'تقرير_نصفي_هدى_العبيدي.pdf',
                'file_extension' => 'pdf',
                'file_size' => 3670016,
                'status' => 'submitted',
                'submitted_at' => $now->copy()->subDays(2),
                'reviewed_at' => null,
                'review_notes' => null,
            ],
        ];

        foreach ($reportsData as $rd) {
            Report::query()->firstOrCreate(
                [
                    'internship_id' => $internships[$rd['internship_index']]->id,
                    'report_type' => $rd['report_type'],
                ],
                [
                    'student_id' => $students[$rd['student_index']]->id,
                    'title' => $rd['title'],
                    'file_path' => 'reports/' . $rd['file_name'],
                    'file_name' => $rd['file_name'],
                    'file_extension' => $rd['file_extension'],
                    'file_size' => $rd['file_size'],
                    'status' => $rd['status'],
                    'submitted_at' => $rd['submitted_at'],
                    'reviewed_at' => $rd['reviewed_at'],
                    'review_notes' => $rd['review_notes'],
                ]
            );
        }

        // ════════════════════════════════════════════════════════════════
        //  11. EXAMINER DISCUSSIONS
        // ════════════════════════════════════════════════════════════════

        $discussionsData = [
            [
                'internship_index' => 0, 'student_index' => 0, 'examiner_index' => 0,
                'scheduled_at' => $now->copy()->addDays(14)->setHour(10)->setMinute(0),
                'location' => 'قاعة المناقشات - كلية الهندسة، جامعة طرابلس',
                'status' => 'scheduled',
                'notes' => 'مناقشة التقرير النصفي لمشروع إدارة البيانات النفطية.',
            ],
            [
                'internship_index' => 1, 'student_index' => 1, 'examiner_index' => 1,
                'scheduled_at' => $now->copy()->addDays(21)->setHour(11)->setMinute(0),
                'location' => 'قاعة 3 - كلية الهندسة، جامعة طرابلس',
                'status' => 'scheduled',
                'notes' => 'مناقشة التقدم في تدريب هندسة الشبكات.',
            ],
            [
                'internship_index' => 3, 'student_index' => 3, 'examiner_index' => 2,
                'scheduled_at' => $now->copy()->addDays(7)->setHour(9)->setMinute(30),
                'location' => 'مختبر الحاسوب - كلية تقنية المعلومات، جامعة طرابلس',
                'status' => 'scheduled',
                'notes' => 'مناقشة منتصف الفترة لمشروع تطوير تطبيقات الموبايل.',
            ],
        ];

        $discussions = [];

        foreach ($discussionsData as $dd) {
            $discussion = ExaminerDiscussion::query()->firstOrCreate(
                [
                    'internship_id' => $internships[$dd['internship_index']]->id,
                    'examiner_id' => $examiners[$dd['examiner_index']]->id,
                ],
                [
                    'student_id' => $students[$dd['student_index']]->id,
                    'scheduled_at' => $dd['scheduled_at'],
                    'location' => $dd['location'],
                    'status' => $dd['status'],
                    'is_urgent' => false,
                    'notes' => $dd['notes'],
                ]
            );
            $discussions[] = $discussion;
        }

        // ════════════════════════════════════════════════════════════════
        //  12. NOTIFICATIONS
        // ════════════════════════════════════════════════════════════════

        $notificationsData = [
            // Student notifications
            ['user_index' => 'student_0', 'title' => 'تم قبول طلبك', 'body' => 'تهانينا! تم قبول طلب التدريب الخاص بك في شركة الواحة للنفط.', 'type' => 'application', 'is_read' => true, 'days_ago' => 10],
            ['user_index' => 'student_0', 'title' => 'بداية التدريب', 'body' => 'تدريبك في شركة الواحة للنفط يبدأ يوم الأحد القادم. لا تنسَ إحضار بطاقتك الجامعية.', 'type' => 'internship', 'is_read' => true, 'days_ago' => 8],
            ['user_index' => 'student_0', 'title' => 'تم مراجعة تقريرك', 'body' => 'تمت مراجعة التقرير الأولي الخاص بك والموافقة عليه. أحسنت!', 'type' => 'report', 'is_read' => true, 'days_ago' => 18],
            ['user_index' => 'student_0', 'title' => 'موعد مناقشة', 'body' => 'تم تحديد موعد مناقشة التقرير النصفي مع د. عبدالرحمن بوزيد.', 'type' => 'discussion', 'is_read' => false, 'days_ago' => 1],

            ['user_index' => 'student_1', 'title' => 'تم قبول طلبك', 'body' => 'تهانينا! تم قبول طلب التدريب الخاص بك في شركة ليبيانا.', 'type' => 'application', 'is_read' => true, 'days_ago' => 8],
            ['user_index' => 'student_1', 'title' => 'رسالة جديدة', 'body' => 'لديك رسالة جديدة من المشرف يوسف المبروك.', 'type' => 'chat', 'is_read' => true, 'days_ago' => 2],
            ['user_index' => 'student_1', 'title' => 'تم مراجعة تقريرك', 'body' => 'تمت مراجعة التقرير الأولي والموافقة عليه مع بعض الملاحظات.', 'type' => 'report', 'is_read' => false, 'days_ago' => 13],

            ['user_index' => 'student_2', 'title' => 'تم قبول طلبك', 'body' => 'تهانينا! تم قبول طلب التدريب الخاص بك في الشركة العامة للكهرباء.', 'type' => 'application', 'is_read' => true, 'days_ago' => 7],
            ['user_index' => 'student_2', 'title' => 'ملاحظات على التقرير', 'body' => 'يحتاج تقريرك الأولي لبعض التعديلات. يرجى مراجعة الملاحظات.', 'type' => 'report', 'is_read' => false, 'days_ago' => 10],

            ['user_index' => 'student_3', 'title' => 'تم قبول طلبك', 'body' => 'تهانينا! تم قبول طلب التدريب الخاص بك في شركة ليبيانا.', 'type' => 'application', 'is_read' => true, 'days_ago' => 9],
            ['user_index' => 'student_3', 'title' => 'تم مراجعة تقريرك', 'body' => 'تمت مراجعة التقرير الأولي والموافقة عليه. عمل ممتاز!', 'type' => 'report', 'is_read' => true, 'days_ago' => 16],
            ['user_index' => 'student_3', 'title' => 'موعد مناقشة', 'body' => 'تم تحديد موعد مناقشة منتصف الفترة مع د. محمد العريبي.', 'type' => 'discussion', 'is_read' => false, 'days_ago' => 1],

            ['user_index' => 'student_4', 'title' => 'حالة الطلب', 'body' => 'للأسف، لم يتم قبول طلبك في شركة ليبيانا بسبب اكتمال المقاعد.', 'type' => 'application', 'is_read' => true, 'days_ago' => 5],
            ['user_index' => 'student_4', 'title' => 'طلب قيد المراجعة', 'body' => 'طلبك في شركة المدار الجديد قيد المراجعة. سنوافيك بالنتيجة قريباً.', 'type' => 'application', 'is_read' => false, 'days_ago' => 2],

            ['user_index' => 'student_5', 'title' => 'حالة الطلب', 'body' => 'للأسف، لم يتم قبول طلبك في الشركة العامة للكهرباء.', 'type' => 'application', 'is_read' => true, 'days_ago' => 4],
            ['user_index' => 'student_5', 'title' => 'طلب قيد المراجعة', 'body' => 'طلبك في شركة الواحة للنفط قيد المراجعة.', 'type' => 'application', 'is_read' => false, 'days_ago' => 1],

            // Examiner notifications
            ['user_index' => 'examiner_0', 'title' => 'مناقشة مجدولة', 'body' => 'تم تحديد موعد مناقشة مع الطالب علي الساعدي.', 'type' => 'discussion', 'is_read' => false, 'days_ago' => 1],
            ['user_index' => 'examiner_1', 'title' => 'مناقشة مجدولة', 'body' => 'تم تحديد موعد مناقشة مع الطالبة مريم الكيلاني.', 'type' => 'discussion', 'is_read' => false, 'days_ago' => 1],
            ['user_index' => 'examiner_2', 'title' => 'مناقشة مجدولة', 'body' => 'تم تحديد موعد مناقشة مع الطالبة هدى العبيدي.', 'type' => 'discussion', 'is_read' => false, 'days_ago' => 1],

            // Admin notifications
            ['user_index' => 'admin_ops', 'title' => 'طلبات جديدة', 'body' => 'هناك 2 طلبات تدريب جديدة بانتظار المراجعة.', 'type' => 'system', 'is_read' => false, 'days_ago' => 2],
            ['user_index' => 'admin_ops', 'title' => 'تقارير جديدة', 'body' => 'تم رفع تقريرين جديدين بانتظار المراجعة.', 'type' => 'system', 'is_read' => false, 'days_ago' => 3],
        ];

        $userMap = [
            'student_0' => $students[0],
            'student_1' => $students[1],
            'student_2' => $students[2],
            'student_3' => $students[3],
            'student_4' => $students[4],
            'student_5' => $students[5],
            'examiner_0' => $examiners[0],
            'examiner_1' => $examiners[1],
            'examiner_2' => $examiners[2],
            'admin_ops' => $operationsAdmin,
        ];

        foreach ($notificationsData as $nd) {
            $user = $userMap[$nd['user_index']];
            $createdAt = $now->copy()->subDays($nd['days_ago']);

            UserNotification::query()->firstOrCreate(
                [
                    'user_id' => $user->id,
                    'title' => $nd['title'],
                    'body' => $nd['body'],
                ],
                [
                    'type' => $nd['type'],
                    'is_read' => $nd['is_read'],
                    'read_at' => $nd['is_read'] ? $createdAt->copy()->addHours(2) : null,
                    'created_at' => $createdAt,
                    'updated_at' => $createdAt,
                ]
            );
        }

        $this->command->info('✅ تم إضافة البيانات التجريبية بنجاح!');
        $this->command->info('   - 3 مدراء نظام (عمليات، محتوى، دعم فني)');
        $this->command->info('   - 3 ممتحنين');
        $this->command->info('   - 8 شركات ليبية مع صور');
        $this->command->info('   - 8 مشرفين (مشرف لكل شركة)');
        $this->command->info('   - 6 طلاب مع ملفاتهم الشخصية');
        $this->command->info('   - 12 فرصة تدريب');
        $this->command->info('   - 8 طلبات تقديم');
        $this->command->info('   - 4 تدريبات نشطة');
        $this->command->info('   - 4 محادثات مع رسائل');
        $this->command->info('   - 6 تقارير');
        $this->command->info('   - 3 مناقشات مجدولة');
        $this->command->info('   - 21 إشعار');
        $this->command->newLine();
        $this->command->info('🔑 كلمة المرور لجميع الحسابات: Password@123');
    }

    /**
     * Copy company logo from Flutter assets to Laravel storage.
     */
    private function copyCompanyLogo(string $assetFileName, string $storagePath): void
    {
        $flutterAssetsPath = base_path('../Waslaa/assets/images/' . $assetFileName);
        $storageDir = storage_path('app/public/' . dirname($storagePath));
        $storageDest = storage_path('app/public/' . $storagePath);

        if (! file_exists($storageDir)) {
            mkdir($storageDir, 0755, true);
        }

        if (file_exists($flutterAssetsPath) && ! file_exists($storageDest)) {
            copy($flutterAssetsPath, $storageDest);
        }
    }
}
