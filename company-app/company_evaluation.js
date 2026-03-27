document.addEventListener('DOMContentLoaded', () => {
    const inputs = document.querySelectorAll('.grade-input');
    const totalDisplay = document.getElementById('totalScore');

    // وظيفة لحساب المجموع
    const calculateTotal = () => {
        let total = 0;
        inputs.forEach(input => {
            total += parseFloat(input.value) || 0;
        });
        totalDisplay.innerText = Math.round(total);
    };

    // إضافة مستمع للأحداث لكل حقل إدخال
    inputs.forEach(input => {
        input.addEventListener('input', (e) => {
            const max = parseFloat(e.target.dataset.max);
            let val = parseFloat(e.target.value);

            // التحقق من صحة القيمة (لا تزيد عن النهاية العظمى)
            if (val > max) {
                alert(`القيمة العظمى لهذا البند هي ${max}`);
                e.target.value = max;
            }
            if (val < 0) e.target.value = 0;

            calculateTotal();
        });
    });
});

// وظيفة الإرسال
function submitEvaluation() {
    const stName = document.getElementById('stName').value;
    const total = document.getElementById('totalScore').innerText;

    if (!stName) {
        alert("الرجاء إدخال اسم الطالب");
        return;
    }

    if (confirm(`هل أنت متأكد من اعتماد نتيجة الطالب ${stName} بمجموع ${total}؟`)) {
        alert("تم إرسال التقييم بنجاح إلى قسم التدريب بالكلية.");
        // هنا يمكن إضافة الكود الخاص بربط قاعدة البيانات
    }
}