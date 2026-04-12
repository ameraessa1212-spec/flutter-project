<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import api from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const router = useRouter()
const companies = ref([])
const loading = ref(true)
const search = ref('')
const specId = ref('')

const filtered = computed(() => {
  if (!search.value) return companies.value
  const t = search.value.toLowerCase()
  return companies.value.filter(c => (c.name || '').toLowerCase().includes(t))
})

async function load() {
  loading.value = true
  const params = {}
  if (specId.value) params.specialization = specId.value
  const { data } = await api.get('/registered-companies', { params }).catch(() => ({ data: { data: [] } }))
  companies.value = data.data || []
  loading.value = false
}

function onSearch(val) { search.value = val }
function onFilter(val) { specId.value = val; load() }

onMounted(load)
</script>

<template>
  <div>
    <PageHeader title="الشركات المسجلة" show-search show-spec-filter search-placeholder="بحث عن شركة..." @search="onSearch" @filter="onFilter" />

    <div v-if="!loading" style="margin-bottom:16px;">
      <span class="badge badge-purple"><i class="ri-building-line"></i> {{ filtered.length }} شركة</span>
    </div>

    <SkeletonLoader v-if="loading" type="table" :columns="6" />
    <div v-else-if="!filtered.length" class="empty">لا توجد شركات</div>
    <div v-else class="card" style="overflow-x:auto;">
      <table class="table">
        <thead>
          <tr>
            <th>الشركة</th>
            <th>المدينة</th>
            <th>البريد</th>
            <th>الهاتف</th>
            <th>المتدربون</th>
            <th>الحالة</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="c in filtered" :key="c.id" style="cursor:pointer;" @click="router.push(`/registered-companies/${c.id}`)">
            <td>
              <div style="display:flex;align-items:center;gap:10px;">
                <div class="avatar-circle" style="width:36px;height:36px;font-size:14px;">{{ (c.name||'').charAt(0) }}</div>
                <div>
                  <strong>{{ c.name }}</strong>
                  <small v-if="c.website_url" class="text-muted" style="display:block;font-size:11px;">{{ c.website_url }}</small>
                </div>
              </div>
            </td>
            <td>{{ c.city || '--' }}</td>
            <td>{{ c.email || '--' }}</td>
            <td>{{ c.phone || '--' }}</td>
            <td><span class="badge badge-purple">{{ c.internships_count }}</span></td>
            <td><span class="badge" :class="c.is_active ? 'badge-active' : 'badge-inactive'">{{ c.is_active ? 'نشط' : 'معطل' }}</span></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
