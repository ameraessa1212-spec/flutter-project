/**
 * Examiner Dashboard SPA
 */

document.addEventListener('DOMContentLoaded', () => {
    if (!requireAuth()) return;
    loadExaminerPage('home', document.querySelector('.menu-item'));
});

async function handleExaminerLogout() {
    try { await apiPost('/logout', {}); } catch (e) { /* ignore */ }
    clearAuth();
    window.location.href = 'index.html';
}

function loadExaminerPage(type, element) {
    const mainArea = document.getElementById('mainArea');
    document.querySelectorAll('.menu-item').forEach(i => i.classList.remove('active'));
    if (element) element.classList.add('active');

    mainArea.style.opacity = '0';
    setTimeout(() => {
        switch (type) {
            case 'home': examinerHome(mainArea); break;
            case 'reports': examinerReports(mainArea); break;
            case 'grades': examinerGrades(mainArea); break;
            case 'schedule': examinerSchedule(mainArea); break;
        }
        mainArea.style.opacity = '1';
    }, 150);
}

// ═══════════════════════════════════════════════════════
// Examiner Home
// ═══════════════════════════════════════════════════════
async function examinerHome(c) {
    const user = getUser();
    const today = new Date().toLocaleDateString('ar-LY', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });

    c.innerHTML = `<div class="dashboard-wrapper animate-fade"><div class="welcome-banner"><div class="welcome-text"><h1>أهلاً بك، ${user?.name || 'الممتحن'}</h1><p>جاري تحميل البيانات...</p></div><div class="date-badge"><i class="ri-calendar-line"></i> ${today}</div></div>
        <div class="stats-row"><div class="mini-stat-card"><div class="stat-icon-box purple"><i class="ri-group-line"></i></div><div class="stat-val"><h3 id="ex-evaluated">--</h3><p>طلاب تم تقييمهم</p></div></div>
        <div class="mini-stat-card"><div class="stat-icon-box orange"><i class="ri-file-warning-line"></i></div><div class="stat-val"><h3 id="ex-pending">--</h3><p>تقارير معلقة</p></div></div>
        <div class="mini-stat-card"><div class="stat-icon-box green"><i class="ri-medal-2-line"></i></div><div class="stat-val"><h3 id="ex-avg">--</h3><p>متوسط الدرجات</p></div></div></div>
        <div class="bottom-grid"><div class="alerts-section"><div class="section-title">تنبيهات</div><div id="ex-alerts"><p style="color:#aaa;text-align:center;">جاري التحميل...</p></div></div>
        <div class="schedule-section"><div class="section-title">جدول مناقشات اليوم</div><table class="home-table"><thead><tr><th>الطالب</th><th>الوقت</th><th>القاعة</th></tr></thead><tbody id="ex-schedule"><tr><td colspan="3" style="text-align:center;color:#aaa;">جاري التحميل...</td></tr></tbody></table></div></div></div>`;

    const result = await apiGet('/examiner/dashboard');
    if (!result?.data) return;
    const d = result.data;

    const el = (id) => document.getElementById(id);
    if (el('ex-evaluated')) el('ex-evaluated').textContent = d.evaluated_count;
    if (el('ex-pending')) el('ex-pending').textContent = d.pending_reports;
    if (el('ex-avg')) el('ex-avg').textContent = d.average_score;

    // Update welcome text
    const welcome = c.querySelector('.welcome-text p');
    if (welcome) welcome.textContent = `لديك اليوم ${d.today_discussions?.length || 0} مناقشات و ${d.pending_reports} تقريراً بانتظار التقييم.`;

    // Alerts
    const alertsDiv = el('ex-alerts');
    if (alertsDiv) {
        if (d.alerts?.length) alertsDiv.innerHTML = d.alerts.map(a => `<div class="alert-box">${a.title}: ${a.body}</div>`).join('');
        else alertsDiv.innerHTML = '<p style="color:#aaa;text-align:center;">لا توجد تنبيهات</p>';
    }

    // Schedule
    const scheduleBody = el('ex-schedule');
    if (scheduleBody) {
        if (d.today_discussions?.length) scheduleBody.innerHTML = d.today_discussions.map(disc => `<tr><td>${disc.student_name || '--'}</td><td>${disc.time || '--'}</td><td>${disc.location || '--'}</td></tr>`).join('');
        else scheduleBody.innerHTML = '<tr><td colspan="3" style="text-align:center;color:#aaa;">لا توجد مناقشات اليوم</td></tr>';
    }
}

