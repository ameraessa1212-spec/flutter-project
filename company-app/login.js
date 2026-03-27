document.addEventListener('DOMContentLoaded', function() {
    const loginForm = document.getElementById('loginForm');
    const submitBtn = document.getElementById('submitBtn');

    if (loginForm) {
        loginForm.addEventListener('submit', function(e) {
            e.preventDefault();

            // 1. إظهار حالة التحميل على الزر
            submitBtn.innerHTML = '<i class="ri-loader-4-line rotate"></i> جاري التحقق...';
            submitBtn.style.pointerEvents = 'none';
            submitBtn.style.opacity = '0.8';

            // 2. محاكاة عملية التحقق (مدة ثانية ونصف)
            setTimeout(() => {
                const email = document.getElementById('email').value;
                
                console.log("تم تسجيل الدخول بنجاح:", email);
                
                // 3. التوجيه لصفحة لوحة التحكم (Dashboard)
                window.location.href = 'dashboard.html';
            }, 1500);
        });
    }
});

// إضافة حركة الدوران للأيقونة
const style = document.createElement('style');
style.innerHTML = `
    .rotate { animation: spin 1s linear infinite; display: inline-block; }
    @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
`;
document.head.appendChild(style);