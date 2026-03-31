import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('company_token') || null)
  const user = ref(JSON.parse(localStorage.getItem('company_user') || 'null'))
  const company = ref(JSON.parse(localStorage.getItem('company_profile') || 'null'))

  const isAuthenticated = computed(() => !!token.value)
  const companyName = computed(() => company.value?.name || 'شركة')

  function setAuth(data) {
    token.value = data.token
    user.value = data.user
    company.value = data.company

    localStorage.setItem('company_token', data.token)
    localStorage.setItem('company_user', JSON.stringify(data.user))
    localStorage.setItem('company_profile', JSON.stringify(data.company))
  }

  function logout() {
    token.value = null
    user.value = null
    company.value = null

    localStorage.removeItem('company_token')
    localStorage.removeItem('company_user')
    localStorage.removeItem('company_profile')
  }

  return { token, user, company, isAuthenticated, companyName, setAuth, logout }
})
