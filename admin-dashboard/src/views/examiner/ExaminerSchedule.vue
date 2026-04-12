<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'
import { useSpecializations } from '../../composables/useSpecializations'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const { specializations, loadSpecializations } = useSpecializations()
const schedules = ref([])
const loading = ref(true)
const specId = ref('')

async function load() {
  loading.value = true
  const params = {}
  if (specId.value) params.specialization_id = specId.value
  const { data } = await api.get('/discussion-schedules', { params }).catch(() => ({ data: { data: [] } }))
  schedules.value = data.data || []
  loading.value = false
}

function onFilter(e) {
  specId.value = e.target.value
  load()
}

onMounted(() => {
  loadSpecializations()
  load()
})
</script>

<template>
  <div>
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;flex-wrap:wrap;gap:12px;">
      <h1 class="page-title" style="margin:0;">جدول المناقشة</h1>
      <select class="form-input" style="max-width:200px;padding:10px 14px;border-radius:999px;" @change="onFilter">
        <option value="">كل التخصصات</option>
        <option v-for="s in specializations" :key="s.id" :value="s.id">{{ s.name }}</option>
      </select>
    </div>

    <SkeletonLoader v-if="loading" type="cards" :card-count="3" />
    <div v-else-if="!schedules.length" class="empty">لا يوجد جدول منشور حالياً</div>
    <div v-else class="grid-2">
      <div v-for="s in schedules" :key="s.id" class="card">
        <h3 style="margin-bottom:8px;font-size:16px;">{{ s.title || 'جدول المناقشة' }}</h3>
        <div style="display:flex;gap:10px;margin-bottom:12px;flex-wrap:wrap;">
          <span v-if="s.specialization" class="badge badge-purple">{{ s.specialization }}</span>
          <span v-if="s.academic_term" class="badge badge-active">{{ s.academic_term }}</span>
        </div>
        <p v-if="s.description" class="text-sm text-muted" style="margin-bottom:12px;">{{ s.description }}</p>
        <img v-if="s.image_url" :src="s.image_url" style="max-width:100%;border-radius:12px;">
        <div v-if="s.file_url" style="margin-top:10px;">
          <a :href="s.file_url" target="_blank" class="btn btn-sm btn-outline"><i class="ri-download-2-line"></i> تحميل الملف</a>
        </div>
      </div>
    </div>
  </div>
</template>
