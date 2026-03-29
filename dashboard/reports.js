document.addEventListener('DOMContentLoaded', () => {
    const grid = document.getElementById('reportsGrid');
    const students = [
        { name: "هدية بلقاسم", id: "2024101", date: "2024/05/12" },
        { name: "أحمد المصراتي", id: "2024102", date: "2024/05/14" },
        { name: "سارة محمود", id: "2024103", date: "2024/05/15" },
        { name: "يوسف علي", id: "2024104", date: "2024/05/16" },
        { name: "ريهام محمد", id: "2024105", date: "2024/05/18" },
        { name: "محمد العبيدي", id: "2024106", date: "2024/05/20" }
    ];

    students.forEach((s, index) => {
        const card = document.createElement('div');
        card.className = 'compact-card card-animate';
        card.style.animationDelay = `${index * 0.1}s`;
        card.innerHTML = `
            <div class="card-top">
                <div class="student-avatar"><i class="ri-user-received-2-line"></i></div>
                <div class="student-info">
                    <h3>${s.name}</h3>
                    <span>رقم القيد: ${s.id}</span>
                </div>
            </div>
            <div class="report-item">
                <div class="report-meta">
                    <i class="ri-microscope-line sc-color"></i>
                    <div class="report-details"><p>البحث العلمي</p><small>استلم: ${s.date}</small></div>
                </div>
                <button class="btn-dl" title="تحميل"><i class="ri-download-2-line"></i></button>
            </div>
            <div class="report-item">
                <div class="report-meta">
                    <i class="ri-building-line fi-color"></i>
                    <div class="report-details"><p>التدريب الميداني</p><small>استلم: ${s.date}</small></div>
                </div>
                <button class="btn-dl" title="تحميل"><i class="ri-download-2-line"></i></button>
            </div>
            <button class="notify-btn" onclick="sendNotification(this)">
                <i class="ri-send-plane-fill"></i><span>إبلاغ الطالب بالاستلام</span>
            </button>`;
        grid.appendChild(card);
    });
});

function sendNotification(btn) {
    btn.innerHTML = `<i class="ri-loader-4-line ri-spin"></i> <span>جاري الإرسال...</span>`;
    setTimeout(() => {
        btn.classList.add('sent');
        btn.innerHTML = `<i class="ri-checkbox-circle-fill"></i> <span>تم إبلاغ الطالب</span>`;
        btn.disabled = true;
    }, 1200);
}