// Global API Configuration
const CONFIG = {

    API_BASE_URL: 'http://localhost:9000/api'
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

function requestCompanyDashboardRefresh(detail = {}) {
    if (!window.parent || window.parent === window) {
        return false;
    }

    try {
        if (typeof window.parent.refreshCompanyDashboard === 'function') {
            window.parent.refreshCompanyDashboard(detail);
            return true;
        }
    } catch (error) {
        // Fall back to postMessage when direct access is unavailable.
    }

    try {
        window.parent.postMessage({
            type: 'company-dashboard-refresh',
            detail
        }, '*');
        return true;
    } catch (error) {
        console.warn('Unable to request dashboard refresh:', error);
    }

    return false;
}