<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const results = ref([])
const loading = ref(true)
const search = ref('')
const specId = ref('')

const filtered = computed(() => {
  if (!search.value) return results.value
  const t = search.value.toLowerCase()
  return results.value.filter(r => (r.student_name||'').toLowerCase().includes(t))
})

async function load() {
  loading.value = true
  const params = {}
  if (specId.value) params.specialization_id = specId.value
  const { data } = await api.get('/evaluation-results', { params }).catch(() => ({ data: { data: [] } }))
  results.value = data.data || []
  loading.value = false
}

function onSearch(val) { search.value = val }
function onFilter(val) { specId.value = val; load() }

onMounted(load)
</script>

<template>
  <div>
    <PageHeader title="استلام تقييمات الطلاب" show-search show-spec-filter search-placeholder="ابحث بالاسم..." @search="onSearch" @filter="onFilter" />
    <SkeletonLoader v-if="loading" type="cards" :card-count="6" />
    <div v-else-if="!filtered.length" class="empty">لا توجد نتائج</div>
    <div v-else class="grid-3">
      <div v-for="ev in filtered" :key="ev.id" class="card" style="text-align:center;">
        <div class="avatar-circle" style="margin:0 auto 10px;width:50px;height:50px;font-size:20px;">{{ (ev.student_name||'').charAt(0) }}</div>
        <strong>{{ ev.student_name }}</strong>
        <p style="font-size:13px;color:#999;">{{ ev.student_number || '--' }}</p>
        <span class="badge badge-purple">{{ ev.specialization || '--' }}</span>
        <div style="margin-top:12px;padding:10px;background:#f8f9fd;border-radius:10px;">
          <span style="font-size:24px;font-weight:800;color:#6A5AE0;">{{ ev.total_score }}/70</span>
        </div>
      </div>
    </div>
  </div>
</template>
