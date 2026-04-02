<template>
  <div class="post-opportunity">
    <div class="form-container animate-fade">
      <h2><i class="ri-add-circle-line" style="color: #6A5AE0; vertical-align: middle;"></i> إضافة فرصة تدريب جديدة</h2>

      <div class="success-msg" v-if="showSuccess">تم إضافة الفرصة بنجاح!</div>
      <div class="error-msg" v-if="showError">{{ errorText }}</div>

      <form @submit.prevent="submit">
        <div class="form-group">
          <label>عنوان الفرصة *</label>
          <input type="text" v-model="form.title" required placeholder="مثال: مطور واجهات خلفية (Laravel)">
        </div>

        <div class="form-group">
          <label>الوصف *</label>
          <textarea v-model="form.description" required placeholder="اكتب وصفاً شاملاً عن التدريب..."></textarea>
        </div>

        <div class="flex-row">
          <div class="form-group">
            <label>التخصص المستهدف</label>
            <select v-model="form.specialization_id">
              <option value="">-- كل التخصصات --</option>
              <option v-for="spec in specializations" :key="spec.id" :value="spec.id">{{ spec.name }}</option>
            </select>
          </div>
          <div class="form-group">
            <label>عدد الطلاب المطلوب</label>
            <input type="number" v-model="form.seats_count" min="1" placeholder="مثال: 5">
          </div>
        </div>

        <div class="flex-row">
          <div class="form-group">
            <label>المدينة *</label>
            <input type="text" v-model="form.city" required placeholder="مثال: طرابلس">
          </div>
          <div class="form-group">
            <label>تفاصيل الموقع</label>
            <input type="text" v-model="form.location_text" placeholder="مثال: شارع الجمهورية، بجانب...">
          </div>
        </div>

        <div class="flex-row">
          <div class="form-group">
            <label>مدة التدريب (بالأيام)</label>
            <input type="number" v-model="form.duration_days" min="1" placeholder="مثال: 90">
          </div>
          <div class="form-group">
            <label>حالة النشر</label>
            <select v-model="form.status">
              <option value="draft">مسودة</option>
              <option value="published">نشر (مرئي للطلاب)</option>
            </select>
          </div>
        </div>

        <div class="flex-row">
          <div class="form-group">
            <label>تاريخ البدء</label>
            <input type="date" v-model="form.start_date">
          </div>
          <div class="form-group">
            <label>تاريخ الانتهاء</label>
            <input type="date" v-model="form.end_date">
          </div>
          <div class="form-group">
            <label>آخر موعد للتقديم</label>
            <input type="date" v-model="form.application_deadline">
          </div>
        </div>

        <button type="submit" class="submit-btn" :disabled="loading">
          <span v-if="!loading"><i class="ri-save-line"></i> حفظ ونشر</span>
          <span v-else>جاري الحفظ...</span>
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { apiFetch } from '../../api'

const loading = ref(false)
const specializations = ref([])
const errorText = ref('')
const showSuccess = ref(false)
const showError = ref(false)

const form = reactive({
  title: '',
  description: '',
  specialization_id: '',
  city: '',
  location_text: '',
  seats_count: '',
  duration_days: '',
  start_date: '',
  end_date: '',
  application_deadline: '',
  status: 'published'
})

onMounted(async () => {
  try {
    const response = await apiFetch('/company/specializations')
    if (response.ok) {
      const data = await response.json()
      specializations.value = data.data || []
    }
  } catch (e) {
    console.error('Failed to load specializations', e)
  }
})

async function submit() {
  loading.value = true
  showSuccess.value = false
  showError.value = false

  try {
    const payload = { ...form }
    if (payload.seats_count) payload.seats_count = parseInt(payload.seats_count)
    if (payload.duration_days) payload.duration_days = parseInt(payload.duration_days)
    if (payload.specialization_id) payload.specialization_id = parseInt(payload.specialization_id)
    if (!payload.specialization_id) delete payload.specialization_id
    if (!payload.seats_count) delete payload.seats_count
    if (!payload.duration_days) delete payload.duration_days
    if (!payload.location_text) delete payload.location_text
    if (!payload.start_date) delete payload.start_date
    if (!payload.end_date) delete payload.end_date
    if (!payload.application_deadline) delete payload.application_deadline

    const response = await apiFetch('/company/opportunities', {
      method: 'POST',
      body: JSON.stringify(payload)
    })

    const data = await response.json()

    if (response.ok) {
      showSuccess.value = true
      form.title = ''
      form.description = ''
      form.specialization_id = ''
      form.city = ''
      form.location_text = ''
      form.seats_count = ''
      form.duration_days = ''
      form.start_date = ''
      form.end_date = ''
      form.application_deadline = ''
    } else {
      errorText.value = data.message || 'تعذر إضافة الفرصة. تحقق من البيانات المدخلة.'
      showError.value = true
    }
  } catch (error) {
    errorText.value = 'حدث خطأ في الاتصال بالخادم.'
    showError.value = true
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.post-opportunity {
    padding: 20px;
    font-family: 'Cairo', sans-serif;
    direction: rtl;
}

.form-container {
    background: #fff; padding: 30px; border-radius: 20px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.02); max-width: 800px; margin: 0 auto;
}

h2 { margin-top: 0; color: #1e293b; margin-bottom: 25px; }

.form-group { margin-bottom: 20px; }
label { display: block; margin-bottom: 8px; font-weight: 600; color: #1e293b; }
input[type="text"], input[type="number"], input[type="date"], select, textarea {
    width: 100%; padding: 12px; border: 1px solid #e2e8f0; border-radius: 10px;
    font-family: 'Cairo'; box-sizing: border-box; outline: none;
}
textarea { resize: vertical; min-height: 100px; }

.submit-btn {
    background: #6A5AE0; color: white; border: none; padding: 12px 25px;
    border-radius: 10px; font-weight: bold; cursor: pointer;
    display: inline-flex; align-items: center; gap: 8px; font-family: 'Cairo';
}
.submit-btn:hover { background: #5b4dd0; }

.flex-row { display: flex; gap: 20px; }
.flex-row > .form-group { flex: 1; }

.success-msg {
    background: #dcfce7; color: #166534; padding: 12px 16px;
    border-radius: 10px; margin-bottom: 20px;
}
.error-msg {
    background: #fee2e2; color: #991b1b; padding: 12px 16px;
    border-radius: 10px; margin-bottom: 20px;
}

.animate-fade {
    animation: fadeInUp 0.6s ease forwards;
}
@keyframes fadeInUp {
    from { transform: translateY(20px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}
</style>
