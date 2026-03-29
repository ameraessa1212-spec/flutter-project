/**
 * Dashboard SPA Router
 * Single-page app shell — no iframes, no page reloads.
 * All pages render into #mainArea via JS functions.
 */

// ─── Boot ───────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    if (!requireAuth()) return;
    navigateTo('home');
});

// ─── Navigation ─────────────────────────────────────────
let currentPage = null;

const routes = {
    home:               { label: 'الرئيسية',          load: pageHome },
    accounts:           { label: 'إدارة حسابات الطلاب', load: pageAccounts },
    requests:           { label: 'بيانات الطلاب',      load: pageRequests },
    upload:             { label: 'تحميل قائمة الطلاب',  load: pageUpload },
    reports:            { label: 'تقارير الطلاب',       load: pageReports },
    evaluation:         { label: 'نتيجة الطلاب',       load: pageEvaluation },
    chat:               { label: 'الدردشة',            load: pageChat },
    transferReports:    { label: 'تحويل التقارير',      load: pageTransferReports },
    receiveResults:     { label: 'استلام التقييم',      load: pageReceiveResults },
    examinerAccounts:   { label: 'إدارة حسابات الممتحنين', load: pageExaminerAccounts },
    companyOffers:      { label: 'عروض الشركات',       load: pageCompanyOffers },
    registeredCompanies:{ label: 'الشركات المسجلة',    load: pageRegisteredCompanies },
    evaluationList:     { label: 'تقييم الشركات',      load: pageEvaluationList },
    companyAccounts:    { label: 'إدارة حسابات الشركات',load: pageCompanyAccounts },
    systemReports:      { label: 'تقارير النظام',      load: pageSystemReports },
    discussionSchedule: { label: 'جدول المناقشة',      load: pageDiscussionSchedule },
};

function navigateTo(page, event) {
    if (event) event.stopPropagation();
    if (!routes[page]) return;

    currentPage = page;
    const mainArea = document.getElementById('mainArea');

    // Update active menu
    document.querySelectorAll('.menu-item').forEach(i => i.classList.remove('active'));
    const activeItem = document.querySelector(`[data-page="${page}"]`);
    if (activeItem) {
        const parent = activeItem.closest('.menu-item') || activeItem;
        parent.classList.add('active');
    }

    // Fade transition
    mainArea.style.opacity = '0';
    setTimeout(() => {
        routes[page].load(mainArea);
        mainArea.style.opacity = '1';
    }, 150);
}

// ─── Sidebar menu toggle ────────────────────────────────
function toggleMenu(element) {
    document.querySelectorAll('.menu-item.has-sub').forEach(item => {
        if (item !== element) item.classList.remove('open');
    });
    element.classList.toggle('open');
}

// ─── Logout ─────────────────────────────────────────────
async function handleLogout() {
    try { await apiPost('/logout', {}); } catch (e) { /* ignore */ }
    clearAuth();
    window.location.href = 'index.html';
}

// ═══════════════════════════════════════════════════════
// PAGE: Home Dashboard
// ═══════════════════════════════════════════════════════
function pageHome(container) {
    container.innerHTML = `
    <div class="dashboard-card-wrapper">
        <div class="header"><h1>نظرة عامة</h1><p>ملخص نشاط نظام التدريب الميداني</p></div>
        <div class="stats-grid">
            <div class="stat-card"><div class="icon-box blue"><i class="ri-group-line"></i></div><div class="stat-info"><h3 id="stat-students">--</h3><p>إجمالي الطلاب</p></div></div>
            <div class="stat-card"><div class="icon-box green"><i class="ri-user-follow-line"></i></div><div class="stat-info"><h3 id="stat-trainees">--</h3><p>متدربون حالياً</p></div></div>
            <div class="stat-card"><div class="icon-box orange"><i class="ri-building-2-line"></i></div><div class="stat-info"><h3 id="stat-companies">--</h3><p>شركات مسجلة</p></div></div>
            <div class="stat-card"><div class="icon-box red"><i class="ri-time-line"></i></div><div class="stat-info"><h3 id="stat-pending">--</h3><p>طلبات معلقة</p></div></div>
        </div>
        <div class="dashboard-row">
            <div class="chart-box"><h3>توزيع الطلاب على الشركات</h3><div class="chart-container"><canvas id="mainChart"></canvas></div></div>
            <div class="alerts-box"><h3 class="alert-title">تنبيهات عاجلة</h3><div id="alerts-container"><p style="color:#aaa;text-align:center;">جاري التحميل...</p></div></div>
        </div>
    </div>`;
    loadDashboardData();
}

async function loadDashboardData() {
    // Stats
    const stats = await apiGet('/dashboard/stats');
    if (stats?.data) {
        setText('stat-students', stats.data.total_students);
        setText('stat-trainees', stats.data.active_trainees);
        setText('stat-companies', stats.data.total_companies);
        setText('stat-pending', String(stats.data.pending_requests).padStart(2, '0'));
    }
    // Chart
    const chart = await apiGet('/dashboard/chart-data');
    initChart(chart?.data?.labels || [], chart?.data?.values || []);
    // Alerts
    const alerts = await apiGet('/dashboard/alerts');
    const ac = document.getElementById('alerts-container');
    if (!ac) return;
    if (alerts?.data?.length) {
        ac.innerHTML = alerts.data.map(a => `<div class="alert-item ${a.type}"><i class="${a.type === 'danger' ? 'ri-error-warning-line' : 'ri-mail-line'}"></i><div><strong>${a.title}</strong><small>${a.message}</small></div></div>`).join('');
    } else {
        ac.innerHTML = '<p style="color:#aaa;text-align:center;">لا توجد تنبيهات حالياً</p>';
    }
}

