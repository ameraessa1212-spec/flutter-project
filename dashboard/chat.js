// 1. تفعيل البحث
function filterContacts() {
    let term = document.getElementById('searchInput').value.toLowerCase();
    document.querySelectorAll('.user-item').forEach(card => {
        let name = card.querySelector('strong').innerText.toLowerCase();
        card.style.display = name.includes(term) ? "flex" : "none";
    });
}

// 2. تفعيل الاتصال
function startCall(type) {
    const overlay = document.getElementById('callOverlay');
    const name = document.getElementById('targetName').innerText;
    const initial = document.getElementById('targetAvatar').innerText;
    const color = document.getElementById('targetAvatar').classList[1];

    document.getElementById('callName').innerText = name;
    document.getElementById('callAvatar').innerText = initial;
    document.getElementById('callAvatar').className = `call-avatar ${color}`;
    document.getElementById('callStatus').innerText = `جاري الاتصال (${type})...`;
    
    overlay.style.display = 'flex';
}
function endCall() { document.getElementById('callOverlay').style.display = 'none'; }

// 3. تسجيل الصوت
function startRecording() {
    document.getElementById('voiceOverlay').style.display = 'flex';
    document.getElementById('micBtn').style.color = '#ff4757';
}
function stopRecording() {
    document.getElementById('voiceOverlay').style.display = 'none';
    document.getElementById('micBtn').style.color = '#888';
    addMessage("voice", "0:10");
}

// 4. إرسال الرسائل والملفات
function sendMsg() {
    const input = document.getElementById('msgInput');
    if(input.value.trim()) { addMessage("text", input.value); input.value = ""; }
}

function handleFile(input) {
    if(input.files[0]) {
        const url = URL.createObjectURL(input.files[0]);
        addMessage("file", input.files[0].name, url);
    }
}

function addMessage(type, content, url = "#") {
    const view = document.getElementById('chatWindow');
    let html = "";
    if(type === "text") html = `<div class="msg-bubble out">${content}</div>`;
    else if(type === "voice") html = `<div class="msg-bubble out" style="display:flex;gap:10px;align-items:center"><i class="ri-play-fill"></i><div style="width:80px;height:3px;background:#fff5;border-radius:2px"></div><span>${content}</span></div>`;
    else if(type === "file") html = `<div class="msg-bubble out" onclick="window.open('${url}')" style="background:#2ecc71;cursor:pointer"><i class="ri-file-line"></i> ${content}</div>`;
    
    view.innerHTML += html;
    view.scrollTop = view.scrollHeight;
}

// 5. وظائف إضافية
function toggleDropdown() { document.getElementById("myDropdown").classList.toggle("show"); }
window.onclick = (e) => { if(!e.target.matches('.ri-more-2-fill')) document.getElementById("myDropdown").classList.remove('show'); };
function checkEnter(e) { if(e.key === 'Enter') sendMsg(); }