<script setup>
import { ref } from 'vue'
import api from '../../composables/useApi'

const uploading = ref(false)
const result = ref(null)
const error = ref('')
const students = ref([])
const fileName = ref('')

function parseCsv(text) {
  const lines = text.split(/\r?\n/).filter(line => line.trim())
  // skip header row
  return lines.slice(1).map(line => {
    const cols = line.split(',')
    if (cols.length >= 2) {
      return { student_number: cols[0].trim(), name: cols[1].trim() }
    }
    return null
  }).filter(Boolean)
}

function handleFile(e) {
  const file = e.target.files[0]
  if (!file) return
  error.value = ''
  fileName.value = file.name
  const reader = new FileReader()
  reader.onload = (ev) => {
    const parsed = parseCsv(ev.target.result)
    if (!parsed.length) {
      error.value = 'الملف فارغ أو غير صالح'
      return
    }
    students.value = parsed
  }
  reader.readAsText(file)
}

async function sendStudents() {
  if (!students.value.length) return
  uploading.value = true; error.value = ''; result.value = null
  try {
    const { data } = await api.post('/students/upload', { students: students.value })
    result.value = data
  } catch (e) { error.value = e.response?.data?.message || 'حدث خطأ' }
  uploading.value = false
}
</script>

<template>
  <div style="max-width:600px;margin:40px auto;text-align:center;">
    <h1 class="page-title">تحميل قائمة الطلاب</h1>
    <p style="color:#777;margin-bottom:25px;">ارفع ملف CSV يحتوي على أرقام القيد وأسماء الطلاب</p>

    <label class="card" style="display:block;padding:50px;cursor:pointer;border:2px dashed #6A5AE0;background:#faf9ff;">
      <i class="ri-upload-cloud-2-line" style="font-size:48px;color:#6A5AE0;display:block;margin-bottom:10px;"></i>
      <p>{{ fileName || 'اضغط لاختيار ملف CSV' }}</p>
      <input type="file" accept=".csv" style="display:none" @change="handleFile" :disabled="uploading">
    </label>

    <div v-if="students.length" class="card" style="margin-top:20px;text-align:right;">
      <p style="font-weight:700;margin-bottom:10px;">تم قراءة {{ students.length }} طالب من الملف:</p>
      <div style="max-height:200px;overflow-y:auto;">
        <table style="width:100%;border-collapse:collapse;">
          <thead>
            <tr style="background:#f3f4f6;">
              <th style="padding:6px 10px;border-bottom:1px solid #e5e7eb;">رقم القيد</th>
              <th style="padding:6px 10px;border-bottom:1px solid #e5e7eb;">الاسم</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(s, i) in students" :key="i">
              <td style="padding:6px 10px;border-bottom:1px solid #f0f0f0;">{{ s.student_number }}</td>
              <td style="padding:6px 10px;border-bottom:1px solid #f0f0f0;">{{ s.name }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <button
        @click="sendStudents"
        :disabled="uploading"
        style="margin-top:15px;padding:10px 30px;background:#6A5AE0;color:#fff;border:none;border-radius:8px;cursor:pointer;font-size:16px;"
      >
        {{ uploading ? 'جاري الإرسال...' : 'إرسال البيانات' }}
      </button>
    </div>

    <div v-if="result" class="card" style="margin-top:20px;background:#f0fff4;border:1px solid #22c55e;">
      <p style="color:#22c55e;font-weight:700;">{{ result.message }}</p>
      <p>تم إنشاء: {{ result.data.created }} | تم تخطي: {{ result.data.skipped }}</p>
    </div>
    <p v-if="error" style="color:#ef4444;margin-top:15px;">{{ error }}</p>
  </div>
</template>
