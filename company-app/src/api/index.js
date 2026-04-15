const DEFAULT_API_BASE_URL = 'http://localhost:9000/'

function joinUrl(baseUrl, path) {
  return `${baseUrl.replace(/\/+$/, '')}/${path.replace(/^\/+/, '')}`
}

const API_BASE_URL = joinUrl(
  import.meta.env.VITE_API_BASE_URL || DEFAULT_API_BASE_URL,
  'api'
)

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
