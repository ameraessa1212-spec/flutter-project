document.addEventListener('DOMContentLoaded', () => {
    loadStudents();
});

async function loadStudents() {
    const list = document.querySelector('.students-list');
    list.innerHTML = '<p style="text-align:center; color:#aaa; padding:40px;">جاري التحميل...</p>';

    try {
        const result = await apiGet('/students');
        if (!result || !result.data) return;

        list.innerHTML = '';
        result.data.forEach(s => {
            const initials = (s.name || '').charAt(0);
            const isActive = s.status === 'active';
            const card = document.createElement('div');
            card.className = 'student-card';
            card.setAttribute('data-id', s.id);
            card.onclick = function() { toggleRow(this); };
            card.innerHTML = `
                <div class="card-main">
                    <div class="student-profile">
                        <div class="avatar-box">${initials}</div>
                        <div class="details">
                            <h3 class="student-name">${s.name}</h3>
                            <span class="student-meta">رقم القيد: ${s.student_number || '--'} • ${s.specialization || '--'}</span>
                        </div>
                    </div>
                    <div class="status-badge ${isActive ? 'active' : 'offline'}">${isActive ? 'نشط الآن' : 'موقف مؤقتاً'}</div>
                </div>
                <div class="expandable-actions">
                    <div class="actions-wrapper">
                        <button class="btn-action edit" onclick="handleEdit(event, ${s.id})">
                            <i class="ri-edit-2-line"></i> تعديل
                        </button>
                        <button class="btn-action pass" onclick="handlePassword(event, ${s.id})">
                            <i class="ri-lock-unlock-line"></i> كلمة السر
                        </button>
                        ${isActive ?
                            `<button class="btn-action stop" onclick="handleToggleStatus(event, ${s.id})"><i class="ri-forbid-3-line"></i> إيقاف</button>` :
                            `<button class="btn-action activate" onclick="handleToggleStatus(event, ${s.id})">تفعيل الحساب</button>`
                        }
                    </div>
                </div>
            `;
            list.appendChild(card);
        });
    } catch (e) {
        list.innerHTML = '<p style="text-align:center; color:red;">حدث خطأ في تحميل البيانات</p>';
    }
}

function toggleRow(card) {
    card.classList.toggle('open');
}

function handleEdit(e, userId) {
    e.stopPropagation();
    const newName = prompt('أدخل الاسم الجديد:');
    if (!newName) return;
    const parts = newName.split(' ');
    apiPut(`/students/${userId}`, {
        first_name: parts[0],
        last_name: parts.slice(1).join(' '),
    }).then(() => loadStudents()).catch(() => alert('حدث خطأ'));
}

function handlePassword(e, userId) {
    e.stopPropagation();
    const newPass = prompt('أدخل كلمة المرور الجديدة (8 أحرف على الأقل):');
    if (!newPass || newPass.length < 8) { alert('كلمة المرور يجب أن تكون 8 أحرف على الأقل'); return; }
    apiPut(`/students/${userId}/password`, {
        password: newPass,
        password_confirmation: newPass,
    }).then(() => alert('تم تغيير كلمة المرور بنجاح')).catch(() => alert('حدث خطأ'));
}

async function handleToggleStatus(e, userId) {
    e.stopPropagation();
    if (!confirm('هل أنت متأكد؟')) return;
    try {
        await apiPut(`/students/${userId}/toggle-status`, {});
        loadStudents();
    } catch (err) {
        alert('حدث خطأ');
    }
}

document.getElementById('btnAddAccount').onclick = function() {
    alert('سيتم فتح نافذة إضافة طالب جديد');
};
