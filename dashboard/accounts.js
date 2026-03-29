// دالة التبديل (فتح وإغلاق البطاقة)
function toggleRow(card) {
    // إذا أردتِ فتح بطاقة واحدة فقط في كل مرة، فكي التعليق عن الكود التالي:
    /*
    document.querySelectorAll('.student-card').forEach(c => {
        if(c !== card) c.classList.remove('open');
    });
    */
    card.classList.toggle('open');
}

// معالجة الضغط على أزرار الأوامر (منع انتشار الحدث)
function handleEdit(e, name) {
    e.stopPropagation();
    alert("تعديل بيانات الطالب: " + name);
}

function handlePassword(e, name) {
    e.stopPropagation();
    alert("تغيير كلمة مرور: " + name);
}

function handleDelete(e, name) {
    e.stopPropagation();
    confirm("هل تريد إيقاف حساب " + name + " بشكل مؤقت؟");
}

function handleActivate(e, name) {
    e.stopPropagation();
    alert("تم تفعيل الحساب لـ " + name);
}

// زر الإضافة الرئيسي
document.getElementById('btnAddAccount').onclick = function() {
    alert("سيتم فتح نافذة إضافة طالب جديد");
};