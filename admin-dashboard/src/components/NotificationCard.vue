<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { api } from '../composables/useApi'

const notifications = ref([])
const unreadCount = ref(0)
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
    const { data } = await api.get('/notifications', { params: { per_page: 50 } })
    notifications.value = data.data || []
  } catch (_) {}
  isLoading.value = false
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

function dateLabel(dateStr) {
  if (!dateStr) return 'غير محدد'
  const d = new Date(dateStr)
  const today = new Date()
  const yesterday = new Date()
  yesterday.setDate(today.getDate() - 1)
  if (d.toDateString() === today.toDateString()) return 'اليوم'
  if (d.toDateString() === yesterday.toDateString()) return 'أمس'
  return d.toLocaleDateString('ar-SA', { year: 'numeric', month: 'short', day: 'numeric' })
}

const grouped = computed(() => {
  const groups = {}
  for (const n of notifications.value) {
    const label = dateLabel(n.created_at)
    if (!groups[label]) groups[label] = []
    groups[label].push(n)
  }
  return groups
})

onMounted(() => {
  fetchUnreadCount()
  fetchNotifications()
  pollInterval = setInterval(fetchUnreadCount, 30000)
})

onUnmounted(() => {
  clearInterval(pollInterval)
})
</script>

<template>
  <div class="card notif-card">
    <div class="card-header">
      <span class="card-title">
        <i class="ri-notification-3-line" style="color:var(--primary);margin-left:6px;"></i>
        الإشعارات
      </span>
      <div style="display:flex;align-items:center;gap:10px;">
        <span v-if="unreadCount > 0" class="badge badge-purple">{{ unreadCount }} غير مقروء</span>
        <button v-if="unreadCount > 0" class="mark-all-btn" @click="markAllRead">تحديد الكل كمقروء</button>
      </div>
    </div>

    <div v-if="isLoading" class="notif-loading">جاري التحميل...</div>
    <div v-else-if="notifications.length === 0" class="notif-empty">لا توجد إشعارات</div>
    <div v-else class="notif-groups">
      <div v-for="(items, label) in grouped" :key="label" class="notif-group">
        <div class="group-label">{{ label }}</div>
        <div
          v-for="n in items"
          :key="n.id"
          class="notif-item"
          :class="{ unread: !n.is_read }"
          @click="markRead(n)"
        >
          <div class="notif-dot" v-if="!n.is_read"></div>
          <div class="notif-icon" v-else>
            <i class="ri-checkbox-circle-line"></i>
          </div>
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
.notif-card {
  max-height: 500px;
  display: flex;
  flex-direction: column;
}

.notif-groups {
  overflow-y: auto;
  flex: 1;
  padding: 0 0 8px;
}

.group-label {
  font-size: 12px;
  font-weight: 700;
  color: var(--text-muted);
  padding: 12px 20px 6px;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.notif-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 10px 20px;
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

.notif-icon {
  color: var(--success);
  font-size: 16px;
  flex-shrink: 0;
  margin-top: 2px;
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

.mark-all-btn {
  background: none;
  border: none;
  color: var(--primary);
  cursor: pointer;
  font-size: 12px;
  font-weight: 600;
  font-family: inherit;
}
.mark-all-btn:hover {
  text-decoration: underline;
}
</style>
