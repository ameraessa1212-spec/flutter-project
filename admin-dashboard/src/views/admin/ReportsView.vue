<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const reports = ref([])
const loading = ref(true)
const search = ref('')
const status = ref('')

async function load() {
  loading.value = true
  const params = {}
  if (search.value) params.search = search.value
  if (status.value) params.status = status.value
  const { data } = await api.get('/student-reports', { params }).catch(() => ({ data: { data: [] } }))
  reports.value = data.data || []
  loading.value = false
}

function onSearch(val) { search.value = val; load() }
function onStatus(val) { status.value = val; load() }

async function notify(r) {
  r._notifying = true
  await api.post(`/student-reports/${r.id}/notify`).catch(() => null)
  r._notified = true; r._notifying = false
}

onMounted(load)
</script>

<template>
  <div>
    <PageHeader title="تقارير الطلاب" show-search show-status-filter search-placeholder="ابحث باسم الطالب..." :status-options="[{value:'submitted',label:'مرسل'},{value:'reviewed',label:'مراجع'}]" @search="onSearch" @status-filter="onStatus" />
    <SkeletonLoader v-if="loading" type="cards" :card-count="6" />
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
