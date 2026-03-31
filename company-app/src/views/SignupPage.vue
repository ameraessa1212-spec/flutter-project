<template>
  <div class="signup-wrapper">
    <div class="signup-card fade-up">
      <div class="signup-header">
        <div class="logo">وصلة تدريب<span>.</span></div>
        <h2>تسجيل شركة جديدة</h2>
        <p>انضم إلينا وساهم في بناء مستقبل الكفاءات الشابة</p>
      </div>

      <div v-if="success" class="success-message">{{ successMessage }}</div>
      <div v-if="generalError" class="error-message" style="text-align:center; margin-bottom:15px;">{{ generalError }}</div>

      <form v-if="!success" @submit.prevent="submit" class="grid-form">

        <div class="form-group full-width upload-section">
          <label>شعار الشركة</label>
          <div class="logo-upload-container">
            <div class="logo-preview" @click="$refs.logoInput.click()">
              <div v-if="!logoPreview" class="upload-placeholder">
                <i class="ri-image-add-line"></i>
                <span>اضغط لرفع الشعار</span>
              </div>
              <img v-else :src="logoPreview" class="preview-img">
            </div>
            <input type="file" ref="logoInput" class="hidden-input" accept="image/*" @change="handleLogoUpload">
            <p class="upload-hint">يفضل صيغة PNG بخلفية شفافة</p>
          </div>
        </div>

        <div class="form-group">
          <label>اسم الشركة</label>
          <div class="input-box">
            <i class="ri-building-line"></i>
            <input type="text" v-model="formData.name" placeholder="مثلاً: شركة المدار الجديد" required>
          </div>
        </div>

        <div class="form-group">
          <label>البريد الإلكتروني</label>
          <div class="input-box">
            <i class="ri-mail-line"></i>
            <input type="email" v-model="formData.email" placeholder="hr@company.ly" required>
          </div>
          <span class="error-message" v-if="errors.email">{{ errors.email }}</span>
        </div>

        <div class="form-group">
          <label>كلمة المرور</label>
          <div class="input-box">
            <i class="ri-lock-password-line"></i>
            <input type="password" v-model="formData.password" placeholder="••••••••" required>
          </div>
        </div>

        <div class="form-group">
          <label>تأكيد كلمة المرور</label>
          <div class="input-box">
            <i class="ri-lock-password-line"></i>
            <input type="password" v-model="formData.password_confirmation" placeholder="••••••••" required>
          </div>
        </div>

        <div class="form-group">
          <label>المدينة</label>
          <div class="input-box">
            <i class="ri-map-pin-line"></i>
            <input type="text" v-model="formData.city" placeholder="طرابلس">
          </div>
        </div>

        <div class="form-group">
          <label>رقم الهاتف</label>
          <div class="input-box">
            <i class="ri-phone-line"></i>
            <input type="text" v-model="formData.phone" placeholder="091XXXXXXX">
          </div>
        </div>

        <div class="form-group full-width">
          <label>نبذة عن الشركة</label>
          <div class="input-box">
            <i class="ri-information-line"></i>
            <textarea v-model="formData.description" placeholder="تخصص الشركة وأهدافها..." rows="3"></textarea>
          </div>
        </div>

        <div class="form-group">
          <label>الموقع الإلكتروني</label>
          <div class="input-box">
            <i class="ri-global-line"></i>
            <input type="url" v-model="formData.website_url" placeholder="https://company.ly">
          </div>
        </div>

        <div class="form-group">
          <label>رابط الموقع على الخريطة</label>
          <div class="input-box">
            <i class="ri-map-2-line"></i>
            <input type="url" v-model="formData.map_url" placeholder="https://maps.google.com/...">
          </div>
        </div>

        <button type="submit" class="submit-btn" :disabled="loading">
          <span v-if="!loading">إرسال طلب الانضمام</span>
          <span v-else><i class="ri-loader-4-line rotate"></i> جاري المعالجة...</span>
        </button>
      </form>

      <div class="signup-footer">
        <span>لديك حساب بالفعل؟</span>
        <router-link to="/login">تسجيل الدخول</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { API_BASE_URL } from '../api'

const router = useRouter()

const formData = reactive({
  name: '', email: '', password: '', password_confirmation: '',
  city: '', phone: '', description: '', logo: null,
  website_url: '', map_url: ''
})
const logoPreview = ref(null)
const errors = reactive({})
const generalError = ref(null)
const loading = ref(false)
const success = ref(false)
const successMessage = ref('')

