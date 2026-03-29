let selectedFile = null;
let selectedTargets = []; 
let currentDept = 'all';

function previewImage(event) {
    const file = event.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = function() {
        const output = document.getElementById('imagePreview');
        const text = document.getElementById('uploadText');
        output.src = reader.result;
        output.style.display = 'block';
        text.innerText = "تم اختيار الصورة بنجاح ✅";
        selectedFile = reader.result;
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

function sendToSelected() {
    if (!selectedFile) {
        alert("من فضلك قم برفع صورة الجدول أولاً");
        return;
    }

    if (selectedTargets.length === 0) {
        alert("من فضلك حدد المستلمين (الممتحنين أو الطلاب أو كلاهما)");
        return;
    }

    // الحصول على نص التعليق/الرسالة
    const userMessage = document.getElementById('messageInput').value;

    const targetNames = selectedTargets.map(t => (t === 'examiners' ? "الممتحنين" : "الطلاب")).join(" و ");
    
    const deptName = {
        'all': 'جميع التخصصات',
        'computer': 'حاسب آلي',
        'control': 'تحكم',
        'telecom': 'اتصالات'
    }[currentDept];

    // عرض الرسالة في التنبيه (سيتم إرسالها للباك إند لاحقاً)
    alert(`جاري الإرسال...
جهة الإرسال: ${targetNames}
التخصص: ${deptName}
الرسالة المرفقة: ${userMessage || "لا يوجد تعليق"}
تم إرفاق ملف الجدول بنجاح.`);
}