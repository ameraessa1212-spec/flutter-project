let companiesData = [];

document.addEventListener('DOMContentLoaded', () => {
    loadCompanyAccounts();
});

async function loadCompanyAccounts() {
    try {
        const result = await apiGet('/company-accounts');
        if (result && result.data) {
            companiesData = result.data;
            renderTable(companiesData);
        }
    } catch (e) {
        console.error('Failed to load company accounts:', e);
    }
}

function renderTable(data) {
    const tbody = document.getElementById('companyTableBody');
    tbody.innerHTML = data.map(c => `
        <tr>
            <td><strong>${c.name}</strong></td>
            <td style="color: #6A5AE0">${c.email || '--'}</td>
            <td>${c.created_at || '--'}</td>
            <td>
                <span class="status-pill ${c.is_active ? 'active' : 'inactive'}">
                    ${c.is_active ? 'نشط' : 'غير نشط'}
                </span>
            </td>
            <td>
                <button onclick="toggleStatus(${c.id})" class="action-btn ${c.is_active ? 'btn-off' : 'btn-on'}">
                    ${c.is_active ? 'تعطيل' : 'تفعيل'}
                </button>
            </td>
        </tr>
    `).join('');
}

async function toggleStatus(companyId) {
    try {
        const result = await apiPut(`/company-accounts/${companyId}/toggle-status`, {});
        if (result) {
            const company = companiesData.find(c => c.id === companyId);
            if (company) company.is_active = result.data.is_active;
            renderTable(companiesData);
        }
    } catch (e) {
        alert('حدث خطأ');
    }
}

function filterCompanies() {
    const term = document.getElementById('companySearch').value.toLowerCase();
    const filtered = companiesData.filter(c => (c.name || '').toLowerCase().includes(term));
    renderTable(filtered);
}