function handleLogoUpload(event) {
  const file = event.target.files[0]
  if (file) {
    formData.logo = file
    const reader = new FileReader()
    reader.onload = (e) => { logoPreview.value = e.target.result }
    reader.readAsDataURL(file)
  }
}

async function submit() {
  loading.value = true
  Object.keys(errors).forEach(key => delete errors[key])
  generalError.value = null

  const formPayload = new FormData()
  Object.keys(formData).forEach(key => {
    if (formData[key] !== null) {
      formPayload.append(key, formData[key])
    }
  })

  try {
    const response = await fetch(API_BASE_URL + '/company/register', {
      method: 'POST',
      body: formPayload
    })

    const data = await response.json()

    if (!response.ok) {
      if (response.status === 422) {
        Object.keys(data.errors).forEach(key => {
          errors[key] = data.errors[key][0]
        })
      } else {
        generalError.value = data.message || 'حدث خطأ ما'
      }
    } else {
      success.value = true
      successMessage.value = "تم التسجيل بنجاح! سيتم مراجعة شعار شركتك وبياناتك."
      setTimeout(() => { router.push('/login') }, 3000)
    }
  } catch (error) {
    generalError.value = 'تعذر الاتصال بالسيرفر'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
:root {
    --primary: #6A5AE0;
    --primary-soft: #f3ebff;
    --text-dark: #1e293b;
    --text-gray: #64748b;
    --bg-color: #f4f7ff;
}

* { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Cairo', sans-serif; }

.signup-wrapper {
    background-color: #f4f7ff;
    direction: rtl;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 40px 20px;
}

.signup-card {
    background: white;
    padding: 40px;
    border-radius: 30px;
    width: 100%;
    max-width: 750px;
    box-shadow: 0 20px 40px rgba(0,0,0,0.05);
}

.signup-header { text-align: center; margin-bottom: 30px; }
.logo { font-size: 24px; font-weight: 900; }
.logo span { color: #6A5AE0; }

.grid-form { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
.full-width { grid-column: span 2; }

.logo-upload-container { text-align: center; margin-bottom: 10px; }
.logo-preview {
    width: 100px; height: 100px; border: 2px dashed #cbd5e1;
    border-radius: 20px; margin: 0 auto 10px;
    display: flex; align-items: center; justify-content: center;
    cursor: pointer; overflow: hidden; background: #f8fafc; transition: 0.3s;
}
.logo-preview:hover { border-color: #6A5AE0; background: #f3ebff; }
.preview-img { width: 100%; height: 100%; object-fit: cover; }
.upload-placeholder { color: #64748b; font-size: 11px; display: flex; flex-direction: column; }
.upload-placeholder i { font-size: 25px; color: #6A5AE0; }
.hidden-input { display: none; }
.upload-hint { font-size: 10px; color: #64748b; }

.input-box { position: relative; }
.input-box i { position: absolute; right: 15px; top: 50%; transform: translateY(-50%); color: #6A5AE0; }
.input-box input, .input-box textarea {
    width: 100%; padding: 10px 40px 10px 15px;
    border-radius: 12px; border: 1px solid #e2e8f0; outline: none;
    font-family: 'Cairo', sans-serif;
}

.submit-btn {
    grid-column: span 2; background: #6A5AE0; color: white;
    padding: 12px; border: none; border-radius: 12px;
    font-weight: 700; cursor: pointer; transition: 0.3s;
    font-family: 'Cairo', sans-serif;
}
.submit-btn:hover { opacity: 0.9; transform: translateY(-2px); }

.rotate { animation: spin 1s linear infinite; display: inline-block; }
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

.error-message { color: #ef4444; font-size: 12px; margin-top: 4px; }
.success-message { color: #10b981; text-align: center; margin-bottom: 15px; font-weight: 700; }

.signup-footer { text-align: center; margin-top: 20px; font-size: 14px; }
.signup-footer a { color: #6A5AE0; text-decoration: none; font-weight: 900; margin-right: 5px; }

.fade-up { animation: fadeUp 0.8s forwards ease-out; }
@keyframes fadeUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }

@media (max-width: 600px) { .grid-form { grid-template-columns: 1fr; } .full-width, .submit-btn { grid-column: span 1; } }
</style>