function initChart(labels, data) {
    const canvas = document.getElementById('mainChart');
    if (!canvas) return;
    if (window._chart) window._chart.destroy();
    window._chart = new Chart(canvas.getContext('2d'), {
        type: 'bar',
        data: { labels, datasets: [{ label: 'عدد الطلاب', data, backgroundColor: '#6A5AE0', borderRadius: 10, barThickness: 45 }] },
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, grid: { color: '#f5f5f5' } }, x: { grid: { display: false } } } }
    });
}

// ═══════════════════════════════════════════════════════
// PAGE: Student Accounts
// ═══════════════════════════════════════════════════════
function pageAccounts(c) {
    c.innerHTML = `<div class="page-panel">
        <header class="page-header"><div class="header-info"><h1>إدارة الحسابات</h1><p>التحكم في بيانات الطلاب وصلاحيات الدخول</p></div></header>
        <div class="students-list" id="studentsList"><p class="loading-text">جاري التحميل...</p></div>
    </div>`;
    loadStudentAccounts();
}

async function loadStudentAccounts() {
    const result = await apiGet('/students');
    const list = document.getElementById('studentsList');
    if (!list) return;
    if (!result?.data?.length) { list.innerHTML = '<p class="empty-text">لا يوجد طلاب</p>'; return; }
    list.innerHTML = result.data.map(s => `
        <div class="student-card" onclick="this.classList.toggle('open')">
            <div class="card-main">
                <div class="student-profile"><div class="avatar-box">${(s.name||'').charAt(0)}</div><div class="details"><h3 class="student-name">${s.name}</h3><span class="student-meta">رقم القيد: ${s.student_number||'--'} • ${s.specialization||'--'}</span></div></div>
                <div class="status-badge ${s.status==='active'?'active':'offline'}">${s.status==='active'?'نشط الآن':'موقف مؤقتاً'}</div>
            </div>
            <div class="expandable-actions"><div class="actions-wrapper">
                <button class="btn-action edit" onclick="event.stopPropagation();editStudent(${s.id})"><i class="ri-edit-2-line"></i> تعديل</button>
                <button class="btn-action pass" onclick="event.stopPropagation();changePassword(${s.id})"><i class="ri-lock-unlock-line"></i> كلمة السر</button>
                <button class="btn-action ${s.status==='active'?'stop':'activate'}" onclick="event.stopPropagation();toggleStudentStatus(${s.id})">${s.status==='active'?'<i class=\"ri-forbid-3-line\"></i> إيقاف':'تفعيل الحساب'}</button>
            </div></div>
        </div>`).join('');
}

async function editStudent(id) {
    const name = prompt('أدخل الاسم الجديد:');
    if (!name) return;
    const parts = name.split(' ');
    await apiPut(`/students/${id}`, { first_name: parts[0], last_name: parts.slice(1).join(' ') });
    loadStudentAccounts();
}
async function changePassword(id) {
    const pw = prompt('كلمة المرور الجديدة (8 أحرف على الأقل):');
    if (!pw || pw.length < 8) { alert('كلمة المرور قصيرة'); return; }
    await apiPut(`/students/${id}/password`, { password: pw, password_confirmation: pw });
    alert('تم تغيير كلمة المرور');
}
async function toggleStudentStatus(id) {
    if (!confirm('هل أنت متأكد؟')) return;
    await apiPut(`/students/${id}/toggle-status`, {});
    loadStudentAccounts();
}

// ═══════════════════════════════════════════════════════
// PAGE: Student Requests
// ═══════════════════════════════════════════════════════
function pageRequests(c) {
    c.innerHTML = `<div class="page-panel"><header class="page-header"><h1>بيانات الطلاب</h1></header><div id="requestsContainer"><p class="loading-text">جاري التحميل...</p></div></div>`;
    loadRequests();
}
async function loadRequests() {
    const result = await apiGet('/student-requests');
    const container = document.getElementById('requestsContainer');
    if (!container) return;
    if (!result?.data?.length) { container.innerHTML = '<p class="empty-text">لا توجد طلبات</p>'; return; }
    container.innerHTML = result.data.map(app => {
        const s = app.student;
        return `<div class="request-row">
            <div class="row-main" onclick="this.parentElement.classList.toggle('open')">
                <div class="student-meta"><span class="reg-number">#${s.student_number||s.id}</span><h3 class="student-name">${s.name}</h3></div>
                <div class="target-company"><i class="ri-community-line"></i> <span>${app.company?.name||'--'}</span></div>
                <div class="major-tag">${s.specialization||'--'}</div>
                <div class="row-actions">
                    <button class="action-icon approve" onclick="event.stopPropagation();updateRequestStatus(${app.id},'approved')"><i class="ri-check-fill"></i></button>
                    <button class="action-icon reject" onclick="event.stopPropagation();updateRequestStatus(${app.id},'rejected')"><i class="ri-close-fill"></i></button>
                </div>
            </div>
            <div class="row-details"><div class="details-inner"><div class="info-group">
                <span class="info-item"><i class="ri-user-smile-line"></i> ${s.username||'--'}</span>
                <span class="info-item"><i class="ri-phone-line"></i> ${s.phone||'--'}</span>
                <span class="info-item"><i class="ri-mail-line"></i> ${s.email||'--'}</span>
            </div></div></div>
        </div>`;
    }).join('');
}
async function updateRequestStatus(id, status) {
    if (!confirm(status === 'approved' ? 'قبول هذا الطلب؟' : 'رفض هذا الطلب؟')) return;
    await apiPut(`/student-requests/${id}/status`, { status });
    loadRequests();
}

