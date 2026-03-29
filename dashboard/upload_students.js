const dropZone = document.getElementById('dropZone');
const fileInput = document.getElementById('fileInput');
const previewPanel = document.getElementById('previewPanel');
const namesList = document.getElementById('namesList');
const cancelBtn = document.getElementById('cancelBtn');

dropZone.onclick = () => fileInput.click();

fileInput.onchange = (e) => {
    if (e.target.files.length > 0) {
        handlePreview();
    }
};

function handlePreview() {
    previewPanel.style.opacity = "1";
    previewPanel.style.pointerEvents = "all";
    
    // بيانات تجريبية تحتوي على الاسم ورقم القيد
    const mockData = [
        { name: "هدية بلقاسم", id: "125487" },
        { name: "أحمد المصراتي", id: "985632" },
        { name: "سارة محمود", id: "447852" },
        { name: "يوسف علي", id: "336985" },
        { name: "ريهام محمد", id: "778541" }
    ];
    
    namesList.innerHTML = '';

    mockData.forEach((student, i) => {
        setTimeout(() => {
            const div = document.createElement('div');
            div.className = 'name-card';
            // إعادة بناء محتوى الكرت ليشمل الاسم ورقم القيد بتنسيق HTML
            div.innerHTML = `
                <span class="student-name">${student.name}</span>
                <span class="student-id">رقم القيد: #${student.id}</span>
            `;
            namesList.appendChild(div);
        }, i * 150);
    });
}

cancelBtn.onclick = (e) => {
    e.stopPropagation();
    previewPanel.style.opacity = "0.4";
    previewPanel.style.pointerEvents = "none";
    namesList.innerHTML = '';
    fileInput.value = ''; 
};