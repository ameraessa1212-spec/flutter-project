document.addEventListener('DOMContentLoaded', function() {
    
    // 1. تعريف العناصر الأساسية
    const menuItems = document.querySelectorAll('.menu-item');
    const homeLink = document.getElementById('homeLink');
    const requestsLink = document.getElementById('requestsLink');
    const evalLink = document.getElementById('evalLink');
    const reviewBtn = document.getElementById('reviewBtn');
    
    const evalFrame = document.getElementById('evalFrame');
    const mainBody = document.getElementById('mainDashboardBody');
    const greetingText = document.getElementById('greetingText');
    const subTitle = document.getElementById('subTitle');
    const logoutBtn = document.getElementById('logoutBtn');

    // --- دالة تحديث حالة القائمة النشطة ---
    function updateActiveMenu(element) {
        menuItems.forEach(item => item.classList.remove('active'));
        if (element) element.classList.add('active');
    }

    // --- دالة العودة للرئيسية ---
    function showHome() {
        updateActiveMenu(homeLink);
        evalFrame.style.display = 'none';
        evalFrame.src = ''; 
        mainBody.style.display = 'block';
        
        // إعادة التحية بناءً على الوقت
        const hour = new Date().getHours();
        let greeting = hour < 12 ? "صباح الخير" : "مساء الخير";
        greetingText.innerText = `${greeting}، شركة المدار الجديد 👋`;
        subTitle.innerText = "إليك ما يحدث في برنامج التدريب الخاص بك اليوم";
    }

    // --- دالة تحميل الصفحات الفرعية وتحديث الهيدر ---
    function loadSubPage(url, menuElement, mainTitle, secondaryTitle) {
        updateActiveMenu(menuElement);
        
        // إخفاء محتوى الرئيسية
        mainBody.style.display = 'none';
        
        // تحديث نصوص الهيدر لتطابق الصفحة الجديدة
        if (greetingText) greetingText.innerText = mainTitle;
        if (subTitle) subTitle.innerText = secondaryTitle;
        
        // تحميل الصفحة الجديدة في الإطار
        evalFrame.src = url;
        evalFrame.style.display = 'block';
    }

    // --- ربط الأزرار بالأحداث ---

    // 1. زر الرئيسية
    if (homeLink) {
        homeLink.addEventListener('click', (e) => { 
            e.preventDefault(); 
            showHome(); 
        });
    }

    // 2. زر طلبات الطلبة
    if (requestsLink) {
        requestsLink.addEventListener('click', (e) => { 
            e.preventDefault(); 
            loadSubPage(
                'students_requests.html', 
                requestsLink, 
                "طلبات التدريب الواردة", 
                "إدارة ومراجعة طلبات الطلاب المتقدمين للفرص التدريبية"
            ); 
        });
    }

    // 3. زر تقييم الطلبة (تم الربط بـ company_evaluation.html)
    if (evalLink) {
        evalLink.addEventListener('click', (e) => { 
            e.preventDefault(); 
            loadSubPage(
                'company_evaluation.html', 
                evalLink, 
                "نموذج تقييم المتدربين", 
                "تقييم الأداء المهني والسلوكي للطلاب خلال فترة التدريب"
            ); 
        });
    }

    // 4. زر المراجعة السريع في البنر
    if (reviewBtn) {
        reviewBtn.addEventListener('click', () => { 
            loadSubPage(
                'students_requests.html', 
                requestsLink, 
                "طلبات التدريب الواردة", 
                "إدارة ومراجعة طلبات الطلاب المتقدمين للفرص التدريبية"
            ); 
        });
    }

    // 5. معالجة تسجيل الخروج
    if (logoutBtn) {
        logoutBtn.addEventListener('click', (e) => {
            e.preventDefault();
            if (confirm("هل أنت متأكد من رغبتك في تسجيل الخروج؟")) {
                window.location.href = 'index.html';
            }
        });
    }

    // ضبط التحية عند أول تحميل للصفحة
    const hour = new Date().getHours();
    let greeting = hour < 12 ? "صباح الخير" : "مساء الخير";
    if (greetingText && mainBody.style.display !== 'none') {
        greetingText.innerText = `${greeting}، شركة المدار الجديد 👋`;
    }
});