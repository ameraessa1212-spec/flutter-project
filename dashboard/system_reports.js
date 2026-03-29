function generateData() {
    const type = document.getElementById('reportType').value;
    const semester = document.getElementById('semester').value;
    const selectedDept = document.getElementById('deptFilter').value;
    const tbody = document.getElementById('tableBody');
    const title = document.getElementById('reportTitle');
    const thead = document.getElementById('tableHead');

    tbody.style.opacity = "0";

    setTimeout(() => {
        if (type === 'students') {
            const deptLabel = selectedDept === 'all' ? 'جميع التخصصات' : selectedDept;
            title.innerText = `تقرير طلاب التدريب الميداني (${deptLabel}) - فصل ${semester}`;
            thead.innerHTML = `<th>رقم القيد</th><th>اسم الطالب</th><th>التخصص</th><th>جهة التدريب</th><th>الحالة</th>`;
            
            const students = [
                {id: "2024102", name: "محمد المصراتي", dept: "حاسب آلي", company: "ليبيا للهاتف", status: "نشط"},
                {id: "220111", name: "سراج محمود", dept: "حاسب آلي", company: "شركة المدار", status: "نشط"},
                {id: "220155", name: "سارة محمود", dept: "اتصالات", company: "شركة المدار", status: "نشط"},
                {id: "220855", name: "سديم محمود", dept: "اتصالات", company: "شركة المدار", status: "نشط"}
            ];

            const filtered = students.filter(s => selectedDept === 'all' || s.dept === selectedDept);

            tbody.innerHTML = filtered.length > 0 
                ? filtered.map(s => `<tr><td>${s.id}</td><td>${s.name}</td><td>${s.dept}</td><td>${s.company}</td><td>${s.status}</td></tr>`).join('')
                : `<tr><td colspan="5" style="text-align:center;">لا توجد بيانات لهذا التخصص</td></tr>`;
        } 
        else if (type === 'companies') {
            title.innerText = `تقرير إحصائيات تعاون الشركات - عام 2026`;
            thead.innerHTML = `<th>اسم الشركة</th><th>عدد الطلاب</th><th>السعة</th><th>الحالة</th>`;
            tbody.innerHTML = `
                <tr><td>شركة ليبيانا للهاتف المحمول</td><td>12 طالب</td><td>20</td><td>نشط</td></tr>
                <tr><td>شركة المدار الجديد</td><td>8 طلاب</td><td>15</td><td>نشط</td></tr>
            `;
        } 
        else if (type === 'examiners') {
            const deptLabel = selectedDept === 'all' ? 'جميع التخصصات' : selectedDept;
            title.innerText = `تقرير إشراف الممتحنين (${deptLabel}) - فصل ${semester}`;
            thead.innerHTML = `<th>اسم الممتحن</th><th>التخصص المسؤول عنه</th><th>عدد الطلاب</th>`;
            
            const examiners = [
                {name: "د. أحمد المبروك", dept: "حاسب آلي", count: "15 طالب"},
                {name: "د. سارة محمود", dept: "اتصالات", count: "8 طلاب"},
                {name: "د. عبد الله الفيتوري", dept: "حاسب آلي", count: "12 طالب"}
            ];

            const filteredEx = examiners.filter(ex => selectedDept === 'all' || ex.dept === selectedDept);

            tbody.innerHTML = filteredEx.length > 0 
                ? filteredEx.map(ex => `<tr><td>${ex.name}</td><td>${ex.dept}</td><td>${ex.count}</td></tr>`).join('')
                : `<tr><td colspan="3" style="text-align:center;">لا توجد بيانات لهذا التخصص</td></tr>`;
        }
        tbody.style.opacity = "1";
    }, 300);
}