// Auto-redirect if already logged in
document.addEventListener('DOMContentLoaded', () => {
    const token = getToken();
    const user = getUser();
    if (token && user) {
        if (user.role === 'examiner') {
            window.location.href = 'examiner_dashboard.html';
        } else {
            window.location.href = 'homescreen.html';
        }
    }
});

async function handleLogin(event) {
    event.preventDefault();

    const btn = document.querySelector('.submit-btn');
    const role = document.querySelector('input[name="userRole"]:checked').value;
    const login = document.getElementById('loginInput').value.trim();
    const password = document.getElementById('passwordInput').value;

    const originalContent = btn.innerHTML;
    btn.innerHTML = '<i class="ri-loader-4-line rotate"></i> جاري التحقق...';
    btn.style.pointerEvents = 'none';
    btn.style.opacity = '0.8';

    try {
        const result = await apiRequest('/login', {
            method: 'POST',
            body: JSON.stringify({ login, password, role }),
            skipAuth: true,
        });

        if (result && result.data) {
            setToken(result.data.token);
            setUser(result.data.user);

            if (role === 'examiner' || result.data.user.role === 'examiner') {
                window.location.href = 'examiner_dashboard.html';
            } else {
                window.location.href = 'homescreen.html';
            }
            return;
        }

        // API returned null (server down)
        alert('لا يمكن الاتصال بالخادم. تأكد من تشغيل السيرفر.');
        btn.innerHTML = originalContent;
        btn.style.pointerEvents = '';
        btn.style.opacity = '';
    } catch (error) {
        const msg = error.data?.message || error.data?.errors?.login?.[0] || 'حدث خطأ في تسجيل الدخول';
        alert(msg);
        btn.innerHTML = originalContent;
        btn.style.pointerEvents = '';
        btn.style.opacity = '';
    }
}

async function handleSignup(event) {
    event.preventDefault();
    const btn = event.target.querySelector('.submit-btn');
    btn.innerHTML = '<i class="ri-loader-4-line rotate"></i> جاري الإرسال...';
    btn.style.pointerEvents = 'none';
    setTimeout(() => { window.location.href = 'verify_email.html'; }, 1500);
}

// Loading spinner animation
if (!document.getElementById('rotate-style')) {
    const style = document.createElement('style');
    style.id = 'rotate-style';
    style.innerHTML = `@keyframes rotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } } .rotate { display: inline-block; animation: rotate 1s infinite linear; }`;
    document.head.appendChild(style);
}
