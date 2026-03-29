document.addEventListener('DOMContentLoaded', () => {
    loadRequests();
});

async function loadRequests() {
    const container = document.getElementById('requestsContainer');
    container.innerHTML = '<p style="text-align:center; color:#aaa; padding:40px;">جاري التحميل...</p>';

    try {
        const result = await apiGet('/student-requests');
        if (!result || !result.data) return;

        container.innerHTML = '';
        result.data.forEach(app => {
            const s = app.student;
            const row = document.createElement('div');
            row.className = 'request-row';
            row.innerHTML = `
                <div class="row-main" onclick="this.parentElement.classList.toggle('open')">
                    <div class="student-meta">
                        <span class="reg-number">#${s.student_number || s.id}</span>
                        <h3 class="student-name">${s.name}</h3>
                    </div>
                    <div class="target-company"><i class="ri-community-line"></i> <span>${app.company?.name || '--'}</span></div>
                    <div class="major-tag">${s.specialization || '--'}</div>
                    <div class="row-actions">
                        <button class="action-icon approve" onclick="updateRequestStatus(event, ${app.id}, 'approved')"><i class="ri-check-fill"></i></button>
                        <button class="action-icon reject" onclick="updateRequestStatus(event, ${app.id}, 'rejected')"><i class="ri-close-fill"></i></button>
                    </div>
                </div>
                <div class="row-details">
                    <div class="details-inner">
                        <div class="info-group">
                            <span class="info-item"><i class="ri-user-smile-line"></i> ${s.username || '--'}</span>
                            <span class="info-item"><i class="ri-phone-line"></i> ${s.phone || '--'}</span>
                            <span class="info-item"><i class="ri-mail-line"></i> ${s.email || '--'}</span>
                        </div>
                    </div>
                </div>
            `;
            container.appendChild(row);
        });

        if (result.data.length === 0) {
            container.innerHTML = '<p style="text-align:center; color:#aaa; padding:40px;">لا توجد طلبات حالياً</p>';
        }
    } catch (e) {
        container.innerHTML = '<p style="text-align:center; color:red;">حدث خطأ في تحميل البيانات</p>';
    }
}

async function updateRequestStatus(e, applicationId, status) {
    e.stopPropagation();
    const label = status === 'approved' ? 'قبول' : 'رفض';
    if (!confirm(`هل تريد ${label} هذا الطلب؟`)) return;

    try {
        await apiPut(`/student-requests/${applicationId}/status`, { status });
        loadRequests();
    } catch (err) {
        alert('حدث خطأ');
    }
}
