document.addEventListener('DOMContentLoaded', function() {
    loadEvaluationResults();

    const searchInput = document.getElementById('searchInput');
    const specialtyFilter = document.getElementById('specialtyFilter');

    if (searchInput) searchInput.addEventListener('input', filterData);
    if (specialtyFilter) specialtyFilter.addEventListener('change', filterData);

    window.calculateTotal = function() {
        let total = 0;
        document.querySelectorAll('#evaluationForm input').forEach(input => {
            total += parseInt(input.value) || 0;
        });

        const display = document.getElementById('totalDisplay');
        if (display) {
            display.innerText = total;
            display.style.color = (total >= 50) ? '#22c55e' : '#ff4757';
        }
    };
});

async function loadEvaluationResults() {
    const container = document.getElementById('studentsGrid');
    if (!container) return;

    try {
        const result = await apiGet('/evaluation-results');
        if (!result || !result.data || result.data.length === 0) {
            container.innerHTML = '<p style="text-align:center; color:#aaa; padding:40px;">لا توجد نتائج حالياً</p>';
            return;
        }

        container.innerHTML = result.data.map(ev => `
            <div class="student-glass-card" data-specialty="${ev.specialization || ''}" onclick="openEvaluation('${ev.student_name}', '${ev.student_number || ''}')">
                <h3>${ev.student_name}</h3>
                <p class="student-id">رقم القيد: ${ev.student_number || '--'}</p>
                <span class="specialty-badge">${ev.specialization || '--'}</span>
                <div class="score-badge">${ev.total_score}/70</div>
            </div>
        `).join('');
    } catch (e) {
        if (container) container.innerHTML = '<p style="text-align:center; color:red;">حدث خطأ في التحميل</p>';
    }
}

function filterData() {
    const query = (document.getElementById('searchInput')?.value || '').toLowerCase().trim();
    const selectedSpecialty = document.getElementById('specialtyFilter')?.value || 'all';
    const cards = document.querySelectorAll('.student-glass-card');

    cards.forEach(card => {
        const name = card.querySelector('h3')?.innerText.toLowerCase().trim() || '';
        const idText = card.querySelector('.student-id')?.innerText || '';
        const idNumber = idText.replace(/[^0-9]/g, '');
        const cardSpecialty = card.dataset.specialty;

        const matchesName = name.startsWith(query);
        const matchesId = idNumber.startsWith(query);
        const matchesFilter = (selectedSpecialty === 'all' || selectedSpecialty === cardSpecialty);

        card.style.display = ((matchesName || matchesId) && matchesFilter) ? 'block' : 'none';
    });
}

function openEvaluation(name, id) {
    document.getElementById('modalStudentName').innerText = name;
    document.getElementById('modalStudentId').innerText = id;
    document.getElementById('evaluationModal').style.display = 'flex';

    if (typeof calculateTotal === 'function') calculateTotal();
}

function closeModal() {
    document.getElementById('evaluationModal').style.display = 'none';
}
