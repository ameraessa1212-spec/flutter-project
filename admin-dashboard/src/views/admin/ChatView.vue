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
const roleFilter = ref('')

onMounted(async () => {
  const { data } = await api.get('/chat/contacts').catch(() => ({ data: { data: [] } }))
  contacts.value = data.data || []
  loadingContacts.value = false
})

const filteredContacts = computed(() => {
  let list = contacts.value
  if (roleFilter.value) {
    list = list.filter(c => c.role === roleFilter.value)
  }
  if (search.value) {
    const t = search.value.toLowerCase()
    list = list.filter(c => c.name.toLowerCase().includes(t))
  }
  return list
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
  messages.value.push({ body, is_mine: true, time: 'الآن' })
  await nextTick()
  scrollBottom()
  await api.post('/chat/messages', { user_id: activeUser.value.id, body, type: 'text' }).catch(() => null)
}

function scrollBottom() {
  const el = document.getElementById('chatMsgs')
  if (el) el.scrollTop = el.scrollHeight
}

function roleLabel(role) {
  return { student: 'طالب', examiner: 'ممتحن', supervisor: 'مشرف' }[role] || role
}
</script>

<template>
  <div class="chat-layout">
    <!-- Contacts Sidebar -->
    <div class="chat-sidebar">
      <div class="mb-sm">
        <input v-model="search" class="search-input" style="max-width:100%;" placeholder="ابحث عن مستخدم...">
      </div>
      <div style="display:flex;gap:6px;margin-bottom:12px;">
        <button class="btn btn-sm" :class="roleFilter === '' ? 'btn-primary' : 'btn-outline'" @click="roleFilter = ''" style="flex:1;font-size:12px;">الكل</button>
        <button class="btn btn-sm" :class="roleFilter === 'student' ? 'btn-primary' : 'btn-outline'" @click="roleFilter = 'student'" style="flex:1;font-size:12px;">طلاب</button>
        <button class="btn btn-sm" :class="roleFilter === 'examiner' ? 'btn-primary' : 'btn-outline'" @click="roleFilter = 'examiner'" style="flex:1;font-size:12px;">ممتحنين</button>
      </div>

      <div v-if="loadingContacts" class="loading" style="padding:20px;font-size:13px;"></div>
      <div v-else-if="!filteredContacts.length" class="empty" style="padding:20px;font-size:13px;">لا يوجد مستخدمين</div>
      <template v-else>
        <div
          v-for="c in filteredContacts" :key="c.id"
          class="contact-item"
          :class="{ active: activeUser?.id === c.id }"
          @click="openChat(c)"
        >
          <div class="avatar-circle" style="width:42px;height:42px;">{{ c.initials }}</div>
          <div style="flex:1;min-width:0;">
            <div class="flex-between">
              <strong style="font-size:14px;">{{ c.name }}</strong>
            </div>
            <div class="flex-between" style="margin-top:2px;">
              <span class="badge" :class="c.role === 'student' ? 'badge-info' : c.role === 'examiner' ? 'badge-purple' : 'badge-active'" style="font-size:10px;padding:2px 8px;">{{ roleLabel(c.role) }}</span>
              <small v-if="c.specialization" class="text-muted" style="font-size:11px;">{{ c.specialization }}</small>
            </div>
          </div>
        </div>
      </template>
    </div>

    <!-- Chat Area -->
    <div class="chat-main">
      <div class="chat-header" v-if="activeUser">
        <div class="avatar-circle">{{ activeUser.initials }}</div>
        <div>
          <strong>{{ activeUser.name }}</strong>
          <div><span class="badge" :class="activeUser.role === 'student' ? 'badge-info' : 'badge-purple'" style="font-size:10px;padding:2px 8px;">{{ roleLabel(activeUser.role) }}</span></div>
        </div>
      </div>
      <div class="chat-header" v-else>
        <i class="ri-chat-3-line" style="font-size:22px;color:var(--text-muted);"></i>
        <span class="text-muted">اختر جهة اتصال لبدء المحادثة</span>
      </div>

      <div class="chat-messages" id="chatMsgs">
        <div v-if="!activeUser" class="empty" style="margin:auto;">
          <i class="ri-message-3-line" style="font-size:48px;color:var(--border);display:block;margin-bottom:12px;"></i>
          اختر محادثة من القائمة
        </div>
        <div v-else-if="loadingMessages" class="loading" style="margin:auto;"></div>
        <div v-else-if="!messages.length" class="empty" style="margin:auto;">
          <i class="ri-chat-new-line" style="font-size:48px;color:var(--border);display:block;margin-bottom:12px;"></i>
          ابدأ المحادثة مع {{ activeUser.name }}
        </div>
        <template v-else>
          <div v-for="(m, i) in messages" :key="i" class="msg" :class="m.is_mine ? 'out' : 'in'">
            <div>{{ m.body }}</div>
            <div style="font-size:10px;opacity:0.7;margin-top:4px;">{{ m.time || '' }}</div>
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
