const API_BASE_URL = 'http://localhost:9000/api'

export { API_BASE_URL }

export async function apiFetch(endpoint, options = {}) {
  const token = localStorage.getItem('company_token')

  const headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    ...options.headers,
  }

  if (token) {
    headers['Authorization'] = `Bearer ${token}`
  }

  const config = {
    ...options,
    headers,
  }

  return fetch(`${API_BASE_URL}${endpoint}`, config)
}
