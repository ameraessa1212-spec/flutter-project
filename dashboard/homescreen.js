document.addEventListener('DOMContentLoaded', () => {
    loadDashboardStats();
    loadChartData();
    loadAlerts();
});

async function loadDashboardStats() {
    try {
        const result = await apiGet('/dashboard/stats');
        if (result && result.data) {
            document.getElementById('stat-students').textContent = result.data.total_students;
            document.getElementById('stat-trainees').textContent = result.data.active_trainees;
            document.getElementById('stat-companies').textContent = result.data.total_companies;
            document.getElementById('stat-pending').textContent = String(result.data.pending_requests).padStart(2, '0');
        }
    } catch (e) {
        console.error('Failed to load stats:', e);
    }
}

async function loadChartData() {
    try {
        const result = await apiGet('/dashboard/chart-data');
        if (result && result.data) {
            initChart(result.data.labels, result.data.values);
        } else {
            initChart([], []);
        }
    } catch (e) {
        console.error('Failed to load chart:', e);
        initChart([], []);
    }
}

async function loadAlerts() {
    try {
        const result = await apiGet('/dashboard/alerts');
        const container = document.getElementById('alerts-container');
        if (result && result.data && result.data.length > 0) {
            container.innerHTML = result.data.map(alert => {
                const icon = alert.type === 'danger' ? 'ri-error-warning-line' : 'ri-mail-line';
                return `<div class="alert-item ${alert.type}">
                    <i class="${icon}"></i>
                    <div><strong>${alert.title}</strong><small>${alert.message}</small></div>
                </div>`;
            }).join('');
        } else {
            container.innerHTML = '<p style="color:#aaa; text-align:center;">لا توجد تنبيهات حالياً</p>';
        }
    } catch (e) {
        console.error('Failed to load alerts:', e);
    }
}

// دالة تفعيل العناصر في القائمة
function setActive(element) {
    if (element.innerText.trim().includes("الرئيسية")) {
        location.reload(); 
        return;
    }
    document.querySelectorAll(".menu-item").forEach(item => item.classList.remove("active"));
    element.classList.add("active");
}

// دالة فتح القوائم المنسدلة 
function toggleMenu(element) {
    document.querySelectorAll(".menu-item").forEach(item => {
        if(item !== element) item.classList.remove("open");
    });
    element.classList.toggle("open");
}

// --- الدوال الخاصة بتحميل الصفحات (الإطارات) ---

// دالة تحميل صفحة الشركات المسجلة (الإضافة الجديدة)
function loadRegisteredCompaniesPage(event) {
    if(event) event.stopPropagation();
    const mainArea = document.getElementById('mainArea');
    mainArea.innerHTML = `
        <div class="dashboard-card-wrapper" style="height: 100%; padding: 0; overflow: hidden; border:none;">
            <iframe src="Registered_Companies.html" 
                    style="width: 100%; height: 100%; border: none; background: #f8f9fd; border-radius: 40px;">
            </iframe>
        </div>
    `;
}

// دالة تحميل صفحة عروض الشركات
function loadCompanyOffersPage(event) {
    if(event) event.stopPropagation();
    const mainArea = document.getElementById('mainArea');
    mainArea.innerHTML = `
        <div class="dashboard-card-wrapper" style="height: 100%; padding: 0; overflow: hidden; border:none;">
            <iframe src="Company_Offers.html" 
                    style="width: 100%; height: 100%; border: none; background: white; border-radius: 40px;">
            </iframe>
        </div>
    `;
}

// دالة تحميل صفحة نتيجة الطالب (التقييم)
function loadEvaluationPage(event) {
    if(event) event.stopPropagation();
    const mainArea = document.getElementById('mainArea');
    mainArea.innerHTML = `
        <div class="dashboard-card-wrapper" style="height: 100%; padding: 0; overflow: hidden; border:none;">
            <iframe src="student_evaluation.html" 
                    style="width: 100%; height: 100%; border: none; background: #fbfaff; border-radius: 40px;">
            </iframe>
        </div>
    `;
}

// دالة تحميل صفحة التقارير
function loadReportsPage(event) {
    if(event) event.stopPropagation();
    const mainArea = document.getElementById('mainArea');
    mainArea.innerHTML = `
        <div class="dashboard-card-wrapper" style="height: 100%; padding: 0; overflow: hidden; border:none;">
            <iframe src="reports.html" style="width: 100%; height: 100%; border: none; background: #fbfcff; border-radius: 40px;"></iframe>
        </div>`;
}

// دالة تحميل صفحة تحميل الطلاب
function loadUploadPage(event) {
    if(event) event.stopPropagation();
    const mainArea = document.getElementById('mainArea');
    mainArea.innerHTML = `<div class="dashboard-card-wrapper" style="height: 100%; padding: 0; overflow: hidden; border:none;"><iframe src="upload_students.html" style="width: 100%; height: 100%; border: none; background: white; border-radius: 40px;"></iframe></div>`;
}

// دالة تحميل صفحة عرض بيانات الطلاب (الطلبات)
function loadRequestsPage(event) {
    if(event) event.stopPropagation();
    const mainArea = document.getElementById('mainArea');
    mainArea.innerHTML = `<div class="dashboard-card-wrapper" style="height: 100%; padding: 0; overflow: hidden; border:none;"><iframe src="requests.html" style="width: 100%; height: 100%; border: none; background: #FBFAFF; border-radius: 40px;"></iframe></div>`;
}