// ═══════════════════════════════════════════════════════
// PAGE: Upload Students
// ═══════════════════════════════════════════════════════
function pageUpload(c) {
    c.innerHTML = `<div class="page-panel" style="max-width:600px;margin:40px auto;text-align:center;">
        <h2>تحميل قائمة الطلاب</h2><p style="color:#777;">ارفع ملف CSV أو Excel يحتوي على أرقام القيد وأسماء الطلاب</p>
        <div id="dropZone" style="border:2px dashed #6A5AE0;border-radius:20px;padding:50px;margin:20px 0;cursor:pointer;background:#faf9ff;" onclick="document.getElementById('fileInputUpload').click()">
            <i class="ri-upload-cloud-2-line" style="font-size:48px;color:#6A5AE0;"></i><p>اسحب الملف هنا أو اضغط للاختيار</p>
        </div>
        <input type="file" id="fileInputUpload" accept=".csv,.xlsx,.xls" style="display:none">
        <div id="uploadResult"></div>
    </div>`;
    document.getElementById('fileInputUpload').onchange = async (e) => {
        if (!e.target.files.length) return;
        const rd = document.getElementById('uploadResult');
        rd.innerHTML = '<p style="color:#6A5AE0;">جاري رفع الملف...</p>';
        const fd = new FormData(); fd.append('file', e.target.files[0]);
        const result = await apiPost('/students/upload', fd);
        if (result) rd.innerHTML = `<p style="color:#22c55e;font-weight:700;">${result.message}</p><p>تم إنشاء: ${result.data.created} | تم تخطي: ${result.data.skipped}</p>`;
        else rd.innerHTML = '<p style="color:red;">حدث خطأ في رفع الملف</p>';
    };
}

// ═══════════════════════════════════════════════════════
// PAGE: Student Reports
// ═══════════════════════════════════════════════════════
function pageReports(c) {
    c.innerHTML = `<div class="page-panel"><header class="page-header"><h1>تقارير الطلاب</h1></header><div class="reports-grid" id="reportsGrid"><p class="loading-text">جاري التحميل...</p></div></div>`;
    loadReports();
}
async function loadReports() {
    const result = await apiGet('/student-reports');
    const grid = document.getElementById('reportsGrid');
    if (!grid) return;
    if (!result?.data?.length) { grid.innerHTML = '<p class="empty-text">لا توجد تقارير</p>'; return; }
    grid.innerHTML = result.data.map(r => {
        const date = r.submitted_at ? new Date(r.submitted_at).toLocaleDateString('ar-LY') : '--';
        return `<div class="compact-card">
            <div class="card-top"><div class="student-avatar"><i class="ri-user-received-2-line"></i></div><div class="student-info"><h3>${r.student?.name||'--'}</h3><span>رقم القيد: ${r.student?.student_number||'--'}</span></div></div>
            <div class="report-item"><div class="report-meta"><i class="ri-file-text-line sc-color"></i><div class="report-details"><p>${r.title||r.report_type||'تقرير'}</p><small>استلم: ${date}</small></div></div>
            ${r.download_url ? `<a href="${r.download_url}" target="_blank" class="btn-dl"><i class="ri-download-2-line"></i></a>` : ''}</div>
            <button class="notify-btn" onclick="notifyReport(this,${r.id})"><i class="ri-send-plane-fill"></i><span>إبلاغ الطالب</span></button>
        </div>`;
    }).join('');
}
async function notifyReport(btn, id) {
    btn.disabled = true; btn.innerHTML = '<i class="ri-loader-4-line ri-spin"></i> جاري...';
    const r = await apiPost(`/student-reports/${id}/notify`, {});
    btn.innerHTML = r ? '<i class="ri-checkbox-circle-fill"></i> تم الإبلاغ' : '<i class="ri-error-warning-line"></i> فشل';
}

