<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'

const reports = ref([])
const loading = ref(true)

onMounted(async () => {
  const { data } = await api.get('/student-reports').catch(() => ({ data: { data: [] } }))
  reports.value = data.data || []
  loading.value = false
})

async function notify(r) {
  r._notifying = true
  await api.post(`/student-reports/${r.id}/notify`).catch(() => null)
  r._notified = true; r._notifying = false
}
</script>

<template>
  <div>
    <h1 class="page-title">تقارير الطلاب</h1>
    <div v-if="loading" class="loading">جاري التحميل...</div>
    <div v-else-if="!reports.length" class="empty">لا توجد تقارير</div>
    <div v-else class="grid-3">
      <div v-for="r in reports" :key="r.id" class="card">
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:12px;">
          <div class="avatar-circle">{{ (r.student?.name || '?').charAt(0) }}</div>
          <div><strong>{{ r.student?.name }}</strong><br><small style="color:#999;">{{ r.student?.student_number || '--' }}</small></div>
        </div>
        <p style="font-size:14px;margin-bottom:4px;">{{ r.title || r.report_type || 'تقرير' }}</p>
        <small style="color:#999;">{{ r.submitted_at ? new Date(r.submitted_at).toLocaleDateString('ar-LY') : '--' }}</small>
        <div style="display:flex;gap:8px;margin-top:12px;">
          <a v-if="r.download_url" :href="r.download_url" target="_blank" class="btn btn-sm btn-outline"><i class="ri-download-2-line"></i> تحميل</a>
          <button class="btn btn-sm btn-primary" :disabled="r._notified || r._notifying" @click="notify(r)">
            {{ r._notified ? 'تم الإبلاغ' : r._notifying ? 'جاري...' : 'إبلاغ الطالب' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
