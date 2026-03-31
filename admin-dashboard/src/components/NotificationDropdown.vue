<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { api } from '../composables/useApi'

const notifications = ref([])
const unreadCount = ref(0)
const isOpen = ref(false)
const isLoading = ref(false)
let pollInterval = null

async function fetchUnreadCount() {
  try {
    const { data } = await api.get('/notifications/unread-count')
    unreadCount.value = data.data.count
  } catch (_) {}
}

async function fetchNotifications() {
  isLoading.value = true
  try {
    const { data } = await api.get('/notifications', { params: { per_page: 15 } })
    notifications.value = data.data || []
  } catch (_) {}
  isLoading.value = false
}

function toggle() {
  isOpen.value = !isOpen.value
  if (isOpen.value) fetchNotifications()
}

async function markRead(n) {
  if (n.is_read) return
  try {
    await api.patch(`/notifications/${n.id}/read`)
    n.is_read = true
    n.read_at = new Date().toISOString()
    unreadCount.value = Math.max(0, unreadCount.value - 1)
  } catch (_) {}
}

async function markAllRead() {
  try {
    await api.patch('/notifications/read-all')
    notifications.value.forEach(n => { n.is_read = true })
    unreadCount.value = 0
  } catch (_) {}
}

function timeAgo(dateStr) {
  if (!dateStr) return ''
  const diff = Date.now() - new Date(dateStr).getTime()
  const mins = Math.floor(diff / 60000)
  if (mins < 1) return 'الآن'
  if (mins < 60) return `منذ ${mins} د`
  const hrs = Math.floor(mins / 60)
  if (hrs < 24) return `منذ ${hrs} س`
  const days = Math.floor(hrs / 24)
  return `منذ ${days} ي`
}

function handleClickOutside(e) {
  const el = document.querySelector('.notif-wrapper')
  if (el && !el.contains(e.target)) isOpen.value = false
}

onMounted(() => {
  fetchUnreadCount()
  pollInterval = setInterval(fetchUnreadCount, 30000)
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  clearInterval(pollInterval)
  document.removeEventListener('click', handleClickOutside)
})
</script>

<template>
  <div class="notif-wrapper">
    <button class="notif-bell" @click.stop="toggle" title="الإشعارات">
      <i class="ri-notification-3-line"></i>
      <span v-if="unreadCount > 0" class="notif-badge">{{ unreadCount > 9 ? '9+' : unreadCount }}</span>
    </button>

    <div v-if="isOpen" class="notif-dropdown">
      <div class="notif-header">
        <span>الإشعارات</span>
        <button v-if="unreadCount > 0" class="mark-all-btn" @click="markAllRead">تحديد الكل كمقروء</button>
      </div>

      <div v-if="isLoading" class="notif-loading">جاري التحميل...</div>
      <div v-else-if="notifications.length === 0" class="notif-empty">لا توجد إشعارات</div>
      <div v-else class="notif-list">
        <div
          v-for="n in notifications"
          :key="n.id"
          class="notif-item"
          :class="{ unread: !n.is_read }"
          @click="markRead(n)"
        >
          <div class="notif-dot" v-if="!n.is_read"></div>
          <div class="notif-content">
            <div class="notif-title">{{ n.title }}</div>
            <div class="notif-body">{{ n.body }}</div>
            <div class="notif-time">{{ timeAgo(n.created_at) }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.notif-wrapper {
  position: relative;
}

.notif-bell {
  background: none;
  border: none;
  cursor: pointer;
  position: relative;
  font-size: 22px;
  color: var(--text-secondary);
  padding: 6px;
  border-radius: 50%;
  transition: var(--transition);
}
.notif-bell:hover {
  background: var(--primary-bg);
  color: var(--primary);
}

.notif-badge {
  position: absolute;
  top: 0;
  right: 0;
  background: var(--danger);
  color: #fff;
  font-size: 10px;
  font-weight: 700;
  min-width: 18px;
  height: 18px;
  border-radius: 9px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 4px;
}

.notif-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  width: 340px;
  max-height: 420px;
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  border: 1px solid var(--border);
  z-index: 1000;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.notif-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px;
  border-bottom: 1px solid var(--border);
  font-weight: 700;
  font-size: 15px;
  color: var(--text-primary);
}

.mark-all-btn {
  background: none;
  border: none;
  color: var(--primary);
  cursor: pointer;
  font-size: 12px;
  font-weight: 600;
}
.mark-all-btn:hover {
  text-decoration: underline;
}

.notif-list {
  overflow-y: auto;
  flex: 1;
}

.notif-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 12px 16px;
  cursor: pointer;
  transition: var(--transition);
  border-bottom: 1px solid var(--border-light);
}
.notif-item:hover {
  background: var(--primary-bg);
}
.notif-item.unread {
  background: rgba(108, 92, 231, 0.04);
}

.notif-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--primary);
  flex-shrink: 0;
  margin-top: 6px;
}

.notif-content {
  flex: 1;
  min-width: 0;
}

.notif-title {
  font-weight: 600;
  font-size: 13px;
  color: var(--text-primary);
  margin-bottom: 2px;
}

.notif-body {
  font-size: 12px;
  color: var(--text-secondary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.notif-time {
  font-size: 11px;
  color: var(--text-muted);
  margin-top: 4px;
}

.notif-loading, .notif-empty {
  padding: 32px 16px;
  text-align: center;
  color: var(--text-muted);
  font-size: 13px;
}
</style>
