window.onload = () => {
    const homeMenu = document.querySelector('.menu-item');
    loadExaminerContent('home', homeMenu);
};

async function handleExaminerLogout() {
    try { await apiPost('/logout', {}); } catch (e) { /* ignore */ }
    clearAuth();
    window.location.href = 'index.html';
}

function loadExaminerContent(type, element) {
    const mainArea = document.getElementById('mainArea');

    document.querySelectorAll('.menu-item').forEach(item => item.classList.remove('active'));
    element.classList.add('active');

    mainArea.style.opacity = '0';

    setTimeout(async () => {
        let htmlContent = '';

        switch (type) {
            case 'home':
                htmlContent = await buildHomeDashboard();
                break;
            case 'reports':
                htmlContent = `<iframe src="Examiner_Reports.html" class="full-frame animate-fade"></iframe>`;
                break;
            case 'grades':
                htmlContent = `<iframe src="Examiner_Grades.html" class="full-frame animate-fade"></iframe>`;
                break;
            case 'schedule':
                htmlContent = `
                    <div class="dashboard-wrapper animate-fade" style="height: 100%;">
                        <iframe src="Discussion_Schedule.html"
                            style="width: 100%; height: 85vh; border: none; border-radius: 25px; box-shadow: 0 10px 30px rgba(0,0,0,0.05);"
                            title="جدول المناقشات">
                        </iframe>
                    </div>`;
                break;
        }

        mainArea.innerHTML = htmlContent;
        mainArea.style.opacity = '1';
    }, 200);
}

async function buildHomeDashboard() {
    const user = getUser();
    const userName = user?.name || 'الممتحن';
    const today = new Date().toLocaleDateString('ar-LY', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });

    let evaluatedCount = '--';
    let pendingReports = '--';
    let avgScore = '--';
    let alertsHtml = '';
    let scheduleRows = '';

    try {
        const result = await apiGet('/examiner/dashboard');
        if (result && result.data) {
            const d = result.data;
            evaluatedCount = d.evaluated_count;
            pendingReports = d.pending_reports;
            avgScore = d.average_score;

            if (d.alerts && d.alerts.length > 0) {
                alertsHtml = d.alerts.map(a => `
                    <div class="alert-box ${a.type === 'evaluation' ? 'green' : 'red'}">
                        <strong>${a.title}</strong><p>${a.body}</p>
                    </div>
                `).join('');
            } else {
                alertsHtml = '<p style="color:#aaa; text-align:center;">لا توجد تنبيهات</p>';
            }

            if (d.today_discussions && d.today_discussions.length > 0) {
                scheduleRows = d.today_discussions.map((disc, i) => `
                    <tr ${i >= 2 ? 'class="extra-row"' : ''}>
                        <td>${disc.student_name || '--'}</td>
                        <td>${disc.time || '--'}</td>
                        <td>${disc.location || '--'}</td>
                        <td><span class="badge ${i === 0 ? 'now' : 'wait'}">${i === 0 ? 'جاري الآن' : 'بانتظار'}</span></td>
                    </tr>
                `).join('');
            } else {
                scheduleRows = '<tr><td colspan="4" style="text-align:center; color:#aaa;">لا توجد مناقشات اليوم</td></tr>';
            }
        }
    } catch (e) {
        console.error('Failed to load examiner dashboard:', e);
    }

    const discussionCount = scheduleRows.includes('لا توجد') ? 0 : (scheduleRows.match(/<tr/g) || []).length;

    return `
        <div class="dashboard-wrapper animate-fade">
            <div class="welcome-banner">
                <div class="welcome-text">
                    <h1>أهلاً بك، ${userName} 👋</h1>
                    <p>لديك اليوم <b>${discussionCount} مناقشات</b> مجدولة و <b>${pendingReports} تقريراً</b> بانتظار التقييم.</p>
                </div>
                <div class="date-badge"><i class="ri-calendar-line"></i> ${today}</div>
            </div>

            <div class="stats-row">
                <div class="mini-stat-card">
                    <div class="stat-icon-box purple"><i class="ri-group-line"></i></div>
                    <div class="stat-val"><h3>${evaluatedCount}</h3><p>طلاب تم تقييمهم</p></div>
                </div>
                <div class="mini-stat-card">
                    <div class="stat-icon-box orange"><i class="ri-file-warning-line"></i></div>
                    <div class="stat-val"><h3>${pendingReports}</h3><p>تقارير معلقة</p></div>
                </div>
                <div class="mini-stat-card">
                    <div class="stat-icon-box green"><i class="ri-medal-2-line"></i></div>
                    <div class="stat-val"><h3>${avgScore}</h3><p>متوسط الدرجات</p></div>
                </div>
            </div>

            <div class="bottom-grid">
                <div class="alerts-section">
                    <div class="section-title">تنبيهات هامة</div>
                    ${alertsHtml}
                </div>

                <div class="schedule-section">
                    <div class="section-header">
                        <div class="section-title">جدول مناقشات اليوم</div>
                        <button class="text-btn" onclick="toggleFullTable()">عرض الكل</button>
                    </div>
                    <table class="home-table">
                        <thead><tr><th>الطالب</th><th>الوقت</th><th>القاعة</th><th>الحالة</th></tr></thead>
                        <tbody>${scheduleRows}</tbody>
                    </table>
                </div>
            </div>
        </div>`;
}

function toggleFullTable() {
    const extraRows = document.querySelectorAll('.extra-row');
    const btn = document.querySelector('.text-btn');
    if (!extraRows.length) return;

    const isHidden = extraRows[0].style.display === '' || extraRows[0].style.display === 'none';
    extraRows.forEach(row => row.style.display = isHidden ? 'table-row' : 'none');
    btn.innerText = isHidden ? 'عرض أقل' : 'عرض الكل';
}
