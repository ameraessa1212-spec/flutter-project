let selectedFileObj = null;
let selectedTargets = [];
let currentDept = 'all';

function previewImage(event) {
    const file = event.target.files[0];
    if (!file) return;

    selectedFileObj = file;
    const reader = new FileReader();
    reader.onload = function() {
        const output = document.getElementById('imagePreview');
        const text = document.getElementById('uploadText');
        output.src = reader.result;
        output.style.display = 'block';
        text.innerText = 'تم اختيار الصورة بنجاح';
    };
    reader.readAsDataURL(file);
}

function toggleTarget(target, element) {
    if (selectedTargets.includes(target)) {
        selectedTargets = selectedTargets.filter(t => t !== target);
        element.classList.remove('active');
    } else {
        selectedTargets.push(target);
        element.classList.add('active');
    }
}

function filterDept(dept, element) {
    currentDept = dept;
    const parent = element.parentElement;
    parent.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
    element.classList.add('active');
}

async function sendToSelected() {
    if (!selectedFileObj) {
        alert('من فضلك قم برفع صورة الجدول أولاً');
        return;
    }

    if (selectedTargets.length === 0) {
        alert('من فضلك حدد المستلمين (الممتحنين أو الطلاب أو كلاهما)');
        return;
    }

    const userMessage = document.getElementById('messageInput').value;

    const formData = new FormData();
    formData.append('image', selectedFileObj);
    selectedTargets.forEach(t => formData.append('targets[]', t));
    formData.append('specialization_filter', currentDept);
    if (userMessage) formData.append('message', userMessage);

    try {
        const result = await apiPost('/discussion-schedules', formData);
        if (result) {
            alert(result.message || 'تم الإرسال بنجاح');
        }
    } catch (e) {
        alert('حدث خطأ في الإرسال');
    }
}
