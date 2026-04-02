<script setup>
import { useRouter, useRoute } from 'vue-router'
import { useAuth } from '../composables/useApi'

const router = useRouter()
const route = useRoute()
const { user, logout } = useAuth()

async function handleLogout() {
  await logout()
  router.push('/login')
}

const menu = [
  { label: 'الرئيسية', icon: 'ri-dashboard-line', to: '/examiner', name: 'examiner-home' },
  { label: 'تقارير الطلاب', icon: 'ri-file-text-line', to: '/examiner/reports', name: 'examiner-reports' },
  { label: 'نتائج التقييم', icon: 'ri-medal-line', to: '/examiner/grades', name: 'examiner-grades' },
  { label: 'جدول المناقشة', icon: 'ri-calendar-event-line', to: '/examiner/schedule', name: 'examiner-schedule' },
]
</script>

<template>
  <div class="layout">
    <aside class="sidebar">
      <div class="logo">
        بوابة الممتحن
      </div>
      <nav>
        <router-link v-for="item in menu" :key="item.name" :to="item.to" class="nav-item" :class="{ active: route.name === item.name }">
          <i :class="item.icon"></i> {{ item.label }}
        </router-link>
      </nav>
      <div class="sidebar-footer">
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:14px;padding:0 4px;">
          <div class="avatar-circle" style="width:36px;height:36px;font-size:14px;">{{ (user?.name || '?').charAt(0) }}</div>
          <div>
            <div style="font-size:13px;font-weight:600;color:rgba(255,255,255,.9);">{{ user?.name }}</div>
            <div style="font-size:11px;color:rgba(255,255,255,.4);">ممتحن</div>
          </div>
        </div>
        <button class="logout-btn" @click="handleLogout">
          <i class="ri-logout-box-r-line"></i> تسجيل الخروج
        </button>
      </div>
    </aside>
    <main class="main">
      <router-view />
    </main>
  </div>
</template>
