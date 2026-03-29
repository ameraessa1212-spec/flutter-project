let offersData = [];

document.addEventListener('DOMContentLoaded', () => {
    loadOffers();
});

async function loadOffers() {
    try {
        const result = await apiGet('/company-offers');
        if (result && result.data) {
            offersData = result.data;
            renderOffers(offersData);
        }
    } catch (e) {
        console.error('Failed to load offers:', e);
    }
}

function renderOffers(data) {
    const grid = document.getElementById('offersGrid');
    if (!grid) return;

    if (data.length === 0) {
        grid.innerHTML = '<p style="text-align:center; color:#aaa; padding:40px;">لا توجد عروض معلقة حالياً</p>';
        return;
    }

    grid.innerHTML = data.map(offer => `
        <div class="modern-card" id="offer-${offer.id}">
            <div class="card-header">
                <div class="company-name">${offer.company?.name || '--'}</div>
                <span class="card-status status-pending">${offer.status === 'pending' ? 'قيد المراجعة' : offer.status}</span>
            </div>
            <div class="card-body">
                <div class="info-row"><i class="ri-map-pin-line"></i> ${offer.city || offer.location_text || '--'}</div>
                <div class="info-row"><i class="ri-briefcase-line"></i> ${offer.specialization || '--'}</div>
                <div class="info-row"><i class="ri-group-line"></i> ${offer.seats_count || 0} طلاب</div>
                <div class="info-row"><i class="ri-time-line"></i> ${offer.duration_text || offer.duration_days + ' يوم'}</div>
            </div>
            <div class="card-actions">
                <button class="btn-view" onclick="openDetails(${offer.id})"><i class="ri-eye-line"></i> عرض</button>
                <button class="btn-approve" onclick="approveRequest(this, ${offer.id})"><i class="ri-check-line"></i> قبول</button>
                <button class="btn-reject" onclick="rejectRequest(this, ${offer.id})"><i class="ri-close-line"></i> رفض</button>
            </div>
        </div>
    `).join('');
}

function openDetails(offerId) {
    const offer = offersData.find(o => o.id === offerId);
    if (!offer) return;

    const content = document.getElementById('modalContent');
    content.innerHTML = `
        <div class="data-row"><span class="data-label">اسم الشركة</span><span class="data-value">${offer.company?.name || '--'}</span></div>
        <div class="data-row-vertical"><span class="data-label">نبذة تعريفية</span><span class="data-value" style="font-weight:400; line-height:1.6; text-align:right;">${offer.company?.description || '--'}</span></div>
        <div class="data-row"><span class="data-label">الموقع الجغرافي</span><span class="data-value">${offer.city || '--'}</span></div>
        <div class="data-row"><span class="data-label">البريد الإلكتروني</span><span class="data-value" style="font-size:13px;">${offer.company?.email || '--'}</span></div>
        <div class="data-row"><span class="data-label">المجال المطلوب</span><span class="data-value" style="color:#6A5AE0;">${offer.specialization || '--'}</span></div>
        <div class="data-row"><span class="data-label">العدد المطلوب</span><span class="data-value">${offer.seats_count || 0} طلاب</span></div>
        <div class="data-row" style="border:none;"><span class="data-label">مدة التدريب</span><span class="data-value">${offer.duration_text || '--'}</span></div>
    `;
    document.getElementById('formModal').style.display = 'flex';
}

function closeModal() {
    document.getElementById('formModal').style.display = 'none';
}

async function approveRequest(btn, offerId) {
    if (!confirm('تأكيد قبول هذا العرض؟')) return;

    btn.disabled = true;
    btn.innerHTML = '<i class="ri-loader-4-line ri-spin"></i>';

    try {
        await apiPut(`/company-offers/${offerId}/approve`, {});
        const card = document.getElementById(`offer-${offerId}`);
        card.querySelector('.card-status').innerText = 'تم القبول';
        card.querySelector('.card-status').className = 'card-status status-approved';
        btn.innerHTML = 'تم القبول ✓';
        btn.style.background = '#33D69F';
        btn.parentElement.querySelector('.btn-reject').style.display = 'none';
    } catch (e) {
        btn.disabled = false;
        btn.innerHTML = '<i class="ri-check-line"></i> قبول';
        alert('حدث خطأ');
    }
}

async function rejectRequest(btn, offerId) {
    const offer = offersData.find(o => o.id === offerId);
    if (!confirm(`هل أنت متأكد من رفض هذا العرض؟`)) return;

    try {
        await apiPut(`/company-offers/${offerId}/reject`, {});
        const card = document.getElementById(`offer-${offerId}`);
        card.querySelector('.card-status').innerText = 'تم الرفض';
        card.querySelector('.card-status').className = 'card-status status-rejected';
        card.style.opacity = '0.6';
        card.querySelector('.card-actions').innerHTML = '<span style="color:#FF5B5B; font-weight:bold; width:100%; text-align:center">تم الرفض بنجاح</span>';
    } catch (e) {
        alert('حدث خطأ');
    }
}

window.onclick = function(event) {
    const modal = document.getElementById('formModal');
    if (event.target == modal) closeModal();
};
