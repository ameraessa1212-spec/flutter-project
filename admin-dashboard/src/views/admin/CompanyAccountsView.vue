<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'

const companies = ref([])
const loading = ref(true)
const search = ref('')

const filtered = computed(() => {
  if (!search.value) return companies.value
  return companies.value.filter(c => (c.name || '').toLowerCase().includes(search.value.toLowerCase()))
})

onMounted(async () => {
  const { data } = await api.get('/company-accounts').catch(() => ({ data: { data: [] } }))
  companies.value = data.data || []
  loading.value = false
})

async function toggle(c) {
  const { data } = await api.put(`/company-accounts/${c.id}/toggle-status`)
  c.is_active = data.data.is_active
}
</script>

<template>
  <div>
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
      <h1 class="page-title" style="margin:0;">إدارة حسابات الشركات</h1>
      <input v-model="search" class="search-input" placeholder="بحث عن شركة...">
    </div>
    <div v-if="loading" class="loading">جاري التحميل...</div>
    <table v-else class="table">
      <thead><tr><th>الشركة</th><th>البريد</th><th>تاريخ الانضمام</th><th>الحالة</th><th>الإجراء</th></tr></thead>
      <tbody>
        <tr v-for="c in filtered" :key="c.id">
          <td><strong>{{ c.name }}</strong></td>
          <td style="color:#6A5AE0;">{{ c.email || '--' }}</td>
          <td>{{ c.created_at || '--' }}</td>
          <td><span class="badge" :class="c.is_active ? 'badge-active' : 'badge-inactive'">{{ c.is_active ? 'نشط' : 'غير نشط' }}</span></td>
          <td><button class="btn btn-sm" :class="c.is_active ? 'btn-danger' : 'btn-success'" @click="toggle(c)">{{ c.is_active ? 'تعطيل' : 'تفعيل' }}</button></td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
