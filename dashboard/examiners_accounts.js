// وظيفة التبديل بين نشط ومعطل
function toggleAccount(btn) {
    const row = btn.closest('tr');
    const statusLabel = row.querySelector('.status-badge');
    const examinerName = row.querySelector('.user-cell').innerText;

    if (statusLabel.classList.contains('active')) {
        // حالة التغيير إلى معطل
        if (confirm(`هل أنت متأكد من تعطيل حساب (${examinerName})؟ لن يتمكن من تسجيل الدخول.`)) {
            statusLabel.innerText = "معطل";
            statusLabel.className = "status-badge inactive";
            btn.innerText = "تفعيل";
            btn.classList.add('activate');
            
            // إضافة تأثير حركي بسيط
            row.style.backgroundColor = "#fffafa";
            setTimeout(() => row.style.backgroundColor = "transparent", 500);
        }
    } else {
        // حالة التغيير إلى نشط
        statusLabel.innerText = "نشط";
        statusLabel.className = "status-badge active";
        btn.innerText = "تعطيل";
        btn.classList.remove('activate');
        
        row.style.backgroundColor = "#f0fff4";
        setTimeout(() => row.style.backgroundColor = "transparent", 500);
    }
}

// وظيفة البحث الذكي
document.getElementById('examinerSearch').addEventListener('input', function() {
    const filter = this.value.toLowerCase();
    const rows = document.querySelectorAll('#examinersTable tr');
    
    rows.forEach(row => {
        const text = row.innerText.toLowerCase();
        if (text.includes(filter)) {
            row.style.display = "";
            row.style.animation = "slideUp 0.3s ease-out";
        } else {
            row.style.display = "none";
        }
    });
});