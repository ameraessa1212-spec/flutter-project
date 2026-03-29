document.addEventListener('DOMContentLoaded', () => {
    loadReports();
});

async function loadReports() {
    const grid = document.getElementById('reportsGrid');
    grid.innerHTML = '<p style="text-align:center; color:#aaa; padding:40px; grid-column:1/-1;">جاري التحميل...</p>';

    try {
        const result = await apiGet('/student-reports');
        if (!result || !result.data) return;

        grid.innerHTML = '';
        result.data.forEach((r, index) => {
            const card = document.createElement('div');
            card.className = 'compact-card card-animate';
            card.style.animationDelay = `${index * 0.1}s`;

            const date = r.submitted_at ? new Date(r.submitted_at).toLocaleDateString('ar-LY') : '--';
            const downloadBtn = r.download_url
                ? `<a href="${r.download_url}" target="_blank" class="btn-dl" title="تحميل"><i class="ri-download-2-line"></i></a>`
                : `<button class="btn-dl" disabled title="لا يوجد ملف"><i class="ri-download-2-line"></i></button>`;

            card.innerHTML = `
                <div class="card-top">
                    <div class="student-avatar"><i class="ri-user-received-2-line"></i></div>
                    <div class="student-info">
                        <h3>${r.student?.name || '--'}</h3>
                        <span>رقم القيد: ${r.student?.student_number || '--'}</span>
                    </div>
                </div>
                <div class="report-item">
                    <div class="report-meta">
                        <i class="ri-file-text-line sc-color"></i>
                        <div class="report-details">
                            <p>${r.title || r.report_type || 'تقرير'}</p>
                            <small>استلم: ${date}</small>
                        </div>
                    </div>
                    ${downloadBtn}
                </div>
                <button class="notify-btn" onclick="sendNotification(this, ${r.id})">
                    <i class="ri-send-plane-fill"></i><span>إبلاغ الطالب بالاستلام</span>
                </button>`;
            grid.appendChild(card);
        });

        if (result.data.length === 0) {
            grid.innerHTML = '<p style="text-align:center; color:#aaa; padding:40px; grid-column:1/-1;">لا توجد تقارير حالياً</p>';
        }
    } catch (e) {
        grid.innerHTML = '<p style="text-align:center; color:red; grid-column:1/-1;">حدث خطأ في تحميل البيانات</p>';
    }
}

async function sendNotification(btn, reportId) {
    btn.innerHTML = `<i class="ri-loader-4-line ri-spin"></i> <span>جاري الإرسال...</span>`;
    btn.disabled = true;

    try {
        await apiPost(`/student-reports/${reportId}/notify`, {});
        btn.classList.add('sent');
        btn.innerHTML = `<i class="ri-checkbox-circle-fill"></i> <span>تم إبلاغ الطالب</span>`;
    } catch (e) {
        btn.innerHTML = `<i class="ri-error-warning-line"></i> <span>فشل الإرسال</span>`;
        btn.disabled = false;
    }
}