// ═══════════════════════════════════════════════════════
// PAGE: Student Evaluation
// ═══════════════════════════════════════════════════════
function pageEvaluation(c) {
    c.innerHTML = `<div class="page-panel"><header class="page-header"><h1>لوحة النتائج النهائية</h1>
        <div class="search-wrapper"><i class="ri-search-line"></i><input type="text" id="evalSearch" placeholder="ابحث باسم الطالب أو الشركة..." oninput="filterEvalCards()"></div></header>
        <div class="results-grid" id="resultsGrid"><p class="loading-text">جاري التحميل...</p></div></div>`;
    loadEvaluations();
}
async function loadEvaluations() {
    const result = await apiGet('/student-evaluations');
    const grid = document.getElementById('resultsGrid');
    if (!grid) return;
    if (!result?.data?.length) { grid.innerHTML = '<p class="empty-text">لا توجد نتائج</p>'; return; }
    grid.innerHTML = result.data.map(item => {
        const cPct = item.company_score > 0 ? Math.round((item.company_score/30)*100) : 0;
        const ePct = item.examiner_score > 0 ? Math.round((item.examiner_score/70)*100) : 0;
        return `<div class="student-card animate-in">
            <div class="card-main"><div class="student-info"><div class="avatar">${(item.student.name||'').charAt(0)}</div><div><h3>${item.student.name}</h3><span>رقم القيد: ${item.student.student_number||'--'}</span></div></div>
            <div class="company-info"><i class="ri-building-line"></i><span>${item.company.name}</span></div></div>
            <div class="card-stats"><div class="stat-item"><small>الشركة (30%)</small><div class="progress-bar"><div class="fill orange" style="width:${cPct}%"></div></div><strong>${item.company_weighted}</strong></div>
            <div class="stat-item"><small>الممتحن (70%)</small><div class="progress-bar"><div class="fill green" style="width:${ePct}%"></div></div><strong>${item.examiner_weighted}</strong></div></div>
            <div class="card-footer"><div class="final-score"><span class="label">المعدل النهائي</span><span class="value">${item.final_percentage}%</span></div></div>
        </div>`;
    }).join('');
}
function filterEvalCards() {
    const term = (document.getElementById('evalSearch')?.value || '').toLowerCase();
    document.querySelectorAll('#resultsGrid .student-card').forEach(card => {
        const text = card.textContent.toLowerCase();
        card.style.display = text.includes(term) ? '' : 'none';
    });
}

// ═══════════════════════════════════════════════════════
// PAGE: Company Offers
// ═══════════════════════════════════════════════════════
let _offersCache = [];
function pageCompanyOffers(c) {
    c.innerHTML = `<div class="page-panel"><header class="page-header"><h1>طلبات التدريب</h1><p>مراجعة عروض الشركات واتخاذ قرار القبول أو الرفض</p></header>
        <div id="offersGrid"><p class="loading-text">جاري التحميل...</p></div>
        <div id="formModal" class="modal-overlay" style="display:none"><div class="modal-box"><div class="modal-header"><h2 style="font-size:18px;margin:0;">تفاصيل طلب التدريب</h2><button class="close-btn" onclick="document.getElementById('formModal').style.display='none'"><i class="ri-close-line"></i></button></div><div id="modalContent" class="modal-body"></div></div></div>
    </div>`;
    loadCompanyOffers();
}
async function loadCompanyOffers() {
    const result = await apiGet('/company-offers');
    const grid = document.getElementById('offersGrid');
    if (!grid) return;
    _offersCache = result?.data || [];
    if (!_offersCache.length) { grid.innerHTML = '<p class="empty-text">لا توجد عروض معلقة</p>'; return; }
    grid.innerHTML = _offersCache.map(o => `
        <div class="modern-card" id="offer-${o.id}"><div class="card-status status-pending">قيد المراجعة</div>
        <div class="card-content"><h3>${o.company?.name||'--'}</h3><p><i class="ri-map-pin-line"></i> ${o.city||'--'} | <i class="ri-briefcase-line"></i> ${o.specialization||'--'} | <i class="ri-group-line"></i> ${o.seats_count||0} طلاب</p></div>
        <div class="card-actions"><button class="btn-view" onclick="showOfferDetails(${o.id})">عرض</button><button class="btn-primary" onclick="approveOffer(this,${o.id})">قبول</button><button class="btn-reject" onclick="rejectOffer(this,${o.id})">رفض</button></div></div>
    `).join('');
}
function showOfferDetails(id) {
    const o = _offersCache.find(x => x.id === id); if (!o) return;
    document.getElementById('modalContent').innerHTML = `<p><strong>الشركة:</strong> ${o.company?.name}</p><p><strong>الوصف:</strong> ${o.company?.description||'--'}</p><p><strong>الموقع:</strong> ${o.city||'--'}</p><p><strong>البريد:</strong> ${o.company?.email||'--'}</p><p><strong>التخصص:</strong> ${o.specialization||'--'}</p><p><strong>العدد:</strong> ${o.seats_count} طلاب</p><p><strong>المدة:</strong> ${o.duration_text||'--'}</p>`;
    document.getElementById('formModal').style.display = 'flex';
}
async function approveOffer(btn, id) {
    if (!confirm('تأكيد قبول العرض؟')) return;
    btn.disabled = true;
    await apiPut(`/company-offers/${id}/approve`, {});
    const card = document.getElementById(`offer-${id}`);
    if (card) { card.querySelector('.card-status').textContent = 'تم القبول'; card.querySelector('.card-status').className = 'card-status status-approved'; card.querySelector('.card-actions').innerHTML = '<span style="color:#33D69F;font-weight:bold;">تم القبول</span>'; }
}
async function rejectOffer(btn, id) {
    if (!confirm('تأكيد رفض العرض؟')) return;
    await apiPut(`/company-offers/${id}/reject`, {});
    const card = document.getElementById(`offer-${id}`);
    if (card) { card.style.opacity = '0.5'; card.querySelector('.card-status').textContent = 'تم الرفض'; card.querySelector('.card-actions').innerHTML = '<span style="color:#FF5B5B;font-weight:bold;">تم الرفض</span>'; }
}

