<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const reports = ref([])
const loading = ref(true)
const searchText = ref('')
const typeFilter = ref('')
const exporting = ref(false)

const reportTypeLabels = {
  initial: 'تقرير تمهيدي',
  midterm: 'تقرير منتصف',
  final: 'تقرير نهائي',
  weekly: 'تقرير أسبوعي',
  monthly: 'تقرير شهري',
}

const statusLabels = {
  draft: 'مسودة',
  submitted: 'مُقدَّم',
  approved: 'معتمد',
  revision_required: 'يحتاج تعديل',
  rejected: 'مرفوض',
}

const statusBadgeClass = {
  draft: 'badge-pending',
  submitted: 'badge-info',
  approved: 'badge-active',
  revision_required: 'badge-pending',
  rejected: 'badge-inactive',
}

const uniqueTypes = computed(() => {
  const set = new Set(reports.value.map(r => r.report_type).filter(Boolean))
  return Array.from(set)
})

const filtered = computed(() => {
  let list = reports.value
  if (typeFilter.value) list = list.filter(r => r.report_type === typeFilter.value)
  if (searchText.value) {
    const t = searchText.value.toLowerCase()
    list = list.filter(r =>
      (r.student_name || '').toLowerCase().includes(t) ||
      (r.title || '').toLowerCase().includes(t)
    )
  }
  return list
})

onMounted(async () => {
  const { data } = await api.get('/examiner/reports').catch(() => ({ data: { data: [] } }))
  reports.value = data.data || []
  loading.value = false
})

function openReport(report) {
  if (report.download_url) {
    window.open(report.download_url, '_blank')
  }
}

function formatSize(bytes) {
  if (!bytes) return ''
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`
}

async function exportPDF() {
  exporting.value = true
  const html2pdf = (await import('html2pdf.js')).default
  const element = document.getElementById('reports-table')
  if (element) {
    await html2pdf().set({
      margin: 10,
      filename: 'تقارير-الطلاب.pdf',
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
      <div>
        <h1 class="page-title" style="margin:0;">تقارير الطلاب</h1>
        <p class="page-subtitle" style="margin-top:4px;">مراجعة التقارير المرفوعة من الطلاب المحولين للمناقشة</p>
      </div>
      <div style="display:flex;gap:10px;align-items:center;flex-wrap:wrap;">
        <select v-model="typeFilter" class="form-select" style="max-width:180px;">
          <option value="">جميع الأنواع</option>
          <option v-for="t in uniqueTypes" :key="t" :value="t">{{ reportTypeLabels[t] || t }}</option>
        </select>
        <input v-model="searchText" class="search-input" placeholder="ابحث بالاسم أو العنوان...">
        <button v-if="filtered.length" class="btn btn-success btn-sm" @click="exportPDF" :disabled="exporting">
          <i class="ri-file-pdf-2-line"></i> {{ exporting ? 'جاري...' : 'تصدير PDF' }}
        </button>
      </div>
    </div>

    <SkeletonLoader v-if="loading" type="table" :columns="5" />
    <div v-else-if="!filtered.length" class="empty">
      <i class="ri-file-text-line" style="font-size:48px;color:var(--border);display:block;margin-bottom:12px;"></i>
      لا توجد تقارير بعد
    </div>
    <div v-else id="reports-table" class="card" style="overflow-x:auto;">
      <table class="table">
        <thead>
          <tr>
            <th>الطالب</th>
            <th>رقم القيد</th>
            <th>عنوان التقرير</th>
            <th>نوع التقرير</th>
            <th>الحالة</th>
            <th>تاريخ الرفع</th>
            <th>إجراء</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in filtered" :key="r.id">
            <td><strong>{{ r.student_name || '--' }}</strong></td>
            <td>{{ r.student_number || '--' }}</td>
            <td>
              <div>{{ r.title || r.file_name || '--' }}</div>
              <small v-if="r.file_size" class="text-muted">{{ formatSize(r.file_size) }}</small>
            </td>
            <td>
              <span class="badge badge-purple">{{ reportTypeLabels[r.report_type] || r.report_type || '--' }}</span>
            </td>
            <td>
              <span class="badge" :class="statusBadgeClass[r.status] || 'badge-pending'">
                {{ statusLabels[r.status] || r.status || '--' }}
              </span>
            </td>
            <td>{{ r.submitted_at || '--' }}</td>
            <td>
              <button
                class="btn btn-sm btn-primary"
                :disabled="!r.download_url"
                @click="openReport(r)"
              >
                <i class="ri-download-2-line"></i> تحميل
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
