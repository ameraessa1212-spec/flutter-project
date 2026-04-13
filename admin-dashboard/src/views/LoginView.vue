<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '../composables/useApi'

const router = useRouter()
const { login } = useAuth()

const loginField = ref('')
const password = ref('')
const role = ref('admin')
const loading = ref(false)
const error = ref('')

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    const data = await login(loginField.value, password.value, role.value)
    if (data.user.role === 'examiner') {
      router.push('/examiner')
    } else {
      router.push('/')
    }
  } catch (e) {
    error.value = e.response?.data?.message || e.response?.data?.errors?.login?.[0] || 'حدث خطأ في تسجيل الدخول'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-wrapper">
    <form class="login-card" @submit.prevent="handleLogin">
      <div class="text-center mb-md">
        <div style="width:56px;height:56px;border-radius:16px;background:linear-gradient(135deg,#6C5CE7,#A29BFE);display:flex;align-items:center;justify-content:center;margin:0 auto 16px;box-shadow:0 8px 24px rgba(108,92,231,0.3);">
          <i class="ri-shield-flash-line" style="font-size:26px;color:white;"></i>
        </div>
        <h1>مرحباً بك</h1>
        <p>يرجى إدخال بياناتك للدخول إلى لوحة التحكم</p>
      </div>

      <div class="role-toggle">
        <button type="button" class="role-btn" :class="{ active: role === 'admin' }" @click="role = 'admin'">
          <i class="ri-settings-5-fill"></i> مشرف
        </button>
        <button type="button" class="role-btn" :class="{ active: role === 'examiner' }" @click="role = 'examiner'">
          <i class="ri-user-star-fill"></i> ممتحن
        </button>
      </div>

      <div class="form-group">
        <label>اسم المستخدم أو البريد الإلكتروني</label>
        <input v-model="loginField" type="text" class="form-input" placeholder="أدخل اسم المستخدم" required>
      </div>

      <div class="form-group">
        <label>كلمة المرور</label>
        <input v-model="password" type="password" class="form-input" placeholder="أدخل كلمة المرور" required>
      </div>

      <button type="submit" class="login-btn" :disabled="loading">
        <i v-if="loading" class="ri-loader-4-line" style="animation:spin 0.7s linear infinite;"></i>
        {{ loading ? 'جاري التحقق...' : 'تسجيل الدخول' }}
      </button>

      <p v-if="error" class="login-error">{{ error }}</p>
    </form>
  </div>
</template>
