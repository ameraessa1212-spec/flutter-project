<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'

const items = ref([])
const loading = ref(true)

async function load() {
  loading.value = true
  const { data } = await api.get('/student-requests').catch(() => ({ data: { data: [] } }))
  items.value = data.data || []
  loading.value = false
}

onMounted(load)
</script>

<template>
  <div>
    <PageHeader title="بيانات الطلاب" />

    <div v-if="loading" class="loading">جاري التحميل...</div>
    <div v-else-if="!items.length" class="empty">لا يوجد طلاب</div>
    <div v-else class="card" style="overflow-x:auto;">
      <table class="table">
        <thead><tr><th>الطالب</th><th>الشركة</th><th>التخصص</th><th>الحالة</th></tr></thead>
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
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
