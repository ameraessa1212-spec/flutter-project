document.addEventListener('DOMContentLoaded', function() {
    const requestGrid = document.querySelector('.requests-grid');

    if (requestGrid) {
        requestGrid.addEventListener('click', function(e) {
            const card = e.target.closest('.request-card');
            if (!card) return;

            const studentName = card.querySelector('h4').innerText;

            if (e.target.classList.contains('accept')) {
                e.target.innerHTML = '<i class="ri-check-line"></i> مقبول';
                e.target.style.background = '#22c55e';
                e.target.style.pointerEvents = 'none';
                const rejectBtn = card.querySelector('.reject');
                if (rejectBtn) rejectBtn.style.display = 'none';
            }

            if (e.target.classList.contains('reject')) {
                if (confirm("هل أنتِ متأكدة من رفض طلب الطالب: " + studentName + "؟")) {
                    card.style.opacity = '0';
                    card.style.transform = 'scale(0.8)';
                    setTimeout(() => { card.remove(); }, 400);
                }
            }
        });
    }
});