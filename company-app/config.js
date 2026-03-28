// Global API Configuration
const CONFIG = {
    // Determine API Base URL dynamically (e.g., if hosted on the same domain or a specific staging/production domain)
    // For now, it defaults to the local Laravel backend. In production context, this could be changed to the real domain.
    API_BASE_URL: window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' 
        ? 'https://flutter-project-main-vmkevy.free.laravel.cloud/api'
        : 'https://flutter-project-main-vmkevy.free.laravel.cloud/api', // Example production URL
};

// Global helper for fetching with auth
async function apiFetch(endpoint, options = {}) {
    const token = localStorage.getItem('company_token');
    
    const headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...options.headers,
    };

    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    const config = {
        ...options,
        headers,
    };

    return fetch(`${CONFIG.API_BASE_URL}${endpoint}`, config);
}