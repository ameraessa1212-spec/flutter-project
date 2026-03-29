const companyForms = {
    'techno': {
        name: 'شركة تكنو كود',
        bio: 'متخصصون في تطوير الحلول البرمجية المتكاملة والتحول الرقمي.',
        email: 'hr@techno.ly',
        location: 'طرابلس - حي الأندلس',
        students: '5 طلاب',
        major: 'حاسب آلي (تطوير ويب)',
        duration: 'شهرين',
        social: 'https://facebook.com/technocode'
    },
    'libya_control': {
        name: 'ليبيا للتحكم',
        bio: 'شركة رائدة في مجال التحكم الصناعي والأنظمة الكهربائية الحديثة.',
        email: 'info@lcontrol.ly',
        location: 'بنغازي - منطقة القوارشة',
        students: '3 طلاب',
        major: 'هندسة تحكم',
        duration: '3 أشهر',
        social: 'https://linkedin.com/company/libya-control'
    }
};

function openDetails(id) {
    const data = companyForms[id];
    const content = document.getElementById('modalContent');
    
    content.innerHTML = `
        <div class="data-row">
            <span class="data-label">اسم الشركة</span>
            <span class="data-value">${data.name}</span>
        </div>
        
        <div class="data-row-vertical">
            <span class="data-label">نبذة تعريفية</span>
            <span class="data-value" style="font-weight:400; line-height:1.6; text-align:right;">${data.bio}</span>
        </div>
        
        <div class="data-row">
            <span class="data-label">الموقع الجغرافي</span>
            <span class="data-value">${data.location}</span>
        </div>
        
        <div class="data-row">
            <span class="data-label">البريد الإلكتروني</span>
            <span class="data-value" style="font-size:13px;">${data.email}</span>
        </div>
        
        <div class="data-row">
            <span class="data-label">رابط التواصل</span>
            <span class="data-value">
                <a href="${data.social}" target="_blank" class="social-link">
                    <i class="ri-links-line"></i> زيارة الرابط
                </a>
            </span>
        </div>

        <div class="data-row">
            <span class="data-label">المجال المطلوب</span>
            <span class="data-value" style="color:#6A5AE0;">${data.major}</span>
        </div>

        <div class="data-row">
            <span class="data-label">العدد المطلوب</span>
            <span class="data-value">${data.students}</span>
        </div>

        <div class="data-row" style="border:none;">
            <span class="data-label">مدة التدريب</span>
            <span class="data-value">${data.duration}</span>
        </div>
        
        <div style="height:10px;"></div>
    `;
    
    document.getElementById('formModal').style.display = 'flex';
}

function closeModal() {
    document.getElementById('formModal').style.display = 'none';
}

function approveRequest(btn, id) {
    const data = companyForms[id];
    if(confirm(`تأكيد قبول شركة [${data.name}]؟\nسيتم إرسال كلمة المرور إلى: ${data.email}`)) {
        const pass = "PW-" + Math.floor(1000 + Math.random() * 9000);
        const card = btn.closest('.modern-card');
        card.querySelector('.card-status').innerText = 'تم القبول';
        card.querySelector('.card-status').className = 'card-status status-approved';
        btn.innerHTML = 'تم القبول ✓';
        btn.disabled = true;
        btn.style.background = '#33D69F';
        btn.parentElement.querySelector('.btn-reject').style.display = 'none';
        alert(`✅ تم الاعتماد بنجاح!\n📧 تم إرسال البريد إلى: ${data.email}\n🔑 كلمة المرور الجديدة هي: ${pass}`);
    }
}

function rejectRequest(cardId, name) {
    if(confirm(`هل أنتِ متأكدة من رفض طلب شركة ${name}؟`)) {
        const card = document.getElementById(cardId);
        card.querySelector('.card-status').innerText = 'تم الرفض';
        card.querySelector('.card-status').className = 'card-status status-rejected';
        card.style.opacity = '0.6';
        card.querySelector('.card-actions').innerHTML = '<span style="color:#FF5B5B; font-weight:bold; width:100%; text-align:center">تم الرفض بنجاح</span>';
    }
}

// إغلاق المودال عند الضغط خارج الصندوق
window.onclick = function(event) {
    const modal = document.getElementById('formModal');
    if (event.target == modal) { closeModal(); }
}