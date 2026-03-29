// --- 1. البحث الفوري (من أول حرف) ---
document.getElementById('searchInput').addEventListener('keyup', function() {
    const filter = this.value.toLowerCase();
    const rows = document.querySelectorAll('#reportsTable tr');
    
    rows.forEach(row => {
        // نتحقق من اسم الطالب (الخلية الثانية) أو رقم القيد (الخلية الثالثة)
        const studentName = row.cells[1].textContent.toLowerCase();
        const studentID = row.cells[2].textContent.toLowerCase();
        
        if (studentName.startsWith(filter) || studentID.startsWith(filter)) {
            row.style.display = "";
        } else {
            row.style.display = "none";
        }
    });
    
    // إلغاء تحديد الكل عند البحث لضمان عدم اختيار عناصر مخفية
    resetSelection();
});

// --- 2. تحديد الكل الذكي (نفس التخصص فقط) ---
function toggleSelectAll() {
    const selectAll = document.getElementById('selectAll');
    const rows = document.querySelectorAll('#reportsTable tr:not([style*="display: none"])');
    const checkboxes = document.querySelectorAll('#reportsTable tr:not([style*="display: none"]) .row-checkbox');
    
    if (selectAll.checked && rows.length > 0) {
        // نأخذ تخصص أول صف ظاهر كمرجع
        const targetDept = rows[0].getAttribute('data-dept');
        let hasDifferentDept = false;

        rows.forEach(row => {
            if (row.getAttribute('data-dept') !== targetDept) {
                hasDifferentDept = true;
            }
        });

        if (hasDifferentDept) {
            alert(`⚠️ تنبيه: القائمة الظاهرة تحتوي على تخصصات مختلفة. \nيرجى استخدام "الفلترة" لاختيار تخصص واحد أولاً لتتمكن من تحديد الكل.`);
            selectAll.checked = false;
            return;
        }
        
        // إذا كانت كل الصفوف من نفس التخصص، يتم التحديد
        checkboxes.forEach(cb => cb.checked = true);
    } else {
        checkboxes.forEach(cb => cb.checked = false);
    }
    
    updateCount();
}

// --- 3. تحديث العداد والتحقق من وحدة التخصص عند النقر اليدوي ---
function updateCount() {
    const selectedCheckboxes = document.querySelectorAll('.row-checkbox:checked');
    const selectedCountDisplay = document.getElementById('selectedCount');
    const currentDeptDisplay = document.getElementById('currentDept');
    
    if (selectedCheckboxes.length > 0) {
        const firstDept = selectedCheckboxes[0].closest('tr').getAttribute('data-dept');
        
        for (let i = 1; i < selectedCheckboxes.length; i++) {
            const currentDept = selectedCheckboxes[i].closest('tr').getAttribute('data-dept');
            
            if (currentDept !== firstDept) {
                alert("⚠️ لا يمكن خلط التخصصات! يرجى اختيار طلاب من قسم (" + firstDept + ") فقط.");
                // استخدام event.target لإلغاء النقرة الأخيرة
                if(window.event) window.event.target.checked = false;
                return;
            }
        }
        currentDeptDisplay.innerText = firstDept;
    } else {
        currentDeptDisplay.innerText = "الكل";
    }

    selectedCountDisplay.innerText = selectedCheckboxes.length;
}

// --- 4. وظيفة الفلترة (الفرز) ---
function filterBy(dept) {
    const rows = document.querySelectorAll('#reportsTable tr');
    const deptDisplay = document.getElementById('currentDept');
    
    deptDisplay.innerText = dept === 'all' ? 'الكل' : dept;

    rows.forEach(row => {
        row.style.display = (dept === 'all' || row.getAttribute('data-dept') === dept) ? "" : "none";
    });

    resetSelection();
}

// دالة مساعدة لتنظيف الاختيارات
function resetSelection() {
    document.getElementById('selectAll').checked = false;
    document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = false);
    updateCount();
}

// --- 5. عملية التحويل النهائية مع مطابقة التخصص ---
function bulkTransfer() {
    const selected = document.querySelectorAll('.row-checkbox:checked');
    const examinerSelect = document.getElementById('examinerList');
    const examinerText = examinerSelect.value;

    if (selected.length === 0) return alert("❌ يرجى تحديد الطلاب أولاً.");
    if (examinerSelect.selectedIndex === 0) return alert("❌ يرجى اختيار الممتحن المختص.");

    const studentDept = selected[0].closest('tr').getAttribute('data-dept');

    if (!examinerText.includes(studentDept)) {
        alert(`❌ خطأ في المطابقة: تخصص الطلاب هو (${studentDept})، يرجى اختيار ممتحن من نفس القسم.`);
        return;
    }

    if (confirm(`تأكيد: تحويل ${selected.length} طلاب إلى ${examinerText}؟`)) {
        selected.forEach(cb => {
            const row = cb.closest('tr');
            row.style.transform = "translateX(-50px)";
            row.style.opacity = "0";
            setTimeout(() => row.remove(), 500);
        });
        setTimeout(() => {
            alert("✅ تم التحويل بنجاح!");
            resetSelection();
        }, 600);
    }
}