function openFullView() {
    const modal = document.getElementById("fullViewModal");
    modal.style.display = "flex"; // إظهار النافذة
}

function closeFullView() {
    const modal = document.getElementById("fullViewModal");
    modal.style.display = "none"; // إخفاء النافذة
}

// إغلاق النافذة عند الضغط في أي مكان خارج الصورة
window.onclick = function(event) {
    const modal = document.getElementById("fullViewModal");
    if (event.target == modal) {
        modal.style.display = "none";
    }
}
function closeFullView() {
    document.getElementById("fullViewModal").style.display = "none";
}

function printImage() {
    const imgUrl = document.getElementById("discussionTableImg").src;
    const windowPrint = window.open('', '');
    windowPrint.document.write('<html><body style="text-align:center;"><img src="' + imgUrl + '" style="max-width:100%;"></body></html>');
    windowPrint.document.close();
    windowPrint.focus();
    setTimeout(() => { windowPrint.print(); windowPrint.close(); }, 500);
}

function downloadImage() {
    const img = document.getElementById("discussionTableImg");
    const link = document.createElement('a');
    link.href = img.src;
    link.download = 'جدول_المناقشات.jpg';
    link.click();
}

