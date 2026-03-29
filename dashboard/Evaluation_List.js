let studentsData = [];

document.addEventListener('DOMContentLoaded', () => {
    loadEvaluationList();
});

async function loadEvaluationList() {
    try {
        const result = await apiGet('/evaluation-list');
        if (result && result.data) {
            studentsData = result.data;
            renderStudents(studentsData);
        }
    } catch (e) {
        console.error('Failed to load evaluation list:', e);
    }
}

function renderStudents(data) {
    const grid = document.getElementById('studentsGrid');
    grid.innerHTML = '';

    if (data.length === 0) {
        grid.innerHTML = '<p style="text-align:center; grid-column:1/-1; padding:20px; color:#777;">لا يوجد طلاب حالياً.</p>';
        return;
    }

    grid.innerHTML = data.map((s, index) => `
        <div class="student-card" style="animation: fadeInUp 0.5s ease forwards; animation-delay: ${index * 0.1}s">
            <h3 style="margin:0; font-size:20px; color:#2d3436;">${s.student_name}</h3>
            <p style="color:#777; font-size:14px; margin:10px 0;">رقم القيد: ${s.student_number || '--'}</p>
            <div style="background:#f0eeff; color:#6A5AE0; padding:5px 15px; border-radius:10px; font-size:12px; font-weight:800; display:inline-block;">${s.specialization || '--'}</div>
            <button class="btn-view" onclick="openEvaluation('${s.student_name}', '${s.student_number || ''}', '${s.company_name || ''}')">
                عرض النتيجة <i class="ri-arrow-left-s-line"></i>
            </button>
        </div>
    `).join('');
}

function filterStudents() {
    const selectedValue = document.getElementById('majorFilter').value;
    let filtered;
    if (selectedValue === 'الكل') {
        filtered = studentsData;
    } else {
        filtered = studentsData.filter(s => (s.specialization || '').includes(selectedValue));
    }
    renderStudents(filtered);
}

function openEvaluation(name, id, company) {
    document.getElementById('listView').classList.remove('active');
    document.getElementById('evaluationView').classList.add('active');

    document.getElementById('stName').innerText = name;
    document.getElementById('stID').innerText = id;
    document.getElementById('stCompany').innerText = company;

    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function showList() {
    document.getElementById('evaluationView').classList.remove('active');
    document.getElementById('listView').classList.add('active');
}

async function sendToExaminer(btn) {
    const originalText = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = `<i class="ri-loader-4-line ri-spin"></i> جاري الإرسال...`;

    // Collect student IDs from the current view (you'd need examiner selection UI)
    const studentIds = studentsData.map(s => s.student_id);
    const examinerSelect = document.getElementById('examinerSelect');
    const examinerId = examinerSelect ? examinerSelect.value : null;

    if (!examinerId) {
        alert('يرجى اختيار الممتحن');
        btn.disabled = false;
        btn.innerHTML = originalText;
        return;
    }

    try {
        const result = await apiPost('/evaluation-list/send-to-examiner', {
            student_ids: studentIds,
            examiner_id: Number(examinerId),
        });

        if (result) {
            btn.style.background = '#2ecc71';
            btn.innerHTML = `<i class="ri-check-double-line"></i> تم الإرسال بنجاح`;
            alert(result.message || 'تم الإرسال بنجاح');
        }
    } catch (err) {
        alert('حدث خطأ في الإرسال');
    }

    setTimeout(() => {
        btn.disabled = false;
        btn.style.background = '#2d3436';
        btn.innerHTML = originalText;
    }, 3000);
}
