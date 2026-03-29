// بيانات الشركات المقبولة (تخيل أنها تأتي من الصفحة السابقة)
const registeredCompanies = [
    {
        id: 1,
        name: "شركة تكنو كود",
        location: "طرابلس - حي الأندلس",
        major: "حاسب آلي",
        students: 5,
        email: "hr@techno.ly",
        color: "linear-gradient(135deg, #6A5AE0, #8A7CF0)"
    },
    {
        id: 2,
        name: "ليبيا للاتصالات",
        location: "طرابلس - زاوية الدهماني",
        major: "اتصالات",
        students: 8,
        email: "jobs@ltt.ly",
        color: "linear-gradient(135deg, #00D084, #00A36C)"
    },
    {
        id: 3,
        name: "ليبيا للتحكم",
        location: "بنغازي - القوارشة",
        major: "تحكم",
        students: 3,
        email: "info@control.ly",
        color: "linear-gradient(135deg, #FF6FD8, #A033FF)"
    }
];

function displayCompanies(data) {
    const grid = document.getElementById('companiesGrid');
    grid.innerHTML = '';
    
    data.forEach(comp => {
        grid.innerHTML += `
            <div class="company-card">
                <div class="card-top">
                    <div class="icon-box" style="background: ${comp.color}">
                        ${comp.name.charAt(0)}
                    </div>
                    <span class="verified-badge"><i class="ri-checkbox-circle-fill"></i> معتمدة</span>
                </div>
                <div class="company-info">
                    <h3>${comp.name}</h3>
                    <p><i class="ri-map-pin-2-fill"></i> ${comp.location}</p>
                    <span class="specialization-tag">${comp.major}</span>
                </div>
                <div class="card-stats">
                    <div class="stat"><i class="ri-group-line"></i> متدربين: <strong>${comp.students}</strong></div>
                    
                </div>
            </div>
        `;
    });
    document.getElementById('companyCount').innerText = data.length;
}

function filterCompanies(major, btn) {
    // تحديث شكل الأزرار
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    // تصفية البيانات
    if(major === 'all') {
        displayCompanies(registeredCompanies);
    } else {
        const filtered = registeredCompanies.filter(c => c.major === major);
        displayCompanies(filtered);
    }
}

// التشغيل الأولي
displayCompanies(registeredCompanies);