// دالة تشغيل الرسم البياني
function initChart(labels = [], data = []) {
    const canvas = document.getElementById('mainChart');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (window.myChart) window.myChart.destroy();
    window.myChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'عدد الطلاب',
                data: data,
                backgroundColor: '#6A5AE0',
                borderRadius: 10,
                barThickness: 45
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, grid: { color: '#f5f5f5' } },
                x: { grid: { display: false } }
            }
        }
    });
}
// دالة تحميل قائمة اختيار الطلاب للتقييم
function loadEvaluationListPage(event) {
    if(event) event.stopPropagation();
    const mainArea = document.getElementById('mainArea');
    mainArea.innerHTML = `
        <div class="dashboard-card-wrapper page-transition" style="height: 100%; padding: 0; overflow: hidden; border:none;">
            <iframe src="Evaluation_List.html" 
                    style="width: 100%; height: 100%; border: none; background: #fbfaff; border-radius: 40px;"
                    onload="this.style.opacity=1">
            </iframe>
        </div>
    `;
}
function loadCompanyAccountsPage(event) {
    if (event) event.preventDefault();
    // إذا كنتِ تستخدمين نظام الـ Content Loader:
    const mainArea = document.getElementById('mainArea');
    mainArea.innerHTML = `<iframe src="Company_Accounts.html" style="width:100%; height:100vh; border:none;"></iframe>`;
}
// دالة تحميل صفحة الدردشة (الشات)
function loadChatPage(event) {
    if(event) event.stopPropagation();
    const mainArea = document.getElementById('mainArea');
    mainArea.innerHTML = `
        <div class="dashboard-card-wrapper" style="height: 100%; padding: 0; overflow: hidden; border:none;">
            <iframe src="chat.html" 
                    style="width: 100%; height: 100%; border: none; background: white; border-radius: 40px;">
            </iframe>
        </div>
    `;
}

// دالة تحميل صفحة إدارة الحسابات
function loadAccountsPage(event) {
    if(event) event.stopPropagation();
    const mainArea = document.getElementById('mainArea');
    mainArea.innerHTML = `
        <div class="dashboard-card-wrapper" style="height: 100%; padding: 0; overflow: hidden; border:none;">
            <iframe src="accounts.html" 
                    style="width: 100%; height: 100%; border: none; background: #f8f9fd; border-radius: 40px;">
            </iframe>
        </div>
    `;
}
// دالة فتح واجهة تحويل التقارير داخل المربع الرئيسي
function loadTransferReportsPage(event) {
    // منع إغلاق القائمة المنسدلة عند النقر
    if(event) event.stopPropagation(); 
    
    const mainArea = document.getElementById('mainArea');
    
    // استبدال المحتوى بـ iframe يعرض صفحة تحويل التقارير
    mainArea.innerHTML = `
        <div class="dashboard-card-wrapper" style="height: 100%; padding: 0; overflow: hidden; border:none;">
            <iframe src="transfer_reports.html" 
                    style="width: 100%; height: 100%; border: none; background: #F8F9FE; border-radius: 40px;">
            </iframe>
        </div>
    `;
}
function loadExaminerAccountsPage(event) {
    if(event) event.stopPropagation(); 
    const mainArea = document.getElementById('mainArea');
    mainArea.innerHTML = `
        <iframe src="examiners_accounts.html" 
                style="width: 100%; height: 100%; border: none; background: #F8F9FE; border-radius: 40px;">
        </iframe>
    `;
}
function loadSystemReportsPage(element) {
    // تحديث الحالة النشطة (Active) في القائمة الجانبية
    document.querySelectorAll('.menu-item').forEach(item => item.classList.remove('active'));
    element.classList.add('active');

    // تحميل صفحة التقارير داخل منطقة المحتوى الأساسية
    // ملاحظة: تأكدي أن الـ ID الخاص بمنطقة المحتوى في صفحتك هو 'main-content'
    const contentArea = document.querySelector('.main-content') || document.getElementById('content');
    
    contentArea.innerHTML = `
        <div style="width: 100%; height: 100%; padding: 20px; overflow-y: auto;">
            <iframe src="system_reports.html" 
                    style="width: 100%; height: 85vh; border: none; border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);">
            </iframe>
        </div>`;
}
function loadReceiveResultsPage(event) {
    if(event) event.stopPropagation();
    const mainArea = document.getElementById('mainArea'); // تأكدي أن هذا هو ID منطقة المحتوى الرئيسية
    mainArea.innerHTML = `
        <div class="dashboard-card-wrapper" style="height: 100%; padding: 0; overflow: hidden; border:none;">
            <iframe src="receive_results.html" style="width: 100%; height: 100%; border: none; background: #fbfcff; border-radius: 40px;"></iframe>
        </div>`;
}
// Logout
async function handleLogout() {
    try {
        await apiPost('/logout', {});
    } catch (e) { /* ignore */ }
    clearAuth();
    window.location.href = 'index.html';
}

// دالة تحميل صفحة جدول المناقشة (الإدارة)
function loadDiscussionSchedulePage(element) {
    // تحديث الحالة النشطة في القائمة الجانبية
    document.querySelectorAll(".menu-item").forEach(item => item.classList.remove("active"));
    element.classList.add("active");

    // تحميل الصفحة داخل المحتوى الرئيسي
    const mainArea = document.getElementById('mainArea');
    mainArea.innerHTML = `
        <div class="dashboard-card-wrapper" style="height: 100%; padding: 0; overflow: hidden; border:none;">
            <iframe src="admin_discussion_table.html" 
                    style="width: 100%; height: 100%; border: none; background: #f8f9fd; border-radius: 40px;">
            </iframe>
        </div>
    `;
}