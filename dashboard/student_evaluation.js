document.addEventListener('DOMContentLoaded', () => {
    loadEvaluations();
    setupSearch();
});

async function loadEvaluations() {
    const grid = document.getElementById('resultsGrid');
    grid.innerHTML = '<p style="text-align:center; color:#aaa; padding:40px; grid-column:1/-1;">جاري التحميل...</p>';

    try {
        const result = await apiGet('/student-evaluations');
        if (!result || !result.data) return;

        grid.innerHTML = '';
        result.data.forEach((item, index) => {
            const companyPct = item.company_score > 0 ? Math.round((item.company_score / 30) * 100) : 0;
            const examinerPct = item.examiner_score > 0 ? Math.round((item.examiner_score / 70) * 100) : 0;
            const initials = (item.student.name || '').charAt(0);

            const card = document.createElement('div');
            card.className = 'student-card animate-in';
            card.style.animationDelay = `${index * 0.1}s`;
            card.innerHTML = `
                <div class="card-main">
                    <div class="student-info">
                        <div class="avatar">${initials}</div>
                        <div>
                            <h3>${item.student.name}</h3>
                            <span>رقم القيد: ${item.student.student_number || '--'}</span>
                        </div>
                    </div>
                    <div class="company-info">
                        <i class="ri-building-line"></i>
                        <span>${item.company.name}</span>
                    </div>
                </div>
                <div class="card-stats">
                    <div class="stat-item">
                        <small>الشركة (30%)</small>
                        <div class="progress-bar"><div class="fill orange" style="width: ${companyPct}%;"></div></div>
                        <strong>${item.company_weighted}</strong>
                    </div>
                    <div class="stat-item">
                        <small>الممتحن (70%)</small>
                        <div class="progress-bar"><div class="fill green" style="width: ${examinerPct}%;"></div></div>
                        <strong>${item.examiner_weighted}</strong>
                    </div>
                </div>
                <div class="card-footer">
                    <div class="final-score">
                        <span class="label">المعدل النهائي</span>
                        <span class="value">${item.final_percentage}%</span>
                    </div>
                </div>
            `;
            grid.appendChild(card);
        });

        if (result.data.length === 0) {
            grid.innerHTML = '<p style="text-align:center; color:#aaa; padding:40px; grid-column:1/-1;">لا توجد نتائج حالياً</p>';
        }
    } catch (e) {
        grid.innerHTML = '<p style="text-align:center; color:red; grid-column:1/-1;">حدث خطأ في تحميل البيانات</p>';
    }
}

function setupSearch() {
    const searchInput = document.getElementById('studentSearch');
    if (!searchInput) return;

    searchInput.addEventListener('keyup', () => {
        const term = searchInput.value.toLowerCase();
        const cards = document.querySelectorAll('.student-card');

        cards.forEach(card => {
            const name = card.querySelector('h3')?.innerText.toLowerCase() || '';
            const company = card.querySelector('.company-info span')?.innerText.toLowerCase() || '';

            card.style.display = (name.includes(term) || company.includes(term)) ? 'flex' : 'none';
        });
    });
}
