<template>
  <div class="login-wrapper">
    <div class="login-card fade-up">
      <div class="login-header">
        <div class="login-logo">WASLAA<span>.</span></div>
        <h2>مرحباً بك مجدداً</h2>
        <p>الرجاء إدخال بياناتك للوصول إلى لوحة التحكم</p>
      </div>

      <div v-if="generalError" class="error-message" style="text-align:center; font-size: 1rem; margin-bottom:15px; background: #fee; padding:10px; border-radius:5px;">{{ generalError }}</div>

      <form @submit.prevent="submit">
        <div class="form-group">
          <label>البريد الإلكتروني</label>
          <div class="input-container">
            <i class="ri-mail-line"></i>
            <input type="email" v-model="formData.email" placeholder="name@company.com" required>
          </div>
        </div>

        <div class="form-group">
          <label>كلمة المرور</label>
          <div class="input-container">
            <i class="ri-lock-password-line"></i>
            <input type="password" v-model="formData.password" placeholder="••••••••" required>
          </div>
        </div>

        <button type="submit" class="login-btn" :disabled="loading">
          <span v-if="!loading">دخول للمنصة</span>
          <span v-else><i class="ri-loader-4-line rotate"></i> جاري الدخول...</span>
          <i class="ri-arrow-left-line" v-if="!loading"></i>
        </button>
      </form>

      <div class="login-footer">
        <span>ليس لديك حساب؟</span>
        <router-link to="/signup">سجل شركتك الآن</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { apiFetch } from '../api'

const router = useRouter()
const auth = useAuthStore()

const formData = reactive({ email: '', password: '' })
const generalError = ref(null)
const loading = ref(false)

async function submit() {
  loading.value = true
  generalError.value = null

  try {
    const response = await apiFetch('/company/login', {
      method: 'POST',
      body: JSON.stringify(formData)
    })

    const data = await response.json()

    if (!response.ok || !data.success) {
      generalError.value = data.message || 'بيانات الدخول غير صحيحة'
    } else {
      auth.setAuth({
        token: data.data.token,
        user: data.data.user,
        company: data.data.company
      })
      router.push('/dashboard')
    }
  } catch (error) {
    generalError.value = 'غير قادر على الاتصال بالخادم.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
:root {
    --primary: #6A5AE0;
    --primary-light: #f0e6ff;
    --text-main: #1a1a2e;
    --text-sub: #64748b;
    --bg-color: #f4f7ff;
}

* { margin: 0; padding: 0; box-sizing: border-box; }

.login-wrapper {
    font-family: 'Cairo', sans-serif;
    background-color: #f4f7ff;
    background-image: radial-gradient(circle at 0% 0%, rgba(138, 43, 226, 0.05) 0%, transparent 50%);
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    direction: rtl;
    width: 100%;
    padding: 20px;
}

.login-card {
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(15px);
    border: 1px solid rgba(255, 255, 255, 0.4);
    border-radius: 40px;
    padding: 50px 40px;
    width: 100%;
    max-width: 420px;
    box-shadow: 0 30px 60px rgba(0,0,0,0.05);
    text-align: center;
}

.login-logo { font-size: 28px; font-weight: 900; margin-bottom: 15px; }
.login-logo span { color: #6A5AE0; }

h2 { font-size: 22px; color: #1a1a2e; margin-bottom: 8px; }
p { font-size: 14px; color: #64748b; margin-bottom: 35px; }

.form-group { text-align: right; margin-bottom: 20px; }
.form-group label { display: block; font-size: 14px; font-weight: 700; margin-bottom: 8px; margin-right: 5px; }

.input-container { position: relative; display: flex; align-items: center; }
.input-container i { position: absolute; right: 15px; color: #6A5AE0; font-size: 18px; }

.input-container input {
    width: 100%;
    padding: 14px 45px 14px 15px;
    border-radius: 15px;
    border: 1.5px solid #e2e8f0;
    background: white;
    font-family: 'Cairo';
    outline: none;
    transition: 0.3s;
}

.input-container input:focus {
    border-color: #6A5AE0;
    box-shadow: 0 0 15px rgba(138, 43, 226, 0.1);
}

.login-btn {
    width: 100%;
    background: #6A5AE0;
    color: white;
    border: none;
    padding: 15px;
    border-radius: 15px;
    font-size: 16px;
    font-weight: 700;
    font-family: 'Cairo', sans-serif;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    transition: 0.3s;
    margin-top: 10px;
}
.login-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 25px rgba(138, 43, 226, 0.3);
}

.login-footer { margin-top: 30px; font-size: 14px; }
.login-footer a { color: #6A5AE0; text-decoration: none; font-weight: 900; margin-right: 5px; }

.error-message { color: #e74c3c; font-size: 0.85rem; margin-top: 5px; }
.rotate { animation: spin 1s linear infinite; display: inline-block; vertical-align: middle; margin-left: 8px; }
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

.fade-up {
    animation: fadeUp 0.8s forwards ease-out;
}
@keyframes fadeUp {
    from { opacity: 0; transform: translateY(30px); }
    to { opacity: 1; transform: translateY(0); }
}
</style>
