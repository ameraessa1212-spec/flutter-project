const dropZone = document.getElementById('dropZone');
const fileInput = document.getElementById('fileInput');
const previewPanel = document.getElementById('previewPanel');
const namesList = document.getElementById('namesList');
const cancelBtn = document.getElementById('cancelBtn');

dropZone.onclick = () => fileInput.click();

fileInput.onchange = (e) => {
    if (e.target.files.length > 0) {
        handleUpload(e.target.files[0]);
    }
};

async function handleUpload(file) {
    previewPanel.style.opacity = '1';
    previewPanel.style.pointerEvents = 'all';
    namesList.innerHTML = '<p style="text-align:center; color:#aaa;">جاري رفع الملف...</p>';

    try {
        const formData = new FormData();
        formData.append('file', file);

        const result = await apiPost('/students/upload', formData);

        if (result) {
            namesList.innerHTML = `
                <div style="text-align:center; padding:20px;">
                    <p style="color:#22c55e; font-weight:700; font-size:1.1em;">✅ ${result.message}</p>
                    <div style="margin-top:10px; color:#666;">
                        <span>تم إنشاء: <strong>${result.data.created}</strong></span> •
                        <span>تم تخطي: <strong>${result.data.skipped}</strong></span> •
                        <span>الإجمالي: <strong>${result.data.total}</strong></span>
                    </div>
                </div>
            `;
        }
    } catch (error) {
        const msg = error.data?.message || 'حدث خطأ في رفع الملف';
        namesList.innerHTML = `<p style="text-align:center; color:red;">${msg}</p>`;
    }
}

cancelBtn.onclick = (e) => {
    e.stopPropagation();
    previewPanel.style.opacity = '0.4';
    previewPanel.style.pointerEvents = 'none';
    namesList.innerHTML = '';
    fileInput.value = '';
};
