let registeredCompanies = [];
const gradients = [
    'linear-gradient(135deg, #6A5AE0, #8A7CF0)',
    'linear-gradient(135deg, #00D084, #00A36C)',
    'linear-gradient(135deg, #FF6FD8, #A033FF)',
    'linear-gradient(135deg, #FF9F43, #FF6B6B)',
    'linear-gradient(135deg, #0ABDE3, #48DBFB)',
];

document.addEventListener('DOMContentLoaded', () => {
    loadRegisteredCompanies();
});

async function loadRegisteredCompanies() {
    try {
        const result = await apiGet('/registered-companies');
        if (result && result.data) {
            registeredCompanies = result.data;
            displayCompanies(registeredCompanies);
        }
    } catch (e) {
        console.error('Failed to load companies:', e);
    }
}

function displayCompanies(data) {
    const grid = document.getElementById('companiesGrid');
    grid.innerHTML = '';

    if (data.length === 0) {
        grid.innerHTML = '<p style="text-align:center; color:#aaa; padding:40px; grid-column:1/-1;">لا توجد شركات مسجلة</p>';
        document.getElementById('companyCount').innerText = '0';
        return;
    }

    data.forEach((comp, index) => {
        const color = gradients[index % gradients.length];
        grid.innerHTML += `
            <div class="company-card">
                <div class="card-top">
                    <div class="icon-box" style="background: ${color}">
                        ${(comp.name || '').charAt(0)}
                    </div>
                    <span class="verified-badge"><i class="ri-checkbox-circle-fill"></i> معتمدة</span>
                </div>
                <div class="company-info">
                    <h3>${comp.name}</h3>
                    <p><i class="ri-map-pin-2-fill"></i> ${comp.city || '--'} ${comp.address ? '- ' + comp.address : ''}</p>
                </div>
                <div class="card-stats">
                    <div class="stat"><i class="ri-group-line"></i> متدربين: <strong>${comp.internships_count}</strong></div>
                </div>
            </div>
        `;
    });
    document.getElementById('companyCount').innerText = data.length;
}

function filterCompanies(major, btn) {
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    if (major === 'all') {
        displayCompanies(registeredCompanies);
    } else {
        // Filter by searching specialization in API
        apiGet(`/registered-companies?specialization=${encodeURIComponent(major)}`).then(result => {
            if (result && result.data) displayCompanies(result.data);
        });
    }
}
