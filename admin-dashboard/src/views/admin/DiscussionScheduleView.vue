<script setup>
import { ref } from 'vue'
import api from '../../composables/useApi'

const file = ref(null)
const preview = ref('')
const targets = ref([])
const message = ref('')
const sending = ref(false)
const result = ref('')

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
  sending.value = true; result.value = ''
  const fd = new FormData()
  fd.append('image', file.value)
  targets.value.forEach(t => fd.append('targets[]', t))
  if (message.value) fd.append('message', message.value)
  try {
    const { data } = await api.post('/discussion-schedules', fd)
    result.value = data.message || 'تم الإرسال بنجاح'
  } catch (e) { result.value = 'حدث خطأ' }
  sending.value = false
}
</script>

<template>
  <div style="max-width:600px;margin:0 auto;">
    <h1 class="page-title">إرسال جدول المناقشة</h1>

    <label class="card" style="display:block;padding:40px;cursor:pointer;border:2px dashed #6A5AE0;text-align:center;margin-bottom:20px;">
      <img v-if="preview" :src="preview" style="max-width:100%;border-radius:10px;margin-bottom:10px;">
      <template v-else><i class="ri-upload-cloud-2-line" style="font-size:48px;color:#6A5AE0;display:block;"></i><p>اضغط لرفع صورة الجدول</p></template>
      <input type="file" accept="image/*" style="display:none" @change="onFileChange">
    </label>

    <div style="display:flex;gap:10px;margin-bottom:15px;">
      <button class="btn" :class="targets.includes('examiners') ? 'btn-primary' : 'btn-outline'" @click="toggleTarget('examiners')" style="flex:1;">الممتحنين</button>
      <button class="btn" :class="targets.includes('students') ? 'btn-primary' : 'btn-outline'" @click="toggleTarget('students')" style="flex:1;">الطلاب</button>
    </div>

    <textarea v-model="message" class="form-input" placeholder="رسالة مرفقة (اختياري)..." style="min-height:80px;resize:vertical;margin-bottom:15px;width:100%;"></textarea>

    <button class="btn btn-primary" style="width:100%;padding:14px;" @click="send" :disabled="sending">
      {{ sending ? 'جاري الإرسال...' : 'إرسال الجدول' }}
    </button>

    <p v-if="result" style="text-align:center;margin-top:15px;color:#22c55e;font-weight:700;">{{ result }}</p>
  </div>
</template>
