<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'

const students = ref([])
const loading = ref(true)
const search = ref('')
const specId = ref('')

async function load() {
  loading.value = true
  const params = {}
  if (search.value) params.search = search.value
  if (specId.value) params.specialization_id = specId.value
  const { data } = await api.get('/students', { params }).catch(() => ({ data: { data: [] } }))
  students.value = data.data || []
  loading.value = false
}

async function toggleStatus(id) {
  if (!confirm('هل أنت متأكد؟')) return
  await api.put(`/students/${id}/toggle-status`)
  load()
}

async function changePassword(id) {
  const pw = prompt('كلمة المرور الجديدة (8 أحرف على الأقل):')
  if (!pw || pw.length < 8) return
  await api.put(`/students/${id}/password`, { password: pw, password_confirmation: pw })
  alert('تم تغيير كلمة المرور')
}

function onSearch(val) { search.value = val; load() }
function onFilter(val) { specId.value = val; load() }

onMounted(load)
</script>

<template>
  <div>
    <PageHeader title="إدارة حسابات الطلاب" show-search show-spec-filter search-placeholder="بحث بالاسم أو رقم القيد..." @search="onSearch" @filter="onFilter" />
    <div v-if="loading" class="loading">جاري التحميل...</div>
    <div v-else-if="!students.length" class="empty">لا يوجد طلاب</div>
    <div v-else class="card" style="overflow-x:auto;">
      <table class="table">
        <thead><tr><th>الطالب</th><th>رقم القيد</th><th>التخصص</th><th>الحالة</th><th>الإجراءات</th></tr></thead>
        <tbody>
          <tr v-for="s in students" :key="s.id">
            <td><strong>{{ s.name }}</strong></td>
            <td>{{ s.student_number || '--' }}</td>
            <td><span class="badge badge-purple" v-if="s.specialization">{{ s.specialization }}</span><span v-else>--</span></td>
            <td><span class="badge badge-dot" :class="s.status === 'active' ? 'badge-active' : 'badge-inactive'">{{ s.status === 'active' ? 'نشط' : 'موقف' }}</span></td>
            <td><div style="display:flex;gap:6px;">
              <button class="btn btn-sm btn-outline" @click="changePassword(s.id)" title="تغيير كلمة المرور"><i class="ri-lock-line"></i></button>
              <button class="btn btn-sm" :class="s.status === 'active' ? 'btn-danger' : 'btn-success'" @click="toggleStatus(s.id)">{{ s.status === 'active' ? 'إيقاف' : 'تفعيل' }}</button>
            </div></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
