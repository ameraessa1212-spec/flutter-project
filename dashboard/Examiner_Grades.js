const students = [
    { name: "هدية بلقاسم", id: "2024101", status: "لم يتم التقييم" },
    { name: "أحمد المصراتي", id: "2024102", status: "لم يتم التقييم" },
    { name: "سارة محمود", id: "2024103", status: "لم يتم التقييم" },
    { name: "محمد عادل", id: "2024104", status: "لم يتم التقييم" },
    { name: "يوسف علي", id: "2024105", status: "لم يتم التقييم" },
    { name: "ريهام محمد", id: "2024106", status: "لم يتم التقييم" },
      
];

document.addEventListener('DOMContentLoaded', () => {
    const list = document.getElementById('studentsGradesList');
    students.forEach(s => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td><strong>${s.name}</strong></td>
            <td>${s.id}</td>
            <td><span class="status-tag" id="status-${s.id}">${s.status}</span></td>
            <td><button class="eval-btn" onclick="openModal('${s.name}', '${s.id}')">رصد الدرجات</button></td>
        `;
        list.appendChild(row);
    });

    const form = document.getElementById('evaluationForm');
    form.addEventListener('input', calculateTotal);
});

function openModal(name, id) {
    document.getElementById('modalStudentName').innerText = name;
    document.getElementById('modalStudentId').innerText = id;
    const modal = document.getElementById('evaluationModal');
    modal.style.display = 'flex'; // استخدام flex لضمان التوسيط
    document.getElementById('evaluationForm').reset();
    document.getElementById('totalDisplay').innerText = '0';
}

function closeModal() {
    document.getElementById('evaluationModal').style.display = 'none';
}

function calculateTotal() {
    const inputs = document.querySelectorAll('#evaluationForm input[type="number"]');
    let total = 0;
    inputs.forEach(input => {
        total += Number(input.value) || 0;
    });
    document.getElementById('totalDisplay').innerText = total;
}

document.getElementById('evaluationForm').onsubmit = (e) => {
    e.preventDefault();
    const studentId = document.getElementById('modalStudentId').innerText;
    const finalScore = document.getElementById('totalDisplay').innerText;
    const statusTag = document.getElementById(`status-${studentId}`);
    statusTag.innerText = `تم التقييم (${finalScore}/70)`;
    alert(`تم الحفظ بنجاح: ${finalScore}/70`);
    closeModal();
};