// ═══════════════════════════════════════════════════════
// PAGE: Registered Companies
// ═══════════════════════════════════════════════════════
function pageRegisteredCompanies(c) {
    c.innerHTML = `<div class="page-panel"><header class="page-header"><h1>الشركات الشريكة <span class="count-badge" id="companyCount">0</span></h1></header><div class="companies-grid" id="companiesGrid"><p class="loading-text">جاري التحميل...</p></div></div>`;
    loadRegisteredCompanies();
}
async function loadRegisteredCompanies() {
    const result = await apiGet('/registered-companies');
    const grid = document.getElementById('companiesGrid');
    if (!grid) return;
    const data = result?.data || [];
    setText('companyCount', data.length);
    if (!data.length) { grid.innerHTML = '<p class="empty-text">لا توجد شركات</p>'; return; }
    const colors = ['linear-gradient(135deg,#6A5AE0,#8A7CF0)','linear-gradient(135deg,#00D084,#00A36C)','linear-gradient(135deg,#FF6FD8,#A033FF)','linear-gradient(135deg,#FF9F43,#FF6B6B)','linear-gradient(135deg,#0ABDE3,#48DBFB)'];
    grid.innerHTML = data.map((co, i) => `<div class="company-card"><div class="card-top"><div class="icon-box" style="background:${colors[i%colors.length]}">${(co.name||'').charAt(0)}</div><span class="verified-badge"><i class="ri-checkbox-circle-fill"></i> معتمدة</span></div><div class="company-info"><h3>${co.name}</h3><p><i class="ri-map-pin-2-fill"></i> ${co.city||'--'}</p></div><div class="card-stats"><div class="stat"><i class="ri-group-line"></i> متدربين: <strong>${co.internships_count}</strong></div></div></div>`).join('');
}

// ═══════════════════════════════════════════════════════
// PAGE: Company Accounts
// ═══════════════════════════════════════════════════════
let _companyAccountsCache = [];
function pageCompanyAccounts(c) {
    c.innerHTML = `<div class="page-panel"><header class="page-header"><h1>إدارة صلاحيات الشركات</h1>
        <div class="search-wrapper"><i class="ri-search-line"></i><input type="text" id="companySearch" placeholder="بحث عن شركة..." oninput="filterCompanyTable()"></div></header>
        <table class="styled-table"><thead><tr><th>الشركة</th><th>البريد</th><th>تاريخ الانضمام</th><th>الحالة</th><th>الإجراء</th></tr></thead><tbody id="companyTableBody"><tr><td colspan="5" class="loading-text">جاري التحميل...</td></tr></tbody></table></div>`;
    loadCompanyAccounts();
}
async function loadCompanyAccounts() {
    const result = await apiGet('/company-accounts');
    _companyAccountsCache = result?.data || [];
    renderCompanyTable(_companyAccountsCache);
}
function renderCompanyTable(data) {
    const tbody = document.getElementById('companyTableBody');
    if (!tbody) return;
    if (!data.length) { tbody.innerHTML = '<tr><td colspan="5" class="empty-text">لا توجد شركات</td></tr>'; return; }
    tbody.innerHTML = data.map(co => `<tr><td><strong>${co.name}</strong></td><td style="color:#6A5AE0">${co.email||'--'}</td><td>${co.created_at||'--'}</td><td><span class="status-pill ${co.is_active?'active':'inactive'}">${co.is_active?'نشط':'غير نشط'}</span></td><td><button onclick="toggleCompanyStatus(${co.id})" class="action-btn ${co.is_active?'btn-off':'btn-on'}">${co.is_active?'تعطيل':'تفعيل'}</button></td></tr>`).join('');
}
async function toggleCompanyStatus(id) {
    const r = await apiPut(`/company-accounts/${id}/toggle-status`, {});
    if (r) { const co = _companyAccountsCache.find(c => c.id === id); if (co) co.is_active = r.data.is_active; renderCompanyTable(_companyAccountsCache); }
}
function filterCompanyTable() {
    const term = (document.getElementById('companySearch')?.value || '').toLowerCase();
    renderCompanyTable(_companyAccountsCache.filter(c => (c.name||'').toLowerCase().includes(term)));
}

