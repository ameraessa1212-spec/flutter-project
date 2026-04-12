<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const items = ref([])
const loading = ref(true)
const search = ref('')
const specId = ref('')
const status = ref('')

async function load() {
  loading.value = true
  const params = {}
  if (search.value) params.search = search.value
  if (specId.value) params.specialization_id = specId.value
  if (status.value) params.status = status.value
  const { data } = await api.get('/student-requests', { params }).catch(() => ({ data: { data: [] } }))
  items.value = data.data || []
  loading.value = false
}

function onSearch(val) { search.value = val; load() }
function onFilter(val) { specId.value = val; load() }
function onStatus(val) { status.value = val; load() }

onMounted(load)
</script>

<template>
  <div>
    <PageHeader title="بيانات الطلاب" show-search show-spec-filter show-status-filter search-placeholder="ابحث باسم الطالب..." @search="onSearch" @filter="onFilter" @status-filter="onStatus" />

    <SkeletonLoader v-if="loading" type="table" :columns="4" />
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
