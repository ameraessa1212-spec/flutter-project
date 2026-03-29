<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'

const items = ref([])
const loading = ref(true)
const search = ref('')
const specId = ref('')

const filtered = computed(() => {
  let list = items.value
  if (search.value) {
    const t = search.value.toLowerCase()
    list = list.filter(i => i.student.name.toLowerCase().includes(t) || i.company.name.toLowerCase().includes(t))
  }
  return list
})

async function load() {
  loading.value = true
  const params = {}
  if (specId.value) params.specialization_id = specId.value
  const { data } = await api.get('/student-evaluations', { params }).catch(() => ({ data: { data: [] } }))
  items.value = data.data || []
  loading.value = false
}

function onSearch(val) { search.value = val }
function onFilter(val) { specId.value = val; load() }

onMounted(load)
</script>

<template>
  <div>
    <PageHeader title="لوحة النتائج النهائية" show-search show-spec-filter search-placeholder="ابحث باسم الطالب أو الشركة..." @search="onSearch" @filter="onFilter" />
    <div v-if="loading" class="loading">جاري التحميل...</div>
    <div v-else-if="!filtered.length" class="empty">لا توجد نتائج</div>
    <div v-else class="grid-3">
      <div v-for="item in filtered" :key="item.id" class="card">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px;">
          <div class="avatar-circle">{{ item.student.name.charAt(0) }}</div>
          <div>
            <strong>{{ item.student.name }}</strong><br>
            <small class="text-muted">{{ item.student.student_number || '--' }}</small>
          </div>
        </div>
        <p class="text-sm text-muted mb-sm"><i class="ri-building-line"></i> {{ item.company.name }}</p>
        <div class="mb-sm">
          <div class="flex-between text-sm"><span>الشركة (30%)</span><strong>{{ item.company_weighted }}</strong></div>
          <div class="progress" style="margin-top:4px;"><div class="progress-fill orange" :style="{ width: Math.min(item.company_score/30*100, 100)+'%' }"></div></div>
        </div>
        <div class="mb-sm">
          <div class="flex-between text-sm"><span>الممتحن (70%)</span><strong>{{ item.examiner_weighted }}</strong></div>
          <div class="progress" style="margin-top:4px;"><div class="progress-fill green" :style="{ width: Math.min(item.examiner_score/70*100, 100)+'%' }"></div></div>
        </div>
        <div style="text-align:center;padding:12px;background:var(--bg-body);border-radius:var(--radius-md);margin-top:8px;">
          <small class="text-muted">المعدل النهائي</small><br>
          <strong style="font-size:28px;color:var(--primary);">{{ item.final_percentage }}%</strong>
        </div>
      </div>
    </div>
  </div>
</template>
