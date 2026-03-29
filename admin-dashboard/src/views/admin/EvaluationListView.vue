<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'

const students = ref([])
const loading = ref(true)

onMounted(async () => {
  const { data } = await api.get('/evaluation-list').catch(() => ({ data: { data: [] } }))
  students.value = data.data || []
  loading.value = false
})
</script>

<template>
  <div>
    <h1 class="page-title">قائمة تقييم الشركات</h1>
    <div v-if="loading" class="loading">جاري التحميل...</div>
    <div v-else-if="!students.length" class="empty">لا يوجد طلاب</div>
    <div v-else class="grid-3">
      <div v-for="s in students" :key="s.id" class="card">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px;">
          <div class="avatar-circle">{{ (s.student_name||'').charAt(0) }}</div>
          <div><strong>{{ s.student_name }}</strong><br><small style="color:#999;">{{ s.student_number || '--' }}</small></div>
        </div>
        <p style="font-size:13px;color:#777;"><i class="ri-building-line"></i> {{ s.company_name || '--' }}</p>
        <span class="badge badge-purple" style="margin-top:8px;">{{ s.specialization || '--' }}</span>
      </div>
    </div>
  </div>
</template>
