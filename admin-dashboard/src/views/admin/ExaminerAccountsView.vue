<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'

const examiners = ref([])
const loading = ref(true)
const search = ref('')

const filtered = computed(() => {
  if (!search.value) return examiners.value
  const t = search.value.toLowerCase()
  return examiners.value.filter(e => (e.name||'').toLowerCase().includes(t) || (e.email||'').toLowerCase().includes(t))
})

onMounted(async () => {
  const { data } = await api.get('/examiners').catch(() => ({ data: { data: [] } }))
  examiners.value = data.data || []
  loading.value = false
})

async function toggle(ex) {
  if (ex.status === 'active' && !confirm(`تعطيل حساب ${ex.name}؟`)) return
  await api.put(`/examiners/${ex.id}/toggle-status`)
  ex.status = ex.status === 'active' ? 'inactive' : 'active'
}
</script>

<template>
  <div>
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
      <h1 class="page-title" style="margin:0;">إدارة حسابات الممتحنين</h1>
      <input v-model="search" class="search-input" placeholder="ابحث عن ممتحن...">
    </div>
    <div v-if="loading" class="loading">جاري التحميل...</div>
    <table v-else class="table">
      <thead><tr><th>الممتحن</th><th>البريد</th><th>الهاتف</th><th>الحالة</th><th>الإجراء</th></tr></thead>
      <tbody>
        <tr v-for="ex in filtered" :key="ex.id">
          <td><strong>{{ ex.name }}</strong></td>
          <td>{{ ex.email || '--' }}</td>
          <td>{{ ex.phone || '--' }}</td>
          <td><span class="badge" :class="ex.status==='active' ? 'badge-active' : 'badge-inactive'">{{ ex.status==='active' ? 'نشط' : 'معطل' }}</span></td>
          <td><button class="btn btn-sm" :class="ex.status==='active' ? 'btn-danger' : 'btn-success'" @click="toggle(ex)">{{ ex.status==='active' ? 'تعطيل' : 'تفعيل' }}</button></td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
