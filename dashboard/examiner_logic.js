// تحميل الصفحة الرئيسية عند التشغيل
window.onload = () => {
    const homeMenu = document.querySelector('.menu-item');
    loadExaminerContent('home', homeMenu);
};

function loadExaminerContent(type, element) {
    const mainArea = document.getElementById('mainArea');
    
    // تحديث القائمة الجانبية
    document.querySelectorAll('.menu-item').forEach(item => item.classList.remove('active'));
    element.classList.add('active');

    mainArea.style.opacity = '0';

    setTimeout(() => {
        let htmlContent = '';

        switch (type) {
            case 'home':
                htmlContent = `
                    <div class="dashboard-wrapper animate-fade">
                        <div class="welcome-banner">
                            <div class="welcome-text">
                                <h1>أهلاً بك، د. علي حسين 👋</h1>
                                <p>لديك اليوم <b>4 مناقشات</b> مجدولة و <b>12 تقريراً</b> بانتظار التقييم.</p>
                            </div>
                            <div class="date-badge"><i class="ri-calendar-line"></i> السبت، 21 فبراير 2026</div>
                        </div>

                        <div class="stats-row">
                            <div class="mini-stat-card">
                                <div class="stat-icon-box purple"><i class="ri-group-line"></i></div>
                                <div class="stat-val"><h3>24</h3><p>طلاب تم تقييمهم</p></div>
                            </div>
                            <div class="mini-stat-card">
                                <div class="stat-icon-box orange"><i class="ri-file-warning-line"></i></div>
                                <div class="stat-val"><h3>12</h3><p>تقارير معلقة</p></div>
                            </div>
                            <div class="mini-stat-card">
                                <div class="stat-icon-box green"><i class="ri-medal-2-line"></i></div>
                                <div class="stat-val"><h3>88%</h3><p>متوسط الدرجات</p></div>
                            </div>
                        </div>

                        <div class="bottom-grid">
                            <div class="alerts-section">
                                <div class="section-title">تنبيهات هامة</div>
                                <div class="alert-box red"><strong>تقارير متأخرة</strong><p>3 طلاب تجاوزوا الموعد</p></div>
                                <div class="alert-box green"><strong>تقييمات الشركات</strong><p>تم استلام تقييم ليبيانا</p></div>
                            </div>

                            <div class="schedule-section">
                                <div class="section-header">
                                    <div class="section-title">جدول مناقشات اليوم</div>
                                    <button class="text-btn" onclick="toggleFullTable()">عرض الكل</button>
                                </div>
                                <table class="home-table">
                                    <thead><tr><th>الطالب</th><th>الوقت</th><th>القاعة</th><th>الحالة</th></tr></thead>
                                    <tbody>
                                        <tr><td>محمد الهاشمي</td><td>09:00 ص</td><td>قاعة 1</td><td><span class="badge now">جاري الآن</span></td></tr>
                                        <tr><td>سارة الفيتوري</td><td>10:30 ص</td><td>قاعة 4</td><td><span class="badge wait">بانتظار</span></td></tr>
                                        <tr class="extra-row"><td>أحمد الورفلي</td><td>12:00 م</td><td>قاعة 1</td><td><span class="badge wait">بانتظار</span></td></tr>
                                        <tr class="extra-row"><td>خالد محمود</td><td>01:30 م</td><td>قاعة 2</td><td><span class="badge wait">بانتظار</span></td></tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>`;
                break;

            case 'reports':
                htmlContent = `<iframe src="Examiner_Reports.html" class="full-frame animate-fade"></iframe>`;
                break;
            case 'grades':
                htmlContent = `<iframe src="Examiner_Grades.html" class="full-frame animate-fade"></iframe>`;
                break;
           // داخل ملف examiner_logic.js ابحث عن switch (type) وحدث حالة schedule

            case 'schedule':
                // نقوم باستدعاء صفحة الجدول داخل iframe للحفاظ على تنسيقها ووظائفها الأصلية
                htmlContent = `
                    <div class="dashboard-wrapper animate-fade" style="height: 100%;">
                        <iframe 
                            src="Discussion_Schedule.html" 
                            style="width: 100%; height: 85vh; border: none; border-radius: 25px; box-shadow: 0 10px 30px rgba(0,0,0,0.05);"
                            title="جدول المناقشات">
                        </iframe>
                    </div>`;
                break;
        }

        mainArea.innerHTML = htmlContent;
        mainArea.style.opacity = '1';
    }, 200);
}

// وظيفة زر عرض الكل
function toggleFullTable() {
    const extraRows = document.querySelectorAll('.extra-row');
    const btn = document.querySelector('.text-btn');
    const isHidden = extraRows[0].style.display === '' || extraRows[0].style.display === 'none';

    extraRows.forEach(row => row.style.display = isHidden ? 'table-row' : 'none');
    btn.innerText = isHidden ? 'عرض أقل' : 'عرض الكل';
}