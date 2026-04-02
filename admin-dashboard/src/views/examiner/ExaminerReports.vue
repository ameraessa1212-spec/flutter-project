<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'
import { useAuth } from '../../composables/useApi'

const { user } = useAuth()
const reports = ref([])
const loading = ref(true)

onMounted(async () => {
  const { data } = await api.get(`/examiners/${user.value?.id}/reports`).catch(() => ({ data: { data: [] } }))
  reports.value = data.data || []
  loading.value = false
})
</script>

<template>
  <div>
    <h1 class="page-title">تقارير الطلاب</h1>
    <div v-if="loading" class="loading">جاري التحميل...</div>
    <div v-else-if="!reports.length" class="empty">لا توجد تقارير</div>
    <div v-else class="grid-3">
      <div v-for="r in reports" :key="r.id" class="card">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px;">
          <div class="avatar-circle">{{ (r.student_name||'?').charAt(0) }}</div>
          <div><strong>{{ r.student_name }}</strong><br><small style="color:#999;">{{ r.student_number || '--' }}</small></div>
        </div>
        <p style="font-size:14px;">{{ r.title || 'تقرير' }}</p>
        <small style="color:#999;">استلم: {{ r.submitted_at || '--' }}</small>
        <a v-if="r.download_url" :href="r.download_url" target="_blank" class="btn btn-sm btn-outline" style="display:block;text-align:center;margin-top:10px;"><i class="ri-download-2-line"></i> تحميل</a>
      </div>
    </div>
  </div>
</template>
