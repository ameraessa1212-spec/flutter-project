document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('requestsContainer');

    const students = [
        { name: "هدية بلقاسم", id: "125487", company: "شركة ليبيا للاتصالات", major: "هندسة برمجيات", username: "hadia_bq", phone: "091-0000000", email: "hadia@email.com" },
        { name: "أحمد المصراتي", id: "985632", company: "شركة المدار الجديد", major: "اتصالات", username: "ahmed_it", phone: "092-1111111", email: "ahmed@email.com" },
        { name: "سارة محمود", id: "447852", company: "مصرف ليبيا المركزي", major: "تقنية معلومات", username: "sara_dev", phone: "091-2222222", email: "sara@email.com" },
        { name: "يوسف علي", id: "336985", company: "الشركة العامة للكهرباء", major: "هندسة كهربائية", username: "yousef_eng", phone: "094-3333333", email: "yousef@email.com" },
        { name: "ريهام محمد", id: "778541", company: "شركة البريقة للنفط", major: "إدارة نظم", username: "reham_m", phone: "091-4444444", email: "reham@email.com" }
    ];

    students.forEach(s => {
        const row = document.createElement('div');
        row.className = 'request-row';
        row.innerHTML = `
            <div class="row-main" onclick="this.parentElement.classList.toggle('open')">
                <div class="student-meta">
                    <span class="reg-number">#${s.id}</span>
                    <h3 class="student-name">${s.name}</h3>
                </div>
                <div class="target-company"><i class="ri-community-line"></i> <span>${s.company}</span></div>
                <div class="major-tag">${s.major}</div>
                <div class="row-actions">
                    <button class="action-icon approve"><i class="ri-check-fill"></i></button>
                    <button class="action-icon reject"><i class="ri-close-fill"></i></button>
                </div>
            </div>
            <div class="row-details">
                <div class="details-inner">
                    <div class="info-group">
                        <span class="info-item"><i class="ri-user-smile-line"></i> ${s.username}</span>
                        <span class="info-item"><i class="ri-phone-line"></i> ${s.phone}</span>
                        <span class="info-item"><i class="ri-mail-line"></i> ${s.email}</span>
                    </div>
                </div>
            </div>
        `;
        container.appendChild(row);
    });
});