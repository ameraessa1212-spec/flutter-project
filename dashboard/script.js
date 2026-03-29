function handleLogin(event) {
    event.preventDefault();
    
    const btn = document.querySelector('.submit-btn');
    const role = document.querySelector('input[name="userRole"]:checked').value;
    
    // تأثير التحميل عند الضغط
    const originalContent = btn.innerHTML;
    btn.innerHTML = '<i class="ri-loader-4-line rotate"></i> جاري التحقق...';
    btn.style.pointerEvents = 'none';
    btn.style.opacity = '0.8';

    setTimeout(() => {
        if(role === 'admin') {
            // توجيه المشرف
            window.location.href = 'homescreen.html';
        } else if(role === 'examiner') {
            // توجيه الممتحن إلى الصفحة الجديدة
            window.location.href = 'examiner_dashboard.html';
        }
    }, 1500);
}

// أنيميشن أيقونة التحميل
const style = document.createElement('style');
style.innerHTML = `
    @keyframes rotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
    .rotate { display: inline-block; animation: rotate 1s infinite linear; }
`;
document.head.appendChild(style);
function handleSignup(event) {
    event.preventDefault();
    
    const btn = event.target.querySelector('.submit-btn');
    const originalContent = btn.innerHTML;
    
    // تأثير التحميل
    btn.innerHTML = '<i class="ri-loader-4-line rotate"></i> جاري المعالجة...';
    btn.style.pointerEvents = 'none';
    btn.style.opacity = '0.8';

    // محاكاة عملية الحفظ ثم التوجيه لصفحة الدخول
    setTimeout(() => {
        alert('تم إنشاء الحساب بنجاح!');
        window.location.href = 'login.html'; // استبدليها باسم ملف صفحة الدخول لديكِ
    }, 2000);
}

// أنيميشن التحميل (أضيفيه إذا لم يكن موجوداً)
if (!document.getElementById('rotate-style')) {
    const style = document.createElement('style');
    style.id = 'rotate-style';
    style.innerHTML = `
        @keyframes rotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
        .rotate { display: inline-block; animation: rotate 1s infinite linear; }
    `;
    document.head.appendChild(style);
}
function handleSignup(event) {
    event.preventDefault();
    const btn = event.target.querySelector('.submit-btn');
    
    // محاكاة التحميل
    btn.innerHTML = '<i class="ri-loader-4-line rotate"></i> جاري الإرسال...';
    btn.style.pointerEvents = 'none';

    setTimeout(() => {
        // التوجيه لصفحة كود التحقق
        window.location.href = 'verify_email.html';
    }, 1500);
}