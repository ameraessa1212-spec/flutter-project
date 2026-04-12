<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const students = ref([])
const loading = ref(true)
const searchText = ref('')
const exporting = ref(false)

const filtered = computed(() => {
  if (!searchText.value) return students.value
  const t = searchText.value.toLowerCase()
  return students.value.filter(s => (s.student_name || '').toLowerCase().includes(t))
})

onMounted(async () => {
  const { data } = await api.get('/examiner/students').catch(() => ({ data: { data: [] } }))
  students.value = data.data || []
  loading.value = false
})

async function exportPDF() {
  exporting.value = true
  const html2pdf = (await import('html2pdf.js')).default
  const element = document.getElementById('students-table')
  if (element) {
    await html2pdf().set({
      margin: 10,
      filename: 'قائمة-الطلاب.pdf',
      html2canvas: { scale: 2, useCORS: true },
      jsPDF: { unit: 'mm', format: 'a4', orientation: 'landscape' },
    }).from(element).save()
  }
  exporting.value = false
}
</script>

<template>
  <div>
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;flex-wrap:wrap;gap:12px;">
      <h1 class="page-title" style="margin:0;">قائمة الطلاب</h1>
      <div style="display:flex;gap:10px;align-items:center;">
        <input v-model="searchText" class="search-input" placeholder="ابحث باسم الطالب...">
        <button v-if="filtered.length" class="btn btn-success btn-sm" @click="exportPDF" :disabled="exporting">
          <i class="ri-file-pdf-2-line"></i> {{ exporting ? 'جاري...' : 'تصدير PDF' }}
        </button>
      </div>
    </div>

    <SkeletonLoader v-if="loading" type="table" :columns="4" />
    <div v-else-if="!filtered.length" class="empty">لا يوجد طلاب</div>
    <div v-else id="students-table" class="card" style="overflow-x:auto;">
      <table class="table">
        <thead>
          <tr>
            <th>الطالب</th>
            <th>رقم القيد</th>
            <th>حالة التقييم</th>
            <th>الدرجة</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="s in filtered" :key="s.id">
            <td><strong>{{ s.student_name }}</strong></td>
            <td>{{ s.student_number || '--' }}</td>
            <td>
              <span class="badge" :class="s.has_evaluation ? 'badge-active' : 'badge-pending'">
                {{ s.has_evaluation ? 'تم التقييم' : 'لم يتم التقييم' }}
              </span>
            </td>
            <td>
              <strong v-if="s.total_score != null" style="color:var(--primary);">{{ s.total_score }}/70</strong>
              <span v-else class="text-muted">--</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
