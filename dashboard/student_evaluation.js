document.addEventListener('DOMContentLoaded', () => {
    const searchInput = document.getElementById('studentSearch');
    
    // وظيفة البحث السريع
    searchInput.addEventListener('keyup', () => {
        const term = searchInput.value.toLowerCase();
        const cards = document.querySelectorAll('.student-card');
        
        cards.forEach(card => {
            const name = card.querySelector('h3').innerText.toLowerCase();
            const company = card.querySelector('.company-info span').innerText.toLowerCase();
            
            if(name.includes(term) || company.includes(term)) {
                card.style.display = "flex";
            } else {
                card.style.display = "none";
            }
        });
    });
});

// الانتقال لصفحة الطالب التفصيلية
function goToDetails(studentName) {
    // هنا يتم تحويل المشرف لصفحة تقييم الطالب التي صممناها سابقاً
    window.location.href = 'student_evaluation.html'; 
}