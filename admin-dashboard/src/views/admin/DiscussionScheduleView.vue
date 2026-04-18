<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'

const file = ref(null)
const preview = ref('')
const targets = ref([])
const message = ref('')
const title = ref('')
const specializationId = ref('')
const specializations = ref([])
const sending = ref(false)
const result = ref('')

onMounted(async () => {
  try {
    const { data } = await api.get('/specializations')
    specializations.value = data.data || []
  } catch (_) {}
})

function onFileChange(e) {
  file.value = e.target.files[0]
  if (file.value) {
    const reader = new FileReader()
    reader.onload = () => preview.value = reader.result
    reader.readAsDataURL(file.value)
  }
}

function toggleTarget(t) {
  const idx = targets.value.indexOf(t)
  if (idx >= 0) targets.value.splice(idx, 1)
  else targets.value.push(t)
}

async function send() {
  if (!file.value) { alert('ارفع صورة الجدول أولاً'); return }
  if (!targets.value.length) { alert('حدد المستلمين'); return }

  sending.value = true
  result.value = ''

  const fd = new FormData()
  fd.append('image', file.value)
  targets.value.forEach(t => fd.append('targets[]', t))
  if (title.value) fd.append('title', title.value)
  if (message.value) fd.append('message', message.value)
  if (specializationId.value) fd.append('specialization_id', specializationId.value)

  try {
    await api.post('/discussion-schedules', fd)
    result.value = 'تم الإرسال بنجاح'
  } catch (e) {
    result.value = 'حدث خطأ أثناء الإرسال'
  } finally {
    sending.value = false
  }
}
</script>

<template>
  <div style="max-width:600px;margin:0 auto; padding: 20px;">
    <h1 class="page-title" style="text-align: center; margin-bottom: 25px;">إرسال جدول المناقشة</h1>

    <label class="upload-card" style="display:block;padding:40px;cursor:pointer;border:2px dashed #6A5AE0;text-align:center;margin-bottom:20px;border-radius:15px;background:#f8faff;">
      <img v-if="preview" :src="preview" style="max-width:100%;border-radius:10px;margin-bottom:10px;box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
      <template v-else>
        <i class="ri-upload-cloud-2-line" style="font-size:48px;color:#6A5AE0;display:block;"></i>
        <p style="color:#6A5AE0; font-weight:600;">اضغط لرفع صورة الجدول</p>
      </template>
      <input type="file" accept="image/*" style="display:none" @change="onFileChange">
    </label>

    <input v-model="title" class="form-input" placeholder="عنوان الجدول (اختياري)" style="width:100%; padding:12px; border-radius:10px; border:1px solid #ddd; margin-bottom:15px;">

    <select v-model="specializationId" style="width:100%; padding:12px; border-radius:10px; border:1px solid #ddd; margin-bottom:15px; font-family:inherit; color:#333; background:white;">
      <option value="">كل التخصصات</option>
      <option v-for="s in specializations" :key="s.id" :value="s.id">{{ s.name }}</option>
    </select>

    <div style="display:flex;gap:10px;margin-bottom:15px;">
      <button class="btn" :class="targets.includes('examiners') ? 'btn-primary' : 'btn-outline'" @click="toggleTarget('examiners')" style="flex:1; padding: 12px; border-radius: 10px; font-weight: 600;">
        الممتحنين
      </button>
      <button class="btn" :class="targets.includes('students') ? 'btn-primary' : 'btn-outline'" @click="toggleTarget('students')" style="flex:1; padding: 12px; border-radius: 10px; font-weight: 600;">
        الطلاب
      </button>
    </div>

    <textarea v-model="message" class="form-input" placeholder="رسالة مرفقة (اختياري)..." style="min-height:100px;resize:vertical;margin-bottom:15px;width:100%; padding:12px; border-radius:10px; border:1px solid #ddd;"></textarea>

    <button class="btn btn-primary" style="width:100%;padding:14px; border-radius:12px; font-size:16px; font-weight:bold;" @click="send" :disabled="sending">
      {{ sending ? 'جاري الإرسال...' : 'إرسال الجدول' }}
    </button>

    <div v-if="result === 'تم الإرسال بنجاح'" style="text-align:center; margin-top:20px; padding:12px; background:#e8fdf4; border-radius:8px;">
      <p style="color:#22c55e; font-weight:700; margin:0;">
        <i class="ri-checkbox-circle-line"></i> {{ result }}
      </p>
    </div>

    <p v-else-if="result" style="text-align:center; margin-top:15px; color:#ef4444; font-weight:600;">{{ result }}</p>
  </div>
</template>

<style scoped>
/* تأكد من وجود هذه التنسيقات في ملف الـ CSS الخاص بك أو أضفها هنا */
.btn-primary {
  background-color: #6A5AE0;
  color: white;
  border: none;
}
.btn-outline {
  background-color: white;
  color: #6A5AE0;
  border: 2px solid #6A5AE0;
}
.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>