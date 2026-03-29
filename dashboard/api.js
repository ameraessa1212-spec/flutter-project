const API_BASE = 'http://localhost:8000/api/admin';

let _isRedirecting = false;

function getToken() {
    return localStorage.getItem('admin_token');
}

function setToken(token) {
    localStorage.setItem('admin_token', token);
}

function setUser(user) {
    localStorage.setItem('admin_user', JSON.stringify(user));
}

function getUser() {
    const data = localStorage.getItem('admin_user');
    return data ? JSON.parse(data) : null;
}

function clearAuth() {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
}

function redirectToLogin() {
    if (_isRedirecting) return;

    // Never redirect if already on the login page
    if (window.location.pathname.endsWith('index.html') || window.location.pathname === '/' || window.location.pathname.endsWith('/')) {
        return;
    }

    _isRedirecting = true;
    clearAuth();
    window.location.href = 'index.html';
}

// Auth guard — call on protected pages to check token before doing anything
function requireAuth() {
    if (!getToken()) {
        redirectToLogin();
        return false;
    }
    return true;
}

async function apiRequest(endpoint, options = {}) {
    const token = getToken();

    if (!token && !options.skipAuth) {
        redirectToLogin();
        return null;
    }

    const headers = {
        'Accept': 'application/json',
        ...(options.headers || {}),
    };

    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    // Don't set Content-Type for FormData (browser sets it with boundary)
    if (!(options.body instanceof FormData)) {
        headers['Content-Type'] = 'application/json';
    }

    try {
        const response = await fetch(`${API_BASE}${endpoint}`, {
            ...options,
            headers,
        });

        if (response.status === 401) {
            redirectToLogin();
            return null;
        }

        if (response.status === 403) {
            const data = await response.json();
            alert(data.message || 'ليس لديك صلاحية.');
            return null;
        }

        if (!response.ok) {
            const data = await response.json().catch(() => ({}));
            throw { status: response.status, data };
        }

        return await response.json();
    } catch (error) {
        // Network error (server not running) — don't redirect, just fail gracefully
        if (!error.status) {
            console.error('Network error:', error);
            return null;
        }
        throw error;
    }
}

async function apiGet(endpoint) {
    return apiRequest(endpoint);
}

async function apiPost(endpoint, body) {
    if (body instanceof FormData) {
        return apiRequest(endpoint, { method: 'POST', body });
    }
    return apiRequest(endpoint, { method: 'POST', body: JSON.stringify(body) });
}

async function apiPut(endpoint, body) {
    return apiRequest(endpoint, { method: 'PUT', body: JSON.stringify(body) });
}

async function apiDelete(endpoint) {
    return apiRequest(endpoint, { method: 'DELETE' });
}
