let companiesData = [
    { name: "شركة ليبيانا للهاتف المحمول", email: "info@libyana.ly", date: "2024-01-10", active: true },
    { name: "شركة المدار الجديد", email: "contact@almadar.ly", date: "2024-02-15", active: true },
    { name: "شركة هاتف ليبيا", email: "support@ltt.ly", date: "2024-03-01", active: true },
    { name: "شركة تكنو كود", email: "jobs@technocode.ly", date: "2024-05-20", active: true }
];

function renderTable(data) {
    const tbody = document.getElementById('companyTableBody');
    tbody.innerHTML = data.map((c, index) => `
        <tr>
            <td><strong>${c.name}</strong></td>
            <td style="color: #6A5AE0">${c.email}</td>
            <td>${c.date}</td>
            <td>
                <span class="status-pill ${c.active ? 'active' : 'inactive'}">
                    ${c.active ? 'نشط' : 'غير نشط'}
                </span>
            </td>
            <td>
                <button onclick="toggleStatus(${index})" class="action-btn ${c.active ? 'btn-off' : 'btn-on'}">
                    ${c.active ? 'تعطيل' : 'تفعيل'}
                </button>
            </td>
        </tr>
    `).join('');
}

function toggleStatus(index) {
    companiesData[index].active = !companiesData[index].active;
    renderTable(companiesData);
}

function filterCompanies() {
    const term = document.getElementById('companySearch').value.toLowerCase();
    const filtered = companiesData.filter(c => c.name.toLowerCase().includes(term));
    renderTable(filtered);
}

document.addEventListener('DOMContentLoaded', () => renderTable(companiesData));
