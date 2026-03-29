let examinersData = [];

document.addEventListener('DOMContentLoaded', () => {
    loadExaminers();
    document.getElementById('examinerSearch').addEventListener('input', filterExaminers);
});

async function loadExaminers() {
    try {
        const result = await apiGet('/examiners');
        if (result && result.data) {
            examinersData = result.data;
            renderExaminers(examinersData);
        }
    } catch (e) {
        console.error('Failed to load examiners:', e);
    }
}

function renderExaminers(data) {
    const tbody = document.getElementById('examinersTable');
    tbody.innerHTML = data.map(ex => `
        <tr>
            <td class="user-cell">${ex.name}</td>
            <td>${ex.email || '--'}</td>
            <td>${ex.phone || '--'}</td>
            <td>
                <span class="status-badge ${ex.status === 'active' ? 'active' : 'inactive'}">
                    ${ex.status === 'active' ? 'نشط' : 'معطل'}
                </span>
            </td>
            <td>
                <button class="toggle-btn ${ex.status === 'active' ? '' : 'activate'}" onclick="toggleAccount(${ex.id})">
                    ${ex.status === 'active' ? 'تعطيل' : 'تفعيل'}
                </button>
            </td>
        </tr>
    `).join('');
}

async function toggleAccount(examinerId) {
    const examiner = examinersData.find(e => e.id === examinerId);
    if (examiner && examiner.status === 'active') {
        if (!confirm(`هل أنت متأكد من تعطيل حساب (${examiner.name})؟`)) return;
    }

    try {
        const result = await apiPut(`/examiners/${examinerId}/toggle-status`, {});
        if (result) {
            loadExaminers();
        }
    } catch (e) {
        alert('حدث خطأ');
    }
}

function filterExaminers() {
    const filter = document.getElementById('examinerSearch').value.toLowerCase();
    const filtered = examinersData.filter(ex =>
        (ex.name || '').toLowerCase().includes(filter) ||
        (ex.email || '').toLowerCase().includes(filter)
    );
    renderExaminers(filtered);
}
