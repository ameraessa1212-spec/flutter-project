<script setup>
import { ref } from 'vue'
import api from '../../composables/useApi'

const uploading = ref(false)
const result = ref(null)
const error = ref('')

async function handleFile(e) {
  const file = e.target.files[0]
  if (!file) return
  uploading.value = true; error.value = ''; result.value = null
  const fd = new FormData(); fd.append('file', file)
  try {
    const { data } = await api.post('/students/upload', fd)
    result.value = data
  } catch (e) { error.value = e.response?.data?.message || 'حدث خطأ' }
  uploading.value = false
}
</script>

<template>
  <div style="max-width:550px;margin:40px auto;text-align:center;">
    <h1 class="page-title">تحميل قائمة الطلاب</h1>
    <p style="color:#777;margin-bottom:25px;">ارفع ملف CSV أو Excel يحتوي على أرقام القيد وأسماء الطلاب</p>
    <label class="card" style="display:block;padding:50px;cursor:pointer;border:2px dashed #6A5AE0;background:#faf9ff;">
      <i class="ri-upload-cloud-2-line" style="font-size:48px;color:#6A5AE0;display:block;margin-bottom:10px;"></i>
      <p>{{ uploading ? 'جاري الرفع...' : 'اضغط لاختيار ملف' }}</p>
      <input type="file" accept=".csv,.xlsx,.xls" style="display:none" @change="handleFile" :disabled="uploading">
    </label>
    <div v-if="result" class="card" style="margin-top:20px;background:#f0fff4;border:1px solid #22c55e;">
      <p style="color:#22c55e;font-weight:700;">{{ result.message }}</p>
      <p>تم إنشاء: {{ result.data.created }} | تم تخطي: {{ result.data.skipped }}</p>
    </div>
    <p v-if="error" style="color:#ef4444;margin-top:15px;">{{ error }}</p>
  </div>
</template>
