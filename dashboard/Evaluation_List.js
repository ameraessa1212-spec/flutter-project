// بيانات الطلاب
const studentsData = [
    { name: "محمد علي الهاشمي", id: "21918234", major: "حاسب آلي", company: "ليبيانا للهاتف المحمول" },
    { name: "أحمد المبروك", id: "22015432", major: "اتصالات", company: "المدار الجديد" },
    { name: "سارة الفيتوري", id: "22119876", major: "حاسب آلي", company: "تكنو كود" }
];

// 1. دالة عرض الكروت في الشبكة
function renderStudents(data) {
    const grid = document.getElementById('studentsGrid');
    
    // تنظيف الشبكة قبل الإضافة
    grid.innerHTML = "";

    if (data.length === 0) {
        grid.innerHTML = '<p style="text-align:center; grid-column:1/-1; padding:20px; color:#777;">لا يوجد طلاب في هذا التخصص حالياً.</p>';
        return;
    }
    
    grid.innerHTML = data.map((s, index) => `
        <div class="student-card" style="animation: fadeInUp 0.5s ease forwards; animation-delay: ${index * 0.1}s">
            <h3 style="margin:0; font-size:20px; color:#2d3436;">${s.name}</h3>
            <p style="color:#777; font-size:14px; margin:10px 0;">رقم القيد: ${s.id}</p>
            <div style="background:#f0eeff; color:#6A5AE0; padding:5px 15px; border-radius:10px; font-size:12px; font-weight:800; display:inline-block;">${s.major}</div>
            <button class="btn-view" onclick="openEvaluation('${s.name}', '${s.id}', '${s.company}')">
                عرض النتيجة <i class="ri-arrow-left-s-line"></i>
            </button>
        </div>
    `).join('');
}

// 2. دالة الفلترة (تعمل عند تغيير قيمة الـ select)
function filterStudents() {
    // الحصول على القيمة المختارة من القائمة المنسدلة
    const selectedValue = document.getElementById('majorFilter').value;
    
    let filtered;
    if (selectedValue === "الكل") {
        filtered = studentsData;
    } else {
        // تصفية البيانات بناءً على التخصص المختار
        filtered = studentsData.filter(student => student.major === selectedValue);
    }
    
    // إعادة بناء الواجهة بالبيانات المفلترة
    renderStudents(filtered);
}

// 3. فتح شاشة التقييم وتعبئة البيانات
function openEvaluation(name, id, company) {
    document.getElementById('listView').classList.remove('active');
    document.getElementById('evaluationView').classList.add('active');
    
    document.getElementById('stName').innerText = name;
    document.getElementById('stID').innerText = id;
    document.getElementById('stCompany').innerText = company;
    
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

// 4. العودة للقائمة الرئيسية
function showList() {
    document.getElementById('evaluationView').classList.remove('active');
    document.getElementById('listView').classList.add('active');
}

// 5. دالة إرسال النتيجة (محاكاة)
function sendToExaminer(btn) {
    const originalText = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = `<i class="ri-loader-4-line ri-spin"></i> جاري إرسال التقرير...`;
    
    setTimeout(() => {
        btn.style.background = "#2ecc71";
        btn.innerHTML = `<i class="ri-check-double-line"></i> تم الإرسال بنجاح`;
        alert('تم بنجاح إرسال نموذج التقييم إلى حساب الممتحن.');
        
        setTimeout(() => {
            btn.disabled = false;
            btn.style.background = "#2d3436";
            btn.innerHTML = originalText;
        }, 3000);
    }, 2000);
}

// عرض جميع الطلاب عند تحميل الصفحة لأول مرة
document.addEventListener('DOMContentLoaded', () => {
    renderStudents(studentsData);
});