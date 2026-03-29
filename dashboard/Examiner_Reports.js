document.addEventListener('DOMContentLoaded', () => {
    loadExaminerReports();
});

async function loadExaminerReports() {
    const grid = document.getElementById('reportsGrid');
    grid.innerHTML = '<p style="text-align:center; color:#aaa; padding:40px; grid-column:1/-1;">جاري التحميل...</p>';

    try {
        const user = getUser();
        const result = await apiGet(`/examiners/${user?.id}/reports`);
        if (!result || !result.data) return;

        grid.innerHTML = '';
        if (result.data.length === 0) {
            grid.innerHTML = '<p style="text-align:center; color:#aaa; padding:40px; grid-column:1/-1;">لا توجد تقارير حالياً</p>';
            return;
        }

        result.data.forEach((r, index) => {
            const card = document.createElement('div');
            card.className = 'compact-card card-animate';
            card.style.animationDelay = `${index * 0.1}s`;

            card.innerHTML = `
                <div class="card-top">
                    <div class="student-avatar"><i class="ri-user-received-2-line"></i></div>
                    <div class="student-info">
                        <h3>${r.student_name || '--'}</h3>
                        <span>رقم القيد: ${r.student_number || '--'}</span>
                    </div>
                </div>
                <div class="report-item">
                    <div class="report-meta">
                        <i class="ri-file-text-line" style="color: #6A5AE0;"></i>
                        <div class="report-details">
                            <p>${r.title || r.report_type || 'تقرير'}</p>
                            <small>تم الاستلام: ${r.submitted_at || '--'}</small>
                        </div>
                    </div>
                    ${r.download_url
                        ? `<a href="${r.download_url}" target="_blank" class="btn-dl" title="تحميل"><i class="ri-download-2-line"></i></a>`
                        : `<button class="btn-dl" disabled><i class="ri-download-2-line"></i></button>`
                    }
                </div>
            `;
            grid.appendChild(card);
        });
    } catch (e) {
        grid.innerHTML = '<p style="text-align:center; color:red; grid-column:1/-1;">حدث خطأ في تحميل البيانات</p>';
    }
}
