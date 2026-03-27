// تشغيل الرسم البياني عند تحميل الصفحة
document.addEventListener('DOMContentLoaded', function() {
    const ctx = document.getElementById('growthChart').getContext('2d');
    
    // إعداد البيانات
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو'],
            datasets: [{
                label: 'نمو الشركات المسجلة',
                data: [12, 19, 15, 25, 22, 35],
                borderColor: '#8a2be2',
                backgroundColor: 'rgba(138, 43, 226, 0.1)',
                borderWidth: 4,
                tension: 0.4, // لجعل الخط منحني (انسيابي)
                fill: true,
                pointRadius: 0
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: {
                y: { display: false },
                x: { grid: { display: false } }
            }
        }
    });

    // إضافة تأثير "المغناطيس" البسيط للبطاقات عند تحريك الماوس
    const cards = document.querySelectorAll('.hero-card');
    document.addEventListener('mousemove', (e) => {
        let x = (window.innerWidth / 2 - e.pageX) / 50;
        let y = (window.innerHeight / 2 - e.pageY) / 50;
        
        cards.forEach(card => {
            card.style.transform = `rotateY(${x}deg) rotateX(${-y}deg)`;
        });
    });
});