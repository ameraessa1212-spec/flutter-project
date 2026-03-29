<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'

const items = ref([])
const loading = ref(true)
const statusFilter = ref('')

async function load() {
  loading.value = true
  const params = {}
  if (statusFilter.value) params.status = statusFilter.value
  const { data } = await api.get('/student-requests', { params }).catch(() => ({ data: { data: [] } }))
  items.value = data.data || []
  loading.value = false
}

async function updateStatus(id, status) {
  if (!confirm(status === 'approved' ? 'قبول الطلب؟' : 'رفض الطلب؟')) return
  await api.put(`/student-requests/${id}/status`, { status })
  load()
}

onMounted(load)
</script>

<template>
  <div>
    <PageHeader title="بيانات الطلاب والطلبات" show-spec-filter @filter="load" />

    <div style="display:flex;gap:8px;margin-bottom:20px;">
      <button class="btn btn-sm" :class="statusFilter === '' ? 'btn-primary' : 'btn-outline'" @click="statusFilter = ''; load()">الكل</button>
      <button class="btn btn-sm" :class="statusFilter === 'pending' ? 'btn-primary' : 'btn-outline'" @click="statusFilter = 'pending'; load()">معلقة</button>
      <button class="btn btn-sm" :class="statusFilter === 'approved' ? 'btn-primary' : 'btn-outline'" @click="statusFilter = 'approved'; load()">مقبولة</button>
      <button class="btn btn-sm" :class="statusFilter === 'rejected' ? 'btn-primary' : 'btn-outline'" @click="statusFilter = 'rejected'; load()">مرفوضة</button>
    </div>

    <div v-if="loading" class="loading">جاري التحميل...</div>
    <div v-else-if="!items.length" class="empty">لا توجد طلبات</div>
    <div v-else class="card" style="overflow-x:auto;">
      <table class="table">
        <thead><tr><th>الطالب</th><th>الشركة</th><th>التخصص</th><th>الحالة</th><th>الإجراء</th></tr></thead>
        <tbody>
          <tr v-for="a in items" :key="a.id">
            <td><strong>{{ a.student?.name }}</strong><br><small class="text-muted">{{ a.student?.student_number }}</small></td>
            <td>{{ a.company?.name || '--' }}</td>
            <td><span class="badge badge-purple" v-if="a.student?.specialization">{{ a.student.specialization }}</span><span v-else>--</span></td>
            <td>
              <span class="badge badge-dot" :class="{ 'badge-active': a.status==='approved', 'badge-inactive': a.status==='rejected', 'badge-pending': a.status==='pending' }">
                {{ a.status === 'pending' ? 'معلق' : a.status === 'approved' ? 'مقبول' : 'مرفوض' }}
              </span>
            </td>
            <td><div style="display:flex;gap:6px;">
              <button v-if="a.status==='pending'" class="btn btn-sm btn-success" @click="updateStatus(a.id,'approved')"><i class="ri-check-line"></i> قبول</button>
              <button v-if="a.status==='pending'" class="btn btn-sm btn-danger" @click="updateStatus(a.id,'rejected')"><i class="ri-close-line"></i> رفض</button>
              <span v-if="a.status!=='pending'" class="text-muted text-sm">تم المعالجة</span>
            </div></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
