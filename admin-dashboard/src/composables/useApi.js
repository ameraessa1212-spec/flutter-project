import axios from 'axios'
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const API_BASE = 'http://localhost:8000/api/admin'

const api = axios.create({
  baseURL: API_BASE,
  headers: { Accept: 'application/json' },
})

// Attach token to every request
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Handle 401 globally
api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem('admin_token')
      localStorage.removeItem('admin_user')
      window.location.replace('/login')
    }
    return Promise.reject(err)
  }
)

export function useAuth() {
  const user = ref(JSON.parse(localStorage.getItem('admin_user') || 'null'))
  const token = ref(localStorage.getItem('admin_token'))

  const isLoggedIn = () => !!localStorage.getItem('admin_token')

  async function login(loginField, password, role) {
    const { data } = await api.post('/login', { login: loginField, password, role })
    localStorage.setItem('admin_token', data.data.token)
    localStorage.setItem('admin_user', JSON.stringify(data.data.user))
    token.value = data.data.token
    user.value = data.data.user
    return data.data
  }

  async function logout() {
    try { await api.post('/logout') } catch (e) { /* ignore */ }
    localStorage.removeItem('admin_token')
    localStorage.removeItem('admin_user')
    token.value = null
    user.value = null
  }

  return { user, token, isLoggedIn, login, logout }
}

export default api
