import { createRouter, createWebHistory } from 'vue-router'

import LandingPage from '../views/LandingPage.vue'
import LoginPage from '../views/LoginPage.vue'
import SignupPage from '../views/SignupPage.vue'
import DashboardLayout from '../views/dashboard/DashboardLayout.vue'
import DashboardHome from '../views/dashboard/DashboardHome.vue'
import PostOpportunity from '../views/dashboard/PostOpportunity.vue'
import StudentsRequests from '../views/dashboard/StudentsRequests.vue'
import CompanyEvaluation from '../views/dashboard/CompanyEvaluation.vue'

const routes = [
  { path: '/', name: 'landing', component: LandingPage },
  { path: '/login', name: 'login', component: LoginPage },
  { path: '/signup', name: 'signup', component: SignupPage },
  {
    path: '/dashboard',
    component: DashboardLayout,
    meta: { requiresAuth: true },
    children: [
      { path: '', name: 'dashboard-home', component: DashboardHome },
      { path: 'post', name: 'dashboard-post', component: PostOpportunity },
      { path: 'requests', name: 'dashboard-requests', component: StudentsRequests },
      { path: 'eval', name: 'dashboard-eval', component: CompanyEvaluation },
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to) => {
  if (to.matched.some(r => r.meta.requiresAuth)) {
    const token = localStorage.getItem('company_token')
    if (!token) {
      return { name: 'login' }
    }
  }
})

export default router
