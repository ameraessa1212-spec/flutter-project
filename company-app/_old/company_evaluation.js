document.addEventListener('DOMContentLoaded', () => {
    const inputs = document.querySelectorAll('.grade-input');
    const totalDisplay = document.getElementById('totalScore');

    const calculateTotal = () => {
        let total = 0;
        inputs.forEach(input => {
            total += parseFloat(input.value) || 0;
        });
        if(totalDisplay) {
            totalDisplay.innerText = Math.round(total);
        }
    };

    inputs.forEach(input => {
        input.addEventListener('input', (e) => {
            const max = parseFloat(e.target.dataset.max);
            let val = parseFloat(e.target.value);
            
            if (val > max) {
                alert(`القيمة العظمى لهذا البند هي ${max}`);
                e.target.value = max;
            }
            if (val < 0) e.target.value = 0;
            
            calculateTotal();
        });
    });
});