// ═══════════════════════════════════════════════════════
// PAGE: Examiner Accounts
// ═══════════════════════════════════════════════════════
let _examinersCache = [];
function pageExaminerAccounts(c) {
    c.innerHTML = `<div class="page-panel"><header class="page-header"><h1>إدارة حسابات الممتحنين</h1>
        <div class="search-wrapper"><i class="ri-search-line"></i><input type="text" id="examinerSearch" placeholder="ابحث عن ممتحن..." oninput="filterExaminersTable()"></div></header>
        <table class="styled-table"><thead><tr><th>الممتحن</th><th>البريد</th><th>الهاتف</th><th>الحالة</th><th>الإجراء</th></tr></thead><tbody id="examinersTable"><tr><td colspan="5" class="loading-text">جاري التحميل...</td></tr></tbody></table></div>`;
    loadExaminers();
}
async function loadExaminers() {
    const result = await apiGet('/examiners');
    _examinersCache = result?.data || [];
    renderExaminersTable(_examinersCache);
}
function renderExaminersTable(data) {
    const tbody = document.getElementById('examinersTable');
    if (!tbody) return;
    if (!data.length) { tbody.innerHTML = '<tr><td colspan="5" class="empty-text">لا يوجد ممتحنين</td></tr>'; return; }
    tbody.innerHTML = data.map(ex => `<tr><td class="user-cell">${ex.name}</td><td>${ex.email||'--'}</td><td>${ex.phone||'--'}</td><td><span class="status-badge ${ex.status==='active'?'active':'inactive'}">${ex.status==='active'?'نشط':'معطل'}</span></td><td><button class="toggle-btn" onclick="toggleExaminer(${ex.id})">${ex.status==='active'?'تعطيل':'تفعيل'}</button></td></tr>`).join('');
}
async function toggleExaminer(id) {
    const ex = _examinersCache.find(e => e.id === id);
    if (ex?.status === 'active' && !confirm(`تعطيل حساب ${ex.name}؟`)) return;
    await apiPut(`/examiners/${id}/toggle-status`, {});
    loadExaminers();
}
function filterExaminersTable() {
    const term = (document.getElementById('examinerSearch')?.value || '').toLowerCase();
    renderExaminersTable(_examinersCache.filter(e => (e.name||'').toLowerCase().includes(term) || (e.email||'').toLowerCase().includes(term)));
}

// ═══════════════════════════════════════════════════════
// PAGE: Transfer Reports
// ═══════════════════════════════════════════════════════
function pageTransferReports(c) {
    c.innerHTML = `<div class="page-panel"><header class="page-header"><h1>تحويل التقارير للممتحنين</h1></header><p class="empty-text">هذه الصفحة تحت التطوير - ستعمل عند وجود بيانات تدريب</p></div>`;
}

// ═══════════════════════════════════════════════════════
// PAGE: Receive Results
// ═══════════════════════════════════════════════════════
function pageReceiveResults(c) {
    c.innerHTML = `<div class="page-panel"><header class="page-header"><h1>استلام تقييمات الطلاب</h1>
        <div class="search-wrapper"><i class="ri-search-line"></i><input type="text" id="resultSearch" placeholder="ابحث بالاسم..." oninput="filterResultCards()"></div></header>
        <div class="results-grid" id="resultsContainer"><p class="loading-text">جاري التحميل...</p></div></div>`;
    loadResults();
}
async function loadResults() {
    const result = await apiGet('/evaluation-results');
    const grid = document.getElementById('resultsContainer');
    if (!grid) return;
    if (!result?.data?.length) { grid.innerHTML = '<p class="empty-text">لا توجد نتائج</p>'; return; }
    grid.innerHTML = result.data.map(ev => `<div class="student-card animate-in"><div class="card-main"><div class="student-info"><div class="avatar">${(ev.student_name||'').charAt(0)}</div><div><h3>${ev.student_name}</h3><span>رقم القيد: ${ev.student_number||'--'}</span></div></div><div class="company-info"><span class="badge">${ev.specialization||'--'}</span></div></div><div class="card-footer"><div class="final-score"><span class="label">الدرجة</span><span class="value">${ev.total_score}/70</span></div></div></div>`).join('');
}
function filterResultCards() {
    const term = (document.getElementById('resultSearch')?.value || '').toLowerCase();
    document.querySelectorAll('#resultsContainer .student-card').forEach(card => { card.style.display = card.textContent.toLowerCase().includes(term) ? '' : 'none'; });
}

// ═══════════════════════════════════════════════════════
// PAGE: Evaluation List
// ═══════════════════════════════════════════════════════
function pageEvaluationList(c) {
    c.innerHTML = `<div class="page-panel"><header class="page-header"><h1>قائمة تقييم الشركات</h1></header><div class="results-grid" id="evalListGrid"><p class="loading-text">جاري التحميل...</p></div></div>`;
    loadEvaluationList();
}
async function loadEvaluationList() {
    const result = await apiGet('/evaluation-list');
    const grid = document.getElementById('evalListGrid');
    if (!grid) return;
    if (!result?.data?.length) { grid.innerHTML = '<p class="empty-text">لا يوجد طلاب</p>'; return; }
    grid.innerHTML = result.data.map(s => `<div class="student-card animate-in"><div class="card-main"><div class="student-info"><div class="avatar">${(s.student_name||'').charAt(0)}</div><div><h3>${s.student_name}</h3><span>${s.student_number||'--'}</span></div></div><div class="company-info"><span>${s.company_name||'--'}</span></div></div><div class="card-footer"><span class="badge">${s.specialization||'--'}</span></div></div>`).join('');
}

