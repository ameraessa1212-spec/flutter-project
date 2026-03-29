document.addEventListener('DOMContentLoaded', () => {
    const grid = document.getElementById('reportsGrid');
    
    // بيانات الطلاب (يمكن استبدالها ببيانات من قاعدة البيانات لاحقاً)
    const students = [
        { name: "هدية بلقاسم", id: "2024101", date: "2024/05/12" },
        { name: "أحمد المصراتي", id: "2024102", date: "2024/05/14" },
        { name: "سارة محمود", id: "2024103", date: "2024/05/15" },
        { name: "يوسف علي", id: "2024104", date: "2024/05/16" }
    ];

    // تفريغ المحتوى الحالي قبل الإضافة لضمان عدم التكرار
    grid.innerHTML = '';

    students.forEach((s, index) => {
        const card = document.createElement('div');
        card.className = 'compact-card card-animate';
        
        // توزيع توقيت الحركة (Delay) ليعطي طابعاً متسلسلاً وناعماً
        card.style.animationDelay = `${index * 0.1}s`;
        
        card.innerHTML = `
            <div class="card-top">
                <div class="student-avatar">
                    <i class="ri-user-received-2-line"></i>
                </div>
                <div class="student-info">
                    <h3>${s.name}</h3>
                    <span>رقم القيد: ${s.id}</span>
                </div>
            </div>

            <div class="report-item">
                <div class="report-meta">
                    <i class="ri-microscope-line" style="color: #6A5AE0;"></i>
                    <div class="report-details">
                        <p>البحث العلمي</p>
                        <small>تم الاستلام: ${s.date}</small>
                    </div>
                </div>
                <button class="btn-dl" title="تحميل البحث العلمي">
                    <i class="ri-download-2-line"></i>
                </button>
            </div>

            <div class="report-item">
                <div class="report-meta">
                    <i class="ri-building-line" style="color: #FF9F43;"></i>
                    <div class="report-details">
                        <p>التدريب الميداني</p>
                        <small>تم الاستلام: ${s.date}</small>
                    </div>
                </div>
                <button class="btn-dl" title="تحميل تقرير التدريب">
                    <i class="ri-download-2-line"></i>
                </button>
            </div>
        `;
        
        grid.appendChild(card);
    });
});