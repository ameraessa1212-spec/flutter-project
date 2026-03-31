<template>
  <div class="dashboard-wrapper">
    <aside class="sidebar">
      <div class="sidebar-header">
        <div class="logo">وصلة<span></span>تدريب.</div>
      </div>

      <nav class="menu">
        <div class="menu-label">القائمة الرئيسية</div>

        <router-link to="/dashboard" class="menu-item" :class="{ active: activeTab === 'home' }" @click="activeTab = 'home'">
          <div class="icon-box"><i class="ri-dashboard-fill"></i></div>
          <span>الرئيسية</span>
        </router-link>

        <router-link to="/dashboard/post" class="menu-item" :class="{ active: activeTab === 'post' }" @click="activeTab = 'post'">
          <div class="icon-box"><i class="ri-add-circle-line"></i></div>
          <span>إضافة فرصة تدريبية</span>
        </router-link>

        <router-link to="/dashboard/requests" class="menu-item" :class="{ active: activeTab === 'requests' }" @click="activeTab = 'requests'">
          <div class="icon-box"><i class="ri-group-line"></i></div>
          <span>طلبات الطلبة</span>
          <span class="badge-new" v-if="stats.pendingRequests > 0">{{ stats.pendingRequests }} جديد</span>
        </router-link>

        <router-link to="/dashboard/eval" class="menu-item" :class="{ active: activeTab === 'eval' }" @click="activeTab = 'eval'">
          <div class="icon-box"><i class="ri-bar-chart-box-line"></i></div>
          <span>تقييم الطلبة</span>
        </router-link>
      </nav>

      <div class="sidebar-footer">
        <div class="company-mini-card">
          <img :src="`https://ui-avatars.com/api/?name=${auth.companyName}&background=6A5AE0&color=fff`" :alt="auth.companyName">
          <div class="info">
            <p class="name">{{ auth.companyName }}</p>
            <p class="role">مسؤول التدريب</p>
          </div>
        </div>
        <a href="#" class="logout-btn" @click.prevent="handleLogout">
          <i class="ri-logout-circle-r-line"></i>
        </a>
      </div>
    </aside>

    <main class="main-content">
      <header class="content-header animate-fade">
        <div class="header-title">
          <h2>{{ headerTitle }}</h2>
          <p>{{ headerSubtitle }}</p>
        </div>
        <div class="header-actions">
          <button class="notif-btn"><i class="ri-notification-3-line"></i><span class="dot" v-if="stats.pendingRequests > 0"></span></button>
          <div class="date-display">
            <i class="ri-calendar-event-line"></i>
            <span>{{ currentDate }}</span>
          </div>
        </div>
      </header>

      <router-view
        :stats="stats"
        :students-list="studentsList"
        @refresh="refreshDashboard"
      />
    </main>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, provide } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../../stores/auth'
import { apiFetch } from '../../api'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()

const stats = ref({
  activeStudents: 0,
  opportunities: 0,
  pendingRequests: 0,
  growth: '+0%',
  rating: '4.8'
})
const studentsList = ref([])

const currentDate = new Intl.DateTimeFormat('ar-LY', { day: 'numeric', month: 'long', year: 'numeric' }).format(new Date())

const pagesInfo = {
  'dashboard-home': { title: '', sub: '' },
  'dashboard-post': { title: 'إضافة فرصة تدريبية', sub: 'اطلب متدربين جدد للانضمام إلى فريقك' },
  'dashboard-requests': { title: 'طلبات التدريب الواردة', sub: 'إدارة ومراجعة طلبات الطلاب المتقدمين للفرص التدريبية' },
  'dashboard-eval': { title: 'نموذج تقييم المتدربين', sub: 'تقييم الأداء المهني والسلوكي للطلاب خلال فترة التدريب' }
}

const activeTab = ref('home')

const headerTitle = computed(() => {
  if (activeTab.value === 'home') {
    const hour = new Date().getHours()
    const greeting = hour < 12 ? 'صباح الخير' : 'مساء الخير'
    return `${greeting}، ${auth.companyName} 👋`
  }
  const info = pagesInfo[route.name]
  return info?.title || ''
})

const headerSubtitle = computed(() => {
  if (activeTab.value === 'home') {
    return 'إليك ما يحدث في برنامج التدريب الخاص بك اليوم'
  }
  const info = pagesInfo[route.name]
  return info?.sub || ''
})

watch(() => route.name, (name) => {
  if (name === 'dashboard-home') activeTab.value = 'home'
  else if (name === 'dashboard-post') activeTab.value = 'post'
  else if (name === 'dashboard-requests') activeTab.value = 'requests'
  else if (name === 'dashboard-eval') activeTab.value = 'eval'
}, { immediate: true })

async function fetchStats() {
  try {
    const response = await apiFetch('/company/dashboard/stats')
    if (response.ok) {
      const data = await response.json()
      stats.value.activeStudents = data.active_interns || 0
      stats.value.opportunities = data.active_opportunities || 0
      stats.value.pendingRequests = data.pending_applications || 0
    }
  } catch (error) {
    console.error('Error fetching stats:', error)
  }
}

