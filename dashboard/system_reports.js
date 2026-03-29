async function generateData() {
    const type = document.getElementById('reportType').value;
    const semester = document.getElementById('semester').value;
    const selectedDept = document.getElementById('deptFilter').value;
    const tbody = document.getElementById('tableBody');
    const title = document.getElementById('reportTitle');
    const thead = document.getElementById('tableHead');

    tbody.style.opacity = '0';

    try {
        const params = new URLSearchParams({ reportType: type, dept: selectedDept, semester });
        const result = await apiGet(`/system-reports?${params}`);

        if (!result) return;

        const deptLabel = selectedDept === 'all' ? 'جميع التخصصات' : selectedDept;

        if (type === 'students') {
            title.innerText = `تقرير طلاب التدريب الميداني (${deptLabel}) - فصل ${semester}`;
        } else if (type === 'companies') {
            title.innerText = `تقرير إحصائيات تعاون الشركات - عام 2026`;
        } else if (type === 'examiners') {
            title.innerText = `تقرير إشراف الممتحنين (${deptLabel}) - فصل ${semester}`;
        }

        // Set columns
        if (result.columns) {
            thead.innerHTML = result.columns.map(col => `<th>${col}</th>`).join('');
        }

        // Set data
        if (result.data && result.data.length > 0) {
            tbody.innerHTML = result.data.map(row => {
                const values = Object.values(row);
                return `<tr>${values.map(v => `<td>${v}</td>`).join('')}</tr>`;
            }).join('');
        } else {
            const colSpan = result.columns ? result.columns.length : 5;
            tbody.innerHTML = `<tr><td colspan="${colSpan}" style="text-align:center;">لا توجد بيانات</td></tr>`;
        }

        tbody.style.opacity = '1';
    } catch (e) {
        console.error('Failed to load report:', e);
        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:red;">حدث خطأ في تحميل البيانات</td></tr>';
        tbody.style.opacity = '1';
    }
}
