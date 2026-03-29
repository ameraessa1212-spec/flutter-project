document.addEventListener('DOMContentLoaded', function() {
    const signupForm = document.getElementById('signupForm');

    if (signupForm) {
        signupForm.addEventListener('submit', function(e) {
            e.preventDefault();

            const btn = this.querySelector('.submit-btn');
            const originalText = btn.innerText;

            // تغيير حالة الزر للتحميل
            btn.innerHTML = '<i class="ri-loader-4-line rotate"></i> جاري إرسال الطلب...';
            btn.style.pointerEvents = 'none';

            setTimeout(() => {
                alert("تم استلام طلبك بنجاح! سيقوم فريقنا بمراجعته والتواصل معك.");
                window.location.href = 'login.html'; // التوجه لصفحة تسجيل الدخول بعد النجاح
            }, 2000);
        });
    }
});

// إضافة ستايل دوران أيقونة التحميل
const style = document.createElement('style');
style.innerHTML = `
    .rotate { animation: spin 1s linear infinite; display: inline-block; vertical-align: middle; margin-left: 8px; }
    @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
`;
document.head.appendChild(style);
// أي كود إضافي للتحسينات البصرية فقط
document.addEventListener('DOMContentLoaded', function() {
    console.log("Signup page ready");
});