async function fetchDashboardData() {
  try {
    const response = await apiFetch('/company/internships')

    if (response.status === 401 || response.status === 403) {
      handleLogout()
      return
    }

    if (response.ok) {
      const data = await response.json()
      studentsList.value = data || []
      stats.value.activeStudents = studentsList.value.filter(s => s.status === 'active').length
    }
  } catch (error) {
    console.error('Error fetching dashboard data:', error)
  }
}

async function refreshDashboard() {
  await Promise.all([fetchDashboardData(), fetchStats()])
}

function handleLogout() {
  auth.logout()
  router.push('/login')
}

provide('refreshDashboard', refreshDashboard)

onMounted(() => {
  refreshDashboard()
})
</script>

<style scoped>
:root {
    --primary: #6A5AE0;
    --primary-light: #8E82EF;
    --bg-main: #F0F2F9;
    --white: #ffffff;
    --text-main: #2D3436;
    --text-muted: #636E72;
    --accent-purple: #EFE9FF;
    --accent-blue: #E1F5FE;
    --accent-green: #E8F5E9;
    --sidebar-w: 280px;
}

* { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Cairo', sans-serif; }

.dashboard-wrapper {
    display: flex; padding: 20px; gap: 20px; height: 100vh;
    background-color: #F0F2F9;
    color: #2D3436;
    direction: rtl;
}

.sidebar {
    width: 280px;
    background: #ffffff;
    border-radius: 30px;
    display: flex;
    flex-direction: column;
    padding: 30px 20px;
    box-shadow: 20px 0 40px rgba(0,0,0,0.02);
    transition: 0.4s ease;
}

.sidebar-header { margin-bottom: 40px; text-align: center; }
.logo { font-size: 22px; font-weight: 900; letter-spacing: 1px; }
.logo span { color: #6A5AE0; }

.menu-label {
    font-size: 12px; font-weight: 800; color: #BBB;
    margin: 20px 15px 10px; text-transform: uppercase;
}

.menu-item {
    display: flex; align-items: center; gap: 15px; padding: 12px 15px;
    text-decoration: none; color: #636E72; font-weight: 600;
    border-radius: 18px; transition: 0.3s; margin-bottom: 5px;
}

.icon-box {
    width: 38px; height: 38px; display: flex; align-items: center; justify-content: center;
    background: #F8F9FA; border-radius: 12px; transition: 0.3s;
}

.menu-item:hover .icon-box, .menu-item.active .icon-box {
    background: #6A5AE0; color: white;
}

.menu-item.active { background: #EFE9FF; color: #6A5AE0; }

.badge-new {
    margin-right: auto; background: #FF7675; color: white;
    font-size: 10px; padding: 4px 8px; border-radius: 8px;
}

.sidebar-footer {
    margin-top: auto;
    padding-top: 20px;
    border-top: 1px solid #F1F2F6;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.logout-btn {
    width: 42px;
    height: 42px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #FFF5F5;
    color: #FF4757;
    border-radius: 12px;
    border: 1px solid #FFEBEB;
    text-decoration: none;
    font-size: 20px;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.logout-btn:hover {
    background: #FF4757;
    color: #FFFFFF;
    border-color: #FF4757;
    transform: scale(1.1);
    box-shadow: 0 8px 15px rgba(255, 71, 87, 0.2);
}

.logout-btn:hover i {
    transform: translateX(-2px);
}

.company-mini-card { display: flex; align-items: center; gap: 10px; }
.company-mini-card img { width: 40px; height: 40px; border-radius: 12px; }
.company-mini-card .name { font-size: 14px; font-weight: 800; }
.company-mini-card .role { font-size: 11px; color: #AAA; }

.main-content { flex: 1; overflow-y: auto; padding: 10px 20px; }

.content-header {
    display: flex; justify-content: space-between; align-items: center;
    margin-bottom: 30px;
}

.header-actions { display: flex; gap: 15px; align-items: center; }
.notif-btn {
    width: 45px; height: 45px; border-radius: 15px; border: none;
    background: white; color: #636E72; position: relative; cursor: pointer;
}
.notif-btn .dot {
    position: absolute; top: 12px; right: 12px; width: 8px; height: 8px;
    background: #FF7675; border: 2px solid white; border-radius: 50%;
}

.date-display {
    background: white; padding: 10px 20px; border-radius: 15px;
    display: flex; align-items: center; gap: 10px; font-weight: 700; font-size: 14px;
}

.animate-fade {
    animation: fadeInUp 0.6s ease forwards;
}
@keyframes fadeInUp {
    from { transform: translateY(20px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}

@media (max-width: 1024px) {
    .sidebar { width: 90px; }
    .sidebar span, .menu-label, .company-mini-card .info, .badge-new { display: none; }
}
</style>
