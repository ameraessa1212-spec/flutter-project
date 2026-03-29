import { createRouter, createWebHistory } from 'vue-router'

import LoginView from '../views/LoginView.vue'
import AdminLayout from '../layouts/AdminLayout.vue'
import ExaminerLayout from '../layouts/ExaminerLayout.vue'

// Admin pages
import DashboardView from '../views/admin/DashboardView.vue'
import StudentsView from '../views/admin/StudentsView.vue'
import RequestsView from '../views/admin/RequestsView.vue'
import UploadView from '../views/admin/UploadView.vue'
import ReportsView from '../views/admin/ReportsView.vue'
import EvaluationView from '../views/admin/EvaluationView.vue'
import CompanyOffersView from '../views/admin/CompanyOffersView.vue'
import RegisteredCompaniesView from '../views/admin/RegisteredCompaniesView.vue'
import CompanyAccountsView from '../views/admin/CompanyAccountsView.vue'
import ExaminerAccountsView from '../views/admin/ExaminerAccountsView.vue'
import EvaluationListView from '../views/admin/EvaluationListView.vue'
import ReceiveResultsView from '../views/admin/ReceiveResultsView.vue'
import SystemReportsView from '../views/admin/SystemReportsView.vue'
import DiscussionScheduleView from '../views/admin/DiscussionScheduleView.vue'
import ChatView from '../views/admin/ChatView.vue'

// Examiner pages
import ExaminerHome from '../views/examiner/ExaminerHome.vue'
import ExaminerReports from '../views/examiner/ExaminerReports.vue'
import ExaminerGrades from '../views/examiner/ExaminerGrades.vue'
import ExaminerSchedule from '../views/examiner/ExaminerSchedule.vue'

const routes = [
  { path: '/login', name: 'login', component: LoginView, meta: { guest: true } },

  {
    path: '/',
    component: AdminLayout,
    meta: { auth: true },
    children: [
      { path: '', name: 'dashboard', component: DashboardView },
      { path: 'students', name: 'students', component: StudentsView },
      { path: 'requests', name: 'requests', component: RequestsView },
      { path: 'upload', name: 'upload', component: UploadView },
      { path: 'reports', name: 'reports', component: ReportsView },
      { path: 'evaluation', name: 'evaluation', component: EvaluationView },
      { path: 'company-offers', name: 'company-offers', component: CompanyOffersView },
      { path: 'registered-companies', name: 'registered-companies', component: RegisteredCompaniesView },
      { path: 'company-accounts', name: 'company-accounts', component: CompanyAccountsView },
      { path: 'examiner-accounts', name: 'examiner-accounts', component: ExaminerAccountsView },
      { path: 'evaluation-list', name: 'evaluation-list', component: EvaluationListView },
      { path: 'receive-results', name: 'receive-results', component: ReceiveResultsView },
      { path: 'system-reports', name: 'system-reports', component: SystemReportsView },
      { path: 'discussion-schedule', name: 'discussion-schedule', component: DiscussionScheduleView },
      { path: 'chat', name: 'chat', component: ChatView },
    ],
  },

  {
    path: '/examiner',
    component: ExaminerLayout,
    meta: { auth: true },
    children: [
      { path: '', name: 'examiner-home', component: ExaminerHome },
      { path: 'reports', name: 'examiner-reports', component: ExaminerReports },
      { path: 'grades', name: 'examiner-grades', component: ExaminerGrades },
      { path: 'schedule', name: 'examiner-schedule', component: ExaminerSchedule },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// Auth guard
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('admin_token')

  if (to.meta.auth && !token) {
    return next('/login')
  }

  if (to.meta.guest && token) {
    const user = JSON.parse(localStorage.getItem('admin_user') || '{}')
    return next(user.role === 'examiner' ? '/examiner' : '/')
  }

  next()
})

export default router
