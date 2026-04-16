<script setup>
import { ref, onMounted, nextTick, computed } from 'vue'
import api from '../../composables/useApi'

const contacts = ref([])
const messages = ref([])
const activeUser = ref(null)
const msgInput = ref('')
const search = ref('')
const loadingContacts = ref(true)
const loadingMessages = ref(false)

const currentAdmin = JSON.parse(localStorage.getItem('admin_user') || '{}')

onMounted(async () => {
  const { data } = await api.get('/chat/contacts').catch(() => ({ data: { data: [] } }))
  contacts.value = data.data || []
  loadingContacts.value = false
})

const filteredContacts = computed(() => {
  if (!search.value) return contacts.value
  const t = search.value.toLowerCase()
  return contacts.value.filter(c => c.name.toLowerCase().includes(t))
})

async function openChat(user) {
  activeUser.value = user
  loadingMessages.value = true
  messages.value = []
  const { data } = await api.get('/chat/messages', { params: { user_id: user.id } }).catch(() => ({ data: { data: [] } }))
  messages.value = data.data || []
  loadingMessages.value = false
  await nextTick()
  scrollBottom()
}

async function sendMsg() {
  if (!msgInput.value.trim() || !activeUser.value) return
  const body = msgInput.value.trim()
  msgInput.value = ''
  messages.value.push({ body, is_mine: true, sender_name: currentAdmin.name || 'أنا', time: 'الآن' })
  await nextTick()
  scrollBottom()
  await api.post('/chat/messages', { user_id: activeUser.value.id, body, type: 'text' }).catch(() => null)
}

function scrollBottom() {
  const el = document.getElementById('chatMsgs')
  if (el) el.scrollTop = el.scrollHeight
}
</script>

<template>
  <div class="chat-layout">
    <!-- Students Sidebar -->
    <div class="chat-sidebar">
      <div class="sidebar-title">
        <i class="ri-user-line"></i>
        <span>تواصل مع الطلاب</span>
      </div>
      <div class="mb-sm">
        <input v-model="search" class="search-input" style="max-width:100%;" placeholder="ابحث عن طالب...">
      </div>

      <div v-if="loadingContacts" class="loading" style="padding:20px;font-size:13px;"></div>
      <div v-else-if="!filteredContacts.length" class="empty" style="padding:20px;font-size:13px;">لا يوجد طلاب</div>
      <template v-else>
        <div
          v-for="c in filteredContacts" :key="c.id"
          class="contact-item"
          :class="{ active: activeUser?.id === c.id }"
          @click="openChat(c)"
        >
          <div class="avatar-circle" style="width:42px;height:42px;">{{ c.initials }}</div>
          <div style="flex:1;min-width:0;">
            <strong style="font-size:14px;display:block;">{{ c.name }}</strong>
            <small v-if="c.specialization" class="text-muted" style="font-size:11px;">{{ c.specialization }}</small>
          </div>
        </div>
      </template>
    </div>

    <!-- Chat Area -->
    <div class="chat-main">
      <div class="chat-header" v-if="activeUser">
        <div class="avatar-circle">{{ activeUser.initials }}</div>
        <div style="flex:1;">
          <strong>{{ activeUser.name }}</strong>
          <div>
            <small v-if="activeUser.specialization" class="text-muted">{{ activeUser.specialization }}</small>
          </div>
        </div>
        <span class="shared-chat-note" title="تشارك هذه المحادثة جميع المسؤولين">
          <i class="ri-team-line"></i> محادثة مشتركة
        </span>
      </div>
      <div class="chat-header" v-else>
        <i class="ri-chat-3-line" style="font-size:22px;color:var(--text-muted);"></i>
        <span class="text-muted">اختر طالباً لبدء المحادثة</span>
      </div>

      <div class="chat-messages" id="chatMsgs">
        <div v-if="!activeUser" class="empty" style="margin:auto;">
          <i class="ri-message-3-line" style="font-size:48px;color:var(--border);display:block;margin-bottom:12px;"></i>
          اختر طالباً من القائمة
        </div>
        <div v-else-if="loadingMessages" class="loading" style="margin:auto;"></div>
        <div v-else-if="!messages.length" class="empty" style="margin:auto;">
          <i class="ri-chat-new-line" style="font-size:48px;color:var(--border);display:block;margin-bottom:12px;"></i>
          ابدأ المحادثة مع {{ activeUser.name }}
        </div>
        <template v-else>
          <div v-for="(m, i) in messages" :key="i" class="msg-wrapper" :class="m.is_mine ? 'out' : 'in'">
            <!-- Show sender name if the message is from another admin (not me, not the student) -->
            <small
              v-if="!m.is_mine && m.sender_name && m.sender_name !== activeUser?.name"
              class="msg-sender"
            >
              {{ m.sender_name }}
            </small>
            <div class="msg" :class="m.is_mine ? 'out' : 'in'">
              <div>{{ m.body }}</div>
              <div style="font-size:10px;opacity:0.7;margin-top:4px;">{{ m.time || '' }}</div>
            </div>
          </div>
        </template>
      </div>

      <div class="chat-footer" v-if="activeUser">
        <input
          v-model="msgInput"
          @keyup.enter="sendMsg"
          placeholder="اكتب رسالتك هنا..."
          autofocus
        >
        <button class="btn btn-primary" @click="sendMsg" :disabled="!msgInput.trim()">
          <i class="ri-send-plane-2-fill"></i> إرسال
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.sidebar-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 700;
  font-size: 15px;
  color: var(--text-primary);
  padding: 4px 4px 12px;
  margin-bottom: 8px;
  border-bottom: 1px solid var(--border-light);
}
.sidebar-title i {
  color: var(--primary);
}

.shared-chat-note {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 12px;
  background: var(--primary-bg);
  color: var(--primary);
  border-radius: var(--radius-full);
  font-size: 11px;
  font-weight: 700;
  white-space: nowrap;
}

.msg-wrapper {
  display: flex;
  flex-direction: column;
  max-width: 70%;
}
.msg-wrapper.out {
  align-self: flex-start;
  align-items: flex-start;
}
.msg-wrapper.in {
  align-self: flex-end;
  align-items: flex-end;
}

.msg-sender {
  font-size: 11px;
  color: var(--primary);
  font-weight: 700;
  margin-bottom: 2px;
  padding: 0 6px;
}

.msg-wrapper .msg {
  max-width: 100%;
}
</style>
