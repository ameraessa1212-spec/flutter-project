document.addEventListener('DOMContentLoaded', () => {
    loadScheduleImage();
});

async function loadScheduleImage() {
    try {
        const result = await apiGet('/discussion-schedules');
        if (result && result.data && result.data.length > 0) {
            const latest = result.data[0];
            const img = document.getElementById('discussionTableImg');
            if (img && latest.image_url) {
                img.src = latest.image_url;
            }
        }
    } catch (e) {
        console.error('Failed to load schedule:', e);
    }
}

function openFullView() {
    document.getElementById('fullViewModal').style.display = 'flex';
}

function closeFullView() {
    document.getElementById('fullViewModal').style.display = 'none';
}

window.onclick = function(event) {
    const modal = document.getElementById('fullViewModal');
    if (event.target == modal) modal.style.display = 'none';
};

function printImage() {
    const imgUrl = document.getElementById('discussionTableImg').src;
    const w = window.open('', '');
    w.document.write('<html><body style="text-align:center;"><img src="' + imgUrl + '" style="max-width:100%;"></body></html>');
    w.document.close();
    w.focus();
    setTimeout(() => { w.print(); w.close(); }, 500);
}

function downloadImage() {
    const img = document.getElementById('discussionTableImg');
    const link = document.createElement('a');
    link.href = img.src;
    link.download = 'جدول_المناقشات.jpg';
    link.click();
}