// ═══════════════════════════════════════════════════════
// PAGE: Chat
// ═══════════════════════════════════════════════════════
let _chatUserId = null;
function pageChat(c) {
    c.innerHTML = `<div class="chat-main-container" style="display:flex;height:calc(100vh - 40px);gap:0;">
        <aside class="sidebar-users" style="width:280px;border-left:1px solid #eee;padding:15px;overflow-y:auto;">
            <input type="text" id="chatSearch" placeholder="ابحث عن مستخدم..." oninput="filterChatContacts()" style="width:100%;padding:10px;border:1px solid #eee;border-radius:10px;margin-bottom:10px;font-family:Cairo;">
            <div id="chatContactsList"><p class="loading-text">جاري التحميل...</p></div>
        </aside>
        <section style="flex:1;display:flex;flex-direction:column;">
            <header style="padding:15px;border-bottom:1px solid #eee;display:flex;align-items:center;gap:10px;"><div class="avatar" id="chatAvatar" style="width:40px;height:40px;border-radius:50%;background:#6A5AE0;color:#fff;display:flex;align-items:center;justify-content:center;">--</div><h4 id="chatName">اختر جهة اتصال</h4></header>
            <div id="chatMessages" style="flex:1;overflow-y:auto;padding:20px;"><p style="text-align:center;color:#aaa;padding:40px;">اختر جهة اتصال لبدء المحادثة</p></div>
            <footer style="padding:15px;border-top:1px solid #eee;display:flex;gap:10px;"><input type="text" id="chatMsgInput" placeholder="اكتب رسالتك..." style="flex:1;padding:10px;border:1px solid #eee;border-radius:10px;font-family:Cairo;" onkeypress="if(event.key==='Enter')sendChatMsg()"><button onclick="sendChatMsg()" style="background:#6A5AE0;color:#fff;border:none;padding:10px 20px;border-radius:10px;cursor:pointer;font-family:Cairo;">إرسال</button></footer>
        </section>
    </div>`;
    loadChatContacts();
}
async function loadChatContacts() {
    const result = await apiGet('/chat/contacts');
    const list = document.getElementById('chatContactsList');
    if (!list) return;
    if (!result?.data?.length) { list.innerHTML = '<p class="empty-text">لا يوجد مستخدمين</p>'; return; }
    list.innerHTML = result.data.map(u => `<div class="user-item" style="display:flex;align-items:center;gap:10px;padding:10px;border-radius:10px;cursor:pointer;margin-bottom:5px;" onmouseover="this.style.background='#f5f5ff'" onmouseout="this.style.background=''" onclick="openChatWith(${u.id},'${u.name}','${u.initials}')"><div class="avatar" style="width:35px;height:35px;border-radius:50%;background:#6A5AE0;color:#fff;display:flex;align-items:center;justify-content:center;font-size:14px;">${u.initials}</div><div><strong style="font-size:14px;">${u.name}</strong><br><small style="color:#999;">${u.role==='student'?'طالب':u.role==='examiner'?'ممتحن':'مشرف'}</small></div></div>`).join('');
}
async function openChatWith(userId, name, initials) {
    _chatUserId = userId;
    setText('chatName', name);
    const av = document.getElementById('chatAvatar'); if (av) av.textContent = initials;
    const msgs = document.getElementById('chatMessages');
    msgs.innerHTML = '<p class="loading-text">جاري التحميل...</p>';
    const result = await apiGet(`/chat/messages?user_id=${userId}`);
    msgs.innerHTML = '';
    if (result?.data?.length) {
        result.data.forEach(m => { msgs.innerHTML += `<div style="padding:8px 15px;border-radius:15px;margin:5px 0;max-width:70%;${m.is_mine?'background:#6A5AE0;color:#fff;margin-right:auto;':'background:#f0f0f0;margin-left:auto;'}">${m.body}</div>`; });
    } else { msgs.innerHTML = '<p style="text-align:center;color:#aaa;">ابدأ المحادثة...</p>'; }
    msgs.scrollTop = msgs.scrollHeight;
}
async function sendChatMsg() {
    const input = document.getElementById('chatMsgInput');
    const body = input.value.trim(); if (!body || !_chatUserId) return;
    input.value = '';
    const msgs = document.getElementById('chatMessages');
    const p = msgs.querySelector('p'); if (p) p.remove();
    msgs.innerHTML += `<div style="padding:8px 15px;border-radius:15px;margin:5px 0;max-width:70%;background:#6A5AE0;color:#fff;margin-right:auto;">${body}</div>`;
    msgs.scrollTop = msgs.scrollHeight;
    await apiPost('/chat/messages', { user_id: _chatUserId, body, type: 'text' });
}
function filterChatContacts() {
    const term = (document.getElementById('chatSearch')?.value || '').toLowerCase();
    document.querySelectorAll('#chatContactsList .user-item').forEach(el => { el.style.display = el.textContent.toLowerCase().includes(term) ? 'flex' : 'none'; });
}

// ═══════════════════════════════════════════════════════
// PAGE: System Reports
// ═══════════════════════════════════════════════════════
function pageSystemReports(c) {
    c.innerHTML = `<div class="page-panel">
        <header class="page-header"><h1>مركز تقارير النظام</h1></header>
        <div class="toolbar" style="display:flex;gap:15px;flex-wrap:wrap;margin-bottom:20px;">
            <select id="reportType" style="padding:10px;border-radius:10px;border:1px solid #ddd;font-family:Cairo;"><option value="students">قائمة الطلاب</option><option value="companies">الشركات</option><option value="examiners">الممتحنين</option></select>
            <select id="deptFilter" style="padding:10px;border-radius:10px;border:1px solid #ddd;font-family:Cairo;"><option value="all">كل التخصصات</option><option value="حاسب آلي">حاسب آلي</option><option value="اتصالات">اتصالات</option></select>
            <button onclick="generateReport()" style="background:#6A5AE0;color:#fff;border:none;padding:10px 25px;border-radius:10px;cursor:pointer;font-family:Cairo;"><i class="ri-refresh-line"></i> عرض البيانات</button>
        </div>
        <table class="styled-table"><thead><tr id="reportHead"><th>-</th></tr></thead><tbody id="reportBody"><tr><td style="text-align:center;padding:40px;color:#aaa;">اضغط "عرض البيانات"</td></tr></tbody></table>
    </div>`;
}
async function generateReport() {
    const type = document.getElementById('reportType').value;
    const dept = document.getElementById('deptFilter').value;
    const result = await apiGet(`/system-reports?reportType=${type}&dept=${dept}`);
    const thead = document.getElementById('reportHead');
    const tbody = document.getElementById('reportBody');
    if (!result) return;
    if (result.columns) thead.innerHTML = result.columns.map(c => `<th>${c}</th>`).join('');
    if (result.data?.length) tbody.innerHTML = result.data.map(row => `<tr>${Object.values(row).map(v => `<td>${v}</td>`).join('')}</tr>`).join('');
    else tbody.innerHTML = `<tr><td colspan="${result.columns?.length||5}" style="text-align:center;padding:20px;">لا توجد بيانات</td></tr>`;
}

// ═══════════════════════════════════════════════════════
// PAGE: Discussion Schedule
// ═══════════════════════════════════════════════════════
function pageDiscussionSchedule(c) {
    c.innerHTML = `<div class="page-panel">
        <header class="page-header"><h1>إرسال جدول المناقشة</h1></header>
        <div style="max-width:600px;margin:0 auto;">
            <div style="border:2px dashed #6A5AE0;border-radius:20px;padding:40px;text-align:center;cursor:pointer;background:#faf9ff;margin-bottom:20px;" onclick="document.getElementById('scheduleFileInput').click()">
                <img id="schedulePreview" style="max-width:100%;border-radius:10px;display:none;margin-bottom:10px;">
                <p id="scheduleUploadText"><i class="ri-upload-cloud-2-line" style="font-size:40px;color:#6A5AE0;display:block;"></i>اضغط لرفع صورة الجدول</p>
            </div>
            <input type="file" id="scheduleFileInput" accept="image/*" style="display:none" onchange="previewScheduleImage(this)">
            <div style="display:flex;gap:10px;margin-bottom:15px;">
                <button class="target-btn" id="tgExaminers" onclick="toggleScheduleTarget('examiners',this)" style="flex:1;padding:10px;border:2px solid #ddd;border-radius:10px;cursor:pointer;font-family:Cairo;background:white;">الممتحنين</button>
                <button class="target-btn" id="tgStudents" onclick="toggleScheduleTarget('students',this)" style="flex:1;padding:10px;border:2px solid #ddd;border-radius:10px;cursor:pointer;font-family:Cairo;background:white;">الطلاب</button>
            </div>
            <textarea id="scheduleMessage" placeholder="رسالة مرفقة (اختياري)..." style="width:100%;padding:15px;border:1px solid #ddd;border-radius:10px;min-height:80px;font-family:Cairo;margin-bottom:15px;"></textarea>
            <button onclick="sendSchedule()" style="width:100%;background:#6A5AE0;color:#fff;border:none;padding:15px;border-radius:10px;font-size:16px;cursor:pointer;font-family:Cairo;">إرسال الجدول</button>
        </div>
    </div>`;
}
let _scheduleFile = null, _scheduleTargets = [];
function previewScheduleImage(input) {
    _scheduleFile = input.files[0]; if (!_scheduleFile) return;
    const reader = new FileReader(); reader.onload = () => { const img = document.getElementById('schedulePreview'); img.src = reader.result; img.style.display = 'block'; document.getElementById('scheduleUploadText').textContent = 'تم اختيار الصورة'; }; reader.readAsDataURL(_scheduleFile);
}
function toggleScheduleTarget(target, btn) {
    const idx = _scheduleTargets.indexOf(target);
    if (idx >= 0) { _scheduleTargets.splice(idx, 1); btn.style.background = 'white'; btn.style.borderColor = '#ddd'; btn.style.color = '#333'; }
    else { _scheduleTargets.push(target); btn.style.background = '#6A5AE0'; btn.style.borderColor = '#6A5AE0'; btn.style.color = '#fff'; }
}
async function sendSchedule() {
    if (!_scheduleFile) { alert('ارفع صورة الجدول أولاً'); return; }
    if (!_scheduleTargets.length) { alert('حدد المستلمين'); return; }
    const fd = new FormData(); fd.append('image', _scheduleFile); _scheduleTargets.forEach(t => fd.append('targets[]', t)); fd.append('message', document.getElementById('scheduleMessage').value);
    const r = await apiPost('/discussion-schedules', fd);
    if (r) alert(r.message || 'تم الإرسال بنجاح');
}

// ─── Utilities ──────────────────────────────────────────
function setText(id, value) {
    const el = document.getElementById(id);
    if (el) el.textContent = value;
}
