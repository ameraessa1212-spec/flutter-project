<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'
import { useAuth } from '../../composables/useApi'
import NotificationCard from '../../components/NotificationCard.vue'

const { user } = useAuth()
const stats = ref({ total_students: 0, active_trainees: 0, total_companies: 0, pending_requests: 0 })
const alerts = ref([])
const loading = ref(true)

onMounted(async () => {
  const [s, a] = await Promise.all([
    api.get('/dashboard/stats').catch(() => null),
    api.get('/dashboard/alerts').catch(() => null),
  ])
  if (s?.data?.data) stats.value = s.data.data
  if (a?.data?.data) alerts.value = a.data.data
  loading.value = false
})

const greeting = () => {
  const h = new Date().getHours()
  if (h < 12) return 'صباح الخير'
  if (h < 18) return 'مساء الخير'
  return 'مساء الخير'
}
</script>

<template>
  <div>
    <!-- Welcome Banner -->
    <div class="card mb-lg" style="background:linear-gradient(135deg,#6C5CE7 0%,#A29BFE 50%,#74B9FF 100%);border:none;padding:32px 36px;color:white;position:relative;overflow:hidden;">
      <div style="position:absolute;width:200px;height:200px;border-radius:50%;background:rgba(255,255,255,0.08);top:-60px;left:-40px;"></div>
      <div style="position:absolute;width:150px;height:150px;border-radius:50%;background:rgba(255,255,255,0.05);bottom:-30px;right:60px;"></div>
      <div style="position:relative;z-index:1;">
        <h2 style="color:white;font-size:22px;margin-bottom:6px;">{{ greeting() }}، {{ user?.name || 'المشرف' }}</h2>
        <p style="opacity:0.85;font-size:14px;">إليك ملخص نشاط نظام التدريب الميداني</p>
      </div>
    </div>

    <!-- Stats -->
    <div class="grid-4 mb-lg">
      <div class="stat-card">
        <div class="icon blue"><i class="ri-group-line"></i></div>
        <div><h3>{{ stats.total_students }}</h3><p>إجمالي الطلاب</p></div>
      </div>
      <div class="stat-card">
        <div class="icon green"><i class="ri-user-follow-line"></i></div>
        <div><h3>{{ stats.active_trainees }}</h3><p>متدربون حالياً</p></div>
      </div>
      <div class="stat-card">
        <div class="icon orange"><i class="ri-building-2-line"></i></div>
        <div><h3>{{ stats.total_companies }}</h3><p>شركات مسجلة</p></div>
      </div>
      <div class="stat-card">
        <div class="icon red"><i class="ri-time-line"></i></div>
        <div><h3>{{ String(stats.pending_requests).padStart(2, '0') }}</h3><p>طلبات معلقة</p></div>
      </div>
    </div>

    <!-- Alerts & Notifications -->
    <div class="grid-2 mb-lg">
      <div class="card">
        <div class="card-header">
          <span class="card-title"><i class="ri-alarm-warning-line" style="color:var(--danger);margin-left:6px;"></i> تنبيهات عاجلة</span>
          <span class="badge badge-purple">{{ alerts.length }}</span>
        </div>
        <div v-if="loading" class="loading" style="padding:30px;"></div>
        <div v-else-if="alerts.length === 0" class="empty" style="padding:30px;">لا توجد تنبيهات حالياً</div>
        <template v-else>
          <div v-for="(a, i) in alerts" :key="i" class="alert-item" :class="a.type">
            <i :class="a.type === 'danger' ? 'ri-error-warning-line' : 'ri-information-line'" style="font-size:20px;margin-top:2px;"></i>
            <div>
              <strong>{{ a.title }}</strong>
              <small>{{ a.message }}</small>
            </div>
          </div>
        </template>
      </div>

      <NotificationCard />
    </div>
  </div>
</template>
