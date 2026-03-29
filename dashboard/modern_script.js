document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    const specialtyFilter = document.getElementById('specialtyFilter');
    const cards = document.querySelectorAll('.student-glass-card');

    // وظيفة البحث والفلترة المحدثة
    function filterData() {
        const query = searchInput.value.toLowerCase().trim();
        const selectedSpecialty = specialtyFilter.value;

        cards.forEach(card => {
            // جلب الاسم والتأكد من تنظيف النص
            const name = card.querySelector('h3').innerText.toLowerCase().trim();
            
            // جلب رقم القيد واستخراج الأرقام فقط (لتجنب كلمة "رقم القيد:")
            const idFullText = card.querySelector('.student-id').innerText.toLowerCase();
            const idNumber = idFullText.replace(/[^0-9]/g, ''); 
            
            const cardSpecialty = card.dataset.specialty;

            // --- منطق البحث المطلوب ---
            // هل يبدأ الاسم بأول حرف/حروف من المدخلات؟
            const matchesName = name.startsWith(query);
            
            // هل يبدأ رقم القيد بأول رقمين/أرقام من المدخلات؟
            const matchesId = idNumber.startsWith(query);

            // فلتر التخصص (تأكدي من حذف الرمز > من HTML ليعمل)
            const matchesFilter = (selectedSpecialty === 'all' || selectedSpecialty === cardSpecialty);

            // تنفيذ الفلترة: يجب أن يطابق التخصص + (إما بداية الاسم أو بداية رقم القيد)
            if ((matchesName || matchesId) && matchesFilter) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }

    searchInput.addEventListener('input', filterData);
    specialtyFilter.addEventListener('change', filterData);

    // حساب المجموع تلقائياً عند فتح المودال (محدث ليعمل بنسبة 100)
    window.calculateTotal = function() {
        let total = 0;
        document.querySelectorAll('#evaluationForm input').forEach(input => {
            total += parseInt(input.value) || 0;
        });
        
        const display = document.getElementById('totalDisplay');
        if (display) {
            display.innerText = total;
            // تغيير لون الرقم إذا وصل للدرجة النهائية
            display.style.color = (total >= 50) ? '#22c55e' : '#ff4757';
        }
    };
});

// فتح المودال وتعبئة البيانات
function openEvaluation(name, id) {
    document.getElementById('modalStudentName').innerText = name;
    document.getElementById('modalStudentId').innerText = id;
    document.getElementById('evaluationModal').style.display = 'flex';
    
    // استدعاء الحساب فور الفتح
    if (typeof calculateTotal === 'function') {
        calculateTotal();
    }
}

function closeModal() {
    document.getElementById('evaluationModal').style.display = 'none';
}