let currentChatUserId = null;

document.addEventListener('DOMContentLoaded', () => {
    loadChatContacts();
});

async function loadChatContacts() {
    try {
        const result = await apiGet('/chat/contacts');
        if (!result || !result.data) return;

        const list = document.getElementById('usersList');
        if (!list) return;

        list.innerHTML = result.data.map(u => `
            <div class="user-item" onclick="openChat(${u.id}, '${u.name}', '${u.initials}')">
                <div class="user-avatar">${u.initials}</div>
                <div class="user-info">
                    <strong>${u.name}</strong>
                    <small>${u.role === 'student' ? 'طالب' : u.role === 'examiner' ? 'ممتحن' : 'مشرف'}</small>
                </div>
            </div>
        `).join('');
    } catch (e) {
        console.error('Failed to load contacts:', e);
    }
}

async function openChat(userId, name, initials) {
    currentChatUserId = userId;
    document.getElementById('targetName').innerText = name;
    document.getElementById('targetAvatar').innerText = initials;

    const chatWindow = document.getElementById('chatWindow');
    chatWindow.innerHTML = '<p style="text-align:center; color:#aaa; padding:20px;">جاري التحميل...</p>';

    try {
        const result = await apiGet(`/chat/messages?user_id=${userId}`);
        chatWindow.innerHTML = '';

        if (result && result.data && result.data.length > 0) {
            result.data.forEach(msg => {
                const cls = msg.is_mine ? 'out' : 'in';
                chatWindow.innerHTML += `<div class="msg-bubble ${cls}">${msg.body}</div>`;
            });
        } else {
            chatWindow.innerHTML = '<p style="text-align:center; color:#aaa; padding:20px;">ابدأ المحادثة...</p>';
        }
        chatWindow.scrollTop = chatWindow.scrollHeight;
    } catch (e) {
        chatWindow.innerHTML = '<p style="text-align:center; color:red;">حدث خطأ</p>';
    }
}

function filterContacts() {
    let term = document.getElementById('searchInput').value.toLowerCase();
    document.querySelectorAll('.user-item').forEach(card => {
        let name = card.querySelector('strong').innerText.toLowerCase();
        card.style.display = name.includes(term) ? 'flex' : 'none';
    });
}

async function sendMsg() {
    const input = document.getElementById('msgInput');
    const body = input.value.trim();
    if (!body || !currentChatUserId) return;

    input.value = '';
    addMessage('text', body);

    try {
        await apiPost('/chat/messages', {
            user_id: currentChatUserId,
            body: body,
            type: 'text',
        });
    } catch (e) {
        console.error('Failed to send:', e);
    }
}

function addMessage(type, content, url = '#') {
    const view = document.getElementById('chatWindow');
    // Remove "start conversation" placeholder
    const placeholder = view.querySelector('p');
    if (placeholder) placeholder.remove();

    let html = '';
    if (type === 'text') html = `<div class="msg-bubble out">${content}</div>`;
    else if (type === 'voice') html = `<div class="msg-bubble out" style="display:flex;gap:10px;align-items:center"><i class="ri-play-fill"></i><div style="width:80px;height:3px;background:#fff5;border-radius:2px"></div><span>${content}</span></div>`;
    else if (type === 'file') html = `<div class="msg-bubble out" onclick="window.open('${url}')" style="background:#2ecc71;cursor:pointer"><i class="ri-file-line"></i> ${content}</div>`;

    view.innerHTML += html;
    view.scrollTop = view.scrollHeight;
}

function startCall(type) {
    const overlay = document.getElementById('callOverlay');
    const name = document.getElementById('targetName').innerText;
    const initial = document.getElementById('targetAvatar').innerText;

    document.getElementById('callName').innerText = name;
    document.getElementById('callAvatar').innerText = initial;
    document.getElementById('callStatus').innerText = `جاري الاتصال (${type})...`;
    overlay.style.display = 'flex';
}
function endCall() { document.getElementById('callOverlay').style.display = 'none'; }

function startRecording() {
    document.getElementById('voiceOverlay').style.display = 'flex';
    document.getElementById('micBtn').style.color = '#ff4757';
}
function stopRecording() {
    document.getElementById('voiceOverlay').style.display = 'none';
    document.getElementById('micBtn').style.color = '#888';
    addMessage('voice', '0:10');
}

function handleFile(input) {
    if (input.files[0]) {
        const url = URL.createObjectURL(input.files[0]);
        addMessage('file', input.files[0].name, url);
    }
}

function toggleDropdown() { document.getElementById('myDropdown').classList.toggle('show'); }
window.onclick = (e) => { if (!e.target.matches('.ri-more-2-fill')) document.getElementById('myDropdown')?.classList.remove('show'); };
function checkEnter(e) { if (e.key === 'Enter') sendMsg(); }