// ═══════════════════════════════════════════════════════
// Examiner Reports
// ═══════════════════════════════════════════════════════
async function examinerReports(c) {
    c.innerHTML = `<div class="page-panel"><header style="margin-bottom:20px;"><h1>تقارير الطلاب</h1></header><div class="reports-grid" id="exReportsGrid"><p class="loading-text">جاري التحميل...</p></div></div>`;
    const user = getUser();
    const result = await apiGet(`/examiners/${user?.id}/reports`);
    const grid = document.getElementById('exReportsGrid');
    if (!grid) return;
    if (!result?.data?.length) { grid.innerHTML = '<p class="empty-text">لا توجد تقارير</p>'; return; }
    grid.innerHTML = result.data.map(r => `<div class="compact-card"><div class="card-top"><div class="student-avatar"><i class="ri-user-received-2-line"></i></div><div class="student-info"><h3>${r.student_name || '--'}</h3><span>رقم القيد: ${r.student_number || '--'}</span></div></div><div class="report-item"><div class="report-meta"><i class="ri-file-text-line" style="color:#6A5AE0;"></i><div class="report-details"><p>${r.title || 'تقرير'}</p><small>استلم: ${r.submitted_at || '--'}</small></div></div>${r.download_url ? `<a href="${r.download_url}" target="_blank" class="btn-dl"><i class="ri-download-2-line"></i></a>` : ''}</div></div>`).join('');
}

// ═══════════════════════════════════════════════════════
// Examiner Grades
// ═══════════════════════════════════════════════════════
let _examStudents = [];
async function examinerGrades(c) {
    c.innerHTML = `<div class="page-panel"><header style="margin-bottom:20px;"><h1>نتائج التقييم</h1></header>
        <table class="styled-table"><thead><tr><th>الطالب</th><th>رقم القيد</th><th>الحالة</th><th>الإجراء</th></tr></thead><tbody id="gradesList"><tr><td colspan="4" class="loading-text">جاري التحميل...</td></tr></tbody></table>
        <div id="gradeModal" class="modal"><div class="modal-content"><div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;"><h2>تقييم الطالب: <span id="gradeStudentName"></span></h2><button onclick="document.getElementById('gradeModal').style.display='none'" style="background:none;border:none;font-size:20px;cursor:pointer;">&times;</button></div>
        <form id="gradeForm" onsubmit="submitExaminerGrade(event)">
            <input type="hidden" id="gradeDiscussionId">
            <fieldset style="border:1px solid #eee;border-radius:10px;padding:15px;margin-bottom:10px;"><legend style="font-weight:700;">المجال المعرفي (15)</legend><div style="display:flex;flex-wrap:wrap;gap:10px;"><input type="number" name="knowledge_1" placeholder="(3)" min="0" max="3" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="knowledge_2" placeholder="(3)" min="0" max="3" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="knowledge_3" placeholder="(3)" min="0" max="3" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="knowledge_4" placeholder="(3)" min="0" max="3" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="knowledge_5" placeholder="(3)" min="0" max="3" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"></div></fieldset>
            <fieldset style="border:1px solid #eee;border-radius:10px;padding:15px;margin-bottom:10px;"><legend style="font-weight:700;">القدرات والمهارات (10)</legend><div style="display:flex;flex-wrap:wrap;gap:10px;"><input type="number" name="skills_1" placeholder="(3)" min="0" max="3" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="skills_2" placeholder="(3)" min="0" max="3" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="skills_3" placeholder="(2)" min="0" max="2" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="skills_4" placeholder="(2)" min="0" max="2" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"></div></fieldset>
            <fieldset style="border:1px solid #eee;border-radius:10px;padding:15px;margin-bottom:10px;"><legend style="font-weight:700;">التوثيق (15)</legend><div style="display:flex;flex-wrap:wrap;gap:10px;"><input type="number" name="doc_1" placeholder="(4)" min="0" max="4" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="doc_2" placeholder="(4)" min="0" max="4" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="doc_3" placeholder="(4)" min="0" max="4" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="doc_4" placeholder="(3)" min="0" max="3" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"></div></fieldset>
            <fieldset style="border:1px solid #eee;border-radius:10px;padding:15px;margin-bottom:10px;"><legend style="font-weight:700;">المناقشة (15)</legend><div style="display:flex;flex-wrap:wrap;gap:10px;"><input type="number" name="disc_1" placeholder="(5)" min="0" max="5" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="disc_2" placeholder="(5)" min="0" max="5" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="disc_3" placeholder="(5)" min="0" max="5" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"></div></fieldset>
            <fieldset style="border:1px solid #eee;border-radius:10px;padding:15px;margin-bottom:15px;"><legend style="font-weight:700;">البحث العلمي (15)</legend><div style="display:flex;flex-wrap:wrap;gap:10px;"><input type="number" name="research_1" placeholder="(3)" min="0" max="3" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="research_2" placeholder="(2)" min="0" max="2" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="research_3" placeholder="(3)" min="0" max="3" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="research_4" placeholder="(3)" min="0" max="3" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"><input type="number" name="research_5" placeholder="(4)" min="0" max="4" style="width:60px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;"></div></fieldset>
            <div style="display:flex;justify-content:space-between;align-items:center;"><span style="font-size:18px;font-weight:700;">المجموع: <span id="gradeTotal" style="color:#6A5AE0;">0</span>/70</span><button type="submit" style="background:#6A5AE0;color:#fff;border:none;padding:12px 30px;border-radius:10px;cursor:pointer;font-family:Cairo;font-weight:700;">حفظ التقييم</button></div>
        </form></div></div>
    </div>`;

    // Auto-calculate total
    document.getElementById('gradeForm').addEventListener('input', () => {
        let total = 0;
        document.querySelectorAll('#gradeForm input[type="number"]').forEach(i => total += Number(i.value) || 0);
        document.getElementById('gradeTotal').textContent = total;
    });

    const result = await apiGet('/examiner/students');
    _examStudents = result?.data || [];
    const tbody = document.getElementById('gradesList');
    if (!tbody) return;
    if (!_examStudents.length) { tbody.innerHTML = '<tr><td colspan="4" class="empty-text">لا يوجد طلاب</td></tr>'; return; }
    tbody.innerHTML = _examStudents.map(s => `<tr><td><strong>${s.student_name}</strong></td><td>${s.student_number || '--'}</td><td><span class="status-tag">${s.status}</span></td><td><button class="eval-btn" onclick="openGradeModal(${s.id},'${s.student_name}')">رصد الدرجات</button></td></tr>`).join('');
}

function openGradeModal(discussionId, name) {
    document.getElementById('gradeStudentName').textContent = name;
    document.getElementById('gradeDiscussionId').value = discussionId;
    document.getElementById('gradeForm').reset();
    document.getElementById('gradeTotal').textContent = '0';
    document.getElementById('gradeModal').style.display = 'flex';
}

async function submitExaminerGrade(e) {
    e.preventDefault();
    const discussionId = Number(document.getElementById('gradeDiscussionId').value);
    const rubric = {};
    let total = 0;
    document.querySelectorAll('#gradeForm input[type="number"]').forEach(i => {
        const v = Number(i.value) || 0; rubric[i.name] = v; total += v;
    });
    const result = await apiPost('/examiner/grades', { examiner_discussion_id: discussionId, rubric_scores: rubric, total_score: total });
    if (result) {
        alert(result.message || 'تم الحفظ');
        document.getElementById('gradeModal').style.display = 'none';
        // Update status in table
        const s = _examStudents.find(x => x.id === discussionId);
        if (s) s.status = `تم التقييم (${total}/70)`;
        const tbody = document.getElementById('gradesList');
        if (tbody) tbody.innerHTML = _examStudents.map(s => `<tr><td><strong>${s.student_name}</strong></td><td>${s.student_number || '--'}</td><td><span class="status-tag">${s.status}</span></td><td><button class="eval-btn" onclick="openGradeModal(${s.id},'${s.student_name}')">رصد الدرجات</button></td></tr>`).join('');
    }
}

// ═══════════════════════════════════════════════════════
// Examiner Schedule
// ═══════════════════════════════════════════════════════
async function examinerSchedule(c) {
    c.innerHTML = `<div class="page-panel"><header style="margin-bottom:20px;"><h1>جدول المناقشة</h1></header><div id="scheduleContent"><p class="loading-text">جاري التحميل...</p></div></div>`;
    const result = await apiGet('/discussion-schedules');
    const div = document.getElementById('scheduleContent');
    if (!div) return;
    if (result?.data?.length && result.data[0].image_url) {
        div.innerHTML = `<img src="${result.data[0].image_url}" style="max-width:100%;border-radius:15px;box-shadow:0 5px 20px rgba(0,0,0,0.1);">`;
    } else {
        div.innerHTML = '<p class="empty-text">لا يوجد جدول منشور حالياً</p>';
    }
}
