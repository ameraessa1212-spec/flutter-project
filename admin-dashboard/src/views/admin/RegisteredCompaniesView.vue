<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'

const companies = ref([])
const loading = ref(true)
const search = ref('')
const colors = ['linear-gradient(135deg,#6C5CE7,#A29BFE)','linear-gradient(135deg,#00B894,#55EFC4)','linear-gradient(135deg,#E17055,#FAB1A0)','linear-gradient(135deg,#0984E3,#74B9FF)','linear-gradient(135deg,#FDCB6E,#F39C12)']

const filtered = computed(() => {
  if (!search.value) return companies.value
  const t = search.value.toLowerCase()
  return companies.value.filter(c => (c.name || '').toLowerCase().includes(t))
})

async function load(specialization) {
  loading.value = true
  const params = {}
  if (specialization) params.specialization = specialization
  const { data } = await api.get('/registered-companies', { params }).catch(() => ({ data: { data: [] } }))
  companies.value = data.data || []
  loading.value = false
}

function onSearch(val) { search.value = val }
function onFilter(val) { load(val ? null : undefined) }

onMounted(() => load())
</script>

<template>
  <div>
    <PageHeader title="الشركات الشريكة" show-search show-spec-filter search-placeholder="بحث عن شركة..." @search="onSearch" @filter="onFilter" />

    <div v-if="!loading" class="mb-md">
      <span class="badge badge-purple"><i class="ri-building-line"></i> {{ filtered.length }} شركة</span>
    </div>

    <div v-if="loading" class="loading">جاري التحميل...</div>
    <div v-else-if="!filtered.length" class="empty">لا توجد شركات</div>
    <div v-else class="grid-3">
      <div v-for="(c, i) in filtered" :key="c.id" class="card" style="text-align:center;">
        <div class="avatar-circle" :style="{ background: colors[i % colors.length], width: '56px', height: '56px', fontSize: '22px', margin: '0 auto 14px' }">{{ (c.name||'').charAt(0) }}</div>
        <strong style="font-size:16px;">{{ c.name }}</strong>
        <p class="text-sm text-muted" style="margin:8px 0;"><i class="ri-map-pin-2-fill"></i> {{ c.city || '--' }}</p>
        <div class="badge badge-active" style="margin-top:4px;"><i class="ri-group-line"></i> {{ c.internships_count }} متدرب</div>
      </div>
    </div>
  </div>
</template>
