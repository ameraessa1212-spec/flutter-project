<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'

const results = ref([])
const loading = ref(true)
const search = ref('')

const filtered = computed(() => {
  if (!search.value) return results.value
  const t = search.value.toLowerCase()
  return results.value.filter(r => (r.student_name||'').toLowerCase().includes(t))
})

onMounted(async () => {
  const { data } = await api.get('/evaluation-results').catch(() => ({ data: { data: [] } }))
  results.value = data.data || []
  loading.value = false
})
</script>

<template>
  <div>
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
      <h1 class="page-title" style="margin:0;">استلام تقييمات الطلاب</h1>
      <input v-model="search" class="search-input" placeholder="ابحث بالاسم...">
    </div>
    <div v-if="loading" class="loading">جاري التحميل...</div>
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
