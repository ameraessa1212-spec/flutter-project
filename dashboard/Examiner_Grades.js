let studentsData = [];

document.addEventListener('DOMContentLoaded', () => {
    loadExaminerStudents();

    const form = document.getElementById('evaluationForm');
    form.addEventListener('input', calculateTotal);
    form.onsubmit = submitGrade;
});

async function loadExaminerStudents() {
    const list = document.getElementById('studentsGradesList');
    list.innerHTML = '<tr><td colspan="4" style="text-align:center; color:#aaa; padding:20px;">جاري التحميل...</td></tr>';

    try {
        const result = await apiGet('/examiner/students');
        if (!result || !result.data) return;

        studentsData = result.data;
        list.innerHTML = '';

        studentsData.forEach(s => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td><strong>${s.student_name}</strong></td>
                <td>${s.student_number || '--'}</td>
                <td><span class="status-tag" id="status-${s.id}">${s.status}</span></td>
                <td><button class="eval-btn" onclick="openModal('${s.student_name}', '${s.id}')">رصد الدرجات</button></td>
            `;
            list.appendChild(row);
        });

        if (studentsData.length === 0) {
            list.innerHTML = '<tr><td colspan="4" style="text-align:center; color:#aaa;">لا يوجد طلاب مخصصين لك</td></tr>';
        }
    } catch (e) {
        list.innerHTML = '<tr><td colspan="4" style="text-align:center; color:red;">حدث خطأ في تحميل البيانات</td></tr>';
    }
}

function openModal(name, discussionId) {
    document.getElementById('modalStudentName').innerText = name;
    document.getElementById('modalStudentId').innerText = discussionId;
    const modal = document.getElementById('evaluationModal');
    modal.style.display = 'flex';
    document.getElementById('evaluationForm').reset();
    document.getElementById('totalDisplay').innerText = '0';
}

function closeModal() {
    document.getElementById('evaluationModal').style.display = 'none';
}

function calculateTotal() {
    const inputs = document.querySelectorAll('#evaluationForm input[type="number"]');
    let total = 0;
    inputs.forEach(input => { total += Number(input.value) || 0; });
    document.getElementById('totalDisplay').innerText = total;
}

async function submitGrade(e) {
    e.preventDefault();
    const discussionId = document.getElementById('modalStudentId').innerText;
    const totalScore = Number(document.getElementById('totalDisplay').innerText);

    const inputs = document.querySelectorAll('#evaluationForm input[type="number"]');
    const rubricScores = {};
    inputs.forEach(input => { rubricScores[input.name || input.id] = Number(input.value) || 0; });

    try {
        const result = await apiPost('/examiner/grades', {
            examiner_discussion_id: Number(discussionId),
            rubric_scores: rubricScores,
            total_score: totalScore,
        });

        if (result) {
            const statusTag = document.getElementById(`status-${discussionId}`);
            if (statusTag) statusTag.innerText = `تم التقييم (${totalScore}/70)`;
            alert(result.message || `تم الحفظ بنجاح: ${totalScore}/70`);
            closeModal();
        }
    } catch (err) {
        alert('حدث خطأ في حفظ التقييم');
    }
}
