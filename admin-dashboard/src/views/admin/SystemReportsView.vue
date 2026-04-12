<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'
import SkeletonLoader from '../../components/SkeletonLoader.vue'
import { useSpecializations } from '../../composables/useSpecializations'

const { specializations, loadSpecializations } = useSpecializations()

const reportType = ref('students')
const dept = ref('all')
const columns = ref([])
const rows = ref([])
const loading = ref(false)
const exporting = ref(false)

onMounted(loadSpecializations)

async function generate() {
  loading.value = true
  const { data } = await api.get('/system-reports', { params: { reportType: reportType.value, dept: dept.value } }).catch(() => ({ data: { columns: [], data: [] } }))
  columns.value = data.columns || []
  rows.value = data.data || []
  loading.value = false
}

async function exportPDF() {
  exporting.value = true
  const html2pdf = (await import('html2pdf.js')).default
  const element = document.getElementById('report-table')
  if (element) {
    await html2pdf().set({
      margin: 10,
      filename: `تقرير-${reportType.value}.pdf`,
      html2canvas: { scale: 2, useCORS: true },
      jsPDF: { unit: 'mm', format: 'a4', orientation: 'landscape' },
    }).from(element).save()
  }
  exporting.value = false
}
</script>

<template>
  <div>
    <h1 class="page-title">مركز تقارير النظام</h1>

    <div class="card mb-lg">
      <div style="display:flex;gap:14px;flex-wrap:wrap;align-items:end;">
        <div>
          <label class="text-sm font-bold text-muted" style="display:block;margin-bottom:4px;">نوع التقرير</label>
          <select v-model="reportType" class="form-input" style="max-width:200px;">
            <option value="students">قائمة الطلاب</option>
            <option value="companies">الشركات</option>
            <option value="examiners">الممتحنين</option>
          </select>
        </div>
        <div>
          <label class="text-sm font-bold text-muted" style="display:block;margin-bottom:4px;">التخصص</label>
          <select v-model="dept" class="form-input" style="max-width:200px;">
            <option value="all">كل التخصصات</option>
            <option v-for="s in specializations" :key="s.id" :value="s.name">{{ s.name }}</option>
          </select>
        </div>
        <button class="btn btn-primary" @click="generate" :disabled="loading">
          <i class="ri-refresh-line"></i> عرض البيانات
        </button>
        <button v-if="columns.length && rows.length" class="btn btn-success" @click="exportPDF" :disabled="exporting">
          <i class="ri-file-pdf-2-line"></i> {{ exporting ? 'جاري التصدير...' : 'تصدير PDF' }}
        </button>
      </div>
    </div>

    <SkeletonLoader v-if="loading" type="table" :columns="4" />
    <div v-else-if="columns.length" id="report-table" class="card" style="overflow-x:auto;">
      <table class="table">
        <thead><tr><th v-for="col in columns" :key="col">{{ col }}</th></tr></thead>
        <tbody>
          <tr v-if="!rows.length"><td :colspan="columns.length" class="empty">لا توجد بيانات</td></tr>
          <tr v-for="(row, i) in rows" :key="i"><td v-for="(val, j) in Object.values(row)" :key="j">{{ val }}</td></tr>
        </tbody>
      </table>
    </div>
    <div v-else class="card text-center" style="padding:60px;">
      <i class="ri-file-search-line" style="font-size:48px;color:var(--text-muted);display:block;margin-bottom:12px;"></i>
      <p class="text-muted">اختر الفلاتر واضغط "عرض البيانات"</p>
    </div>
  </div>
</template>
