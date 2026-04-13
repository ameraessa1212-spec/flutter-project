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
  { label: 'الرئيسية', icon: 'ri-home-4-line', to: '/', name: 'dashboard' },
  { group: 'الطلاب', items: [
    { label: 'تحميل قائمة الطلاب', icon: 'ri-upload-2-line', to: '/upload', name: 'upload' },
    { label: 'بيانات الطلاب', icon: 'ri-id-card-line', to: '/student', name: 'student' },
    { label: 'تقارير الطلاب', icon: 'ri-file-text-line', to: '/reports', name: 'reports' },
    { label: 'النتائج النهائية', icon: 'ri-bar-chart-line', to: '/evaluation', name: 'evaluation' },
    { label: 'إدارة الحسابات', icon: 'ri-user-settings-line', to: '/students', name: 'students' },
    { label: 'تواصل مع الطلاب', icon: 'ri-mail-send-line', to: '/chat', name: 'contact-students' },
  ]},
  { group: 'الممتحنين', items: [
    { label: 'تحويل التقارير', icon: 'ri-file-transfer-line', to: '/evaluation-list', name: 'evaluation-list' },
    { label: 'استلام التقييم', icon: 'ri-clipboard-line', to: '/receive-results', name: 'receive-results' },
    { label: 'إدارة الحسابات', icon: 'ri-admin-line', to: '/examiner-accounts', name: 'examiner-accounts' },
  ]},
  { group: 'الشركات', items: [
    { label: 'عروض التدريب', icon: 'ri-briefcase-line', to: '/company-offers', name: 'company-offers' },
    { label: 'الشركات المسجلة', icon: 'ri-community-line', to: '/registered-companies', name: 'registered-companies' },
    { label: 'تقييمات الشركات', icon: 'ri-star-line', to: '/company-evaluations', name: 'company-evaluations' },
    { label: 'إدارة الحسابات', icon: 'ri-settings-5-line', to: '/company-accounts', name: 'company-accounts' },
  ]},
  { label: 'تقارير النظام', icon: 'ri-file-chart-line', to: '/system-reports', name: 'system-reports' },
  { label: 'جدول المناقشة', icon: 'ri-calendar-event-line', to: '/discussion-schedule', name: 'discussion-schedule' },
]
</script>

<template>
  <div class="layout">
    <aside class="sidebar">
      <div class="logo">لوحة التحكم</div>
      <nav>
        <template v-for="(item, i) in menu" :key="i">
          <router-link v-if="item.to" :to="item.to" class="nav-item" :class="{ active: route.name === item.name }">
            <i :class="item.icon"></i> {{ item.label }}
          </router-link>
          <template v-else-if="item.group">
            <div class="nav-group-title">{{ item.group }}</div>
            <router-link v-for="sub in item.items" :key="sub.name" :to="sub.to" class="nav-item" :class="{ active: route.name === sub.name }">
              <i :class="sub.icon"></i> {{ sub.label }}
            </router-link>
          </template>
        </template>
      </nav>
      <div class="sidebar-footer">
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:14px;padding:0 4px;">
          <div class="avatar-circle" style="width:36px;height:36px;font-size:14px;">{{ (user?.name || '?').charAt(0) }}</div>
          <div>
            <div style="font-size:13px;font-weight:600;color:rgba(255,255,255,.9);">{{ user?.name }}</div>
            <div style="font-size:11px;color:rgba(255,255,255,.4);">{{ user?.role }}</div>
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
