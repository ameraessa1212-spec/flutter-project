<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const offers = ref([])
const loading = ref(true)
const detail = ref(null)
const search = ref('')
const specId = ref('')
const status = ref('')

const statusOptions = [
  { value: 'pending', label: 'قيد المراجعة' },
  { value: 'approved', label: 'مقبول' },
  { value: 'published', label: 'منشور' },
  { value: 'rejected', label: 'مرفوض' },
]

function statusLabel(s) {
  if (s === 'pending') return 'قيد المراجعة'
  if (s === 'approved') return 'مقبول'
  if (s === 'published') return 'منشور'
  if (s === 'rejected') return 'مرفوض'
  return s || '--'
}

function statusClass(s) {
  if (s === 'pending') return 'badge-pending'
  if (s === 'approved' || s === 'published') return 'badge-active'
  if (s === 'rejected') return 'badge-inactive'
  return ''
}

async function load() {
  loading.value = true
  const params = {}
  if (search.value) params.search = search.value
  if (specId.value) params.specialization_id = specId.value
  if (status.value) params.status = status.value
  const { data } = await api.get('/company-offers', { params }).catch(() => ({ data: { data: [] } }))
  offers.value = data.data || []
  loading.value = false
}

function onSearch(val) { search.value = val; load() }
function onFilter(val) { specId.value = val; load() }
function onStatus(val) { status.value = val; load() }

async function approve(o) {
  if (!confirm('تأكيد قبول العرض؟')) return
  await api.put(`/company-offers/${o.id}/approve`)
  o.status = 'approved'
}
async function reject(o) {
  if (!confirm('تأكيد رفض العرض؟')) return
  await api.put(`/company-offers/${o.id}/reject`)
  o.status = 'rejected'
}

onMounted(load)
</script>

<template>
  <div>
    <PageHeader title="عروض التدريب من الشركات" show-search show-spec-filter show-status-filter :status-options="statusOptions" search-placeholder="ابحث باسم الشركة..." @search="onSearch" @filter="onFilter" @status-filter="onStatus" />
    <SkeletonLoader v-if="loading" type="cards" :card-count="6" />
    <div v-else-if="!offers.length" class="empty">لا توجد عروض</div>
    <div v-else class="grid-3">
      <div v-for="o in offers" :key="o.id" class="card" :style="{ opacity: o.status==='rejected' ? 0.5 : 1 }">
        <div style="display:flex;justify-content:space-between;margin-bottom:10px;">
          <strong>{{ o.company?.name }}</strong>
          <span class="badge" :class="statusClass(o.status)">
            {{ statusLabel(o.status) }}
          </span>
        </div>
        <p style="font-size:13px;color:#777;margin-bottom:6px;"><i class="ri-map-pin-line"></i> {{ o.city || '--' }}</p>
        <p style="font-size:13px;color:#777;margin-bottom:6px;"><i class="ri-briefcase-line"></i> {{ o.specialization || '--' }}</p>
        <p style="font-size:13px;color:#777;margin-bottom:6px;"><i class="ri-group-line"></i> {{ o.seats_count }} طلاب | {{ o.duration_text || (o.duration_days ? o.duration_days + ' يوم' : '--') }}</p>
        <p style="font-size:13px;color:#777;margin-bottom:12px;"><i class="ri-calendar-line"></i> {{ o.start_date || '--' }} → {{ o.end_date || '--' }}</p>
        <div v-if="o.status==='pending'" style="display:flex;gap:8px;">
          <button class="btn btn-sm btn-outline" @click="detail = o">عرض</button>
          <button class="btn btn-sm btn-success" @click="approve(o)">قبول</button>
          <button class="btn btn-sm btn-danger" @click="reject(o)">رفض</button>
        </div>
        <div v-else style="display:flex;gap:8px;justify-content:center;">
          <button class="btn btn-sm btn-outline" @click="detail = o">عرض التفاصيل</button>
        </div>
      </div>
    </div>

    <!-- Detail Modal -->
    <div v-if="detail" class="modal-backdrop" @click.self="detail = null">
      <div class="modal-box">
        <div class="modal-header"><h3>تفاصيل العرض</h3><button class="modal-close" @click="detail = null">&times;</button></div>
        <p><strong>الشركة:</strong> {{ detail.company?.name }}</p>
        <p><strong>الوصف:</strong> {{ detail.company?.description || '--' }}</p>
        <p><strong>البريد:</strong> {{ detail.company?.email || '--' }}</p>
        <p><strong>الموقع:</strong> {{ detail.city || '--' }}</p>
        <p><strong>التخصص:</strong> {{ detail.specialization || '--' }}</p>
        <p><strong>العدد:</strong> {{ detail.seats_count }} طلاب</p>
        <p><strong>المدة:</strong> {{ detail.duration_text || (detail.duration_days ? detail.duration_days + ' يوم' : '--') }}</p>
        <p><strong>تاريخ البدء:</strong> {{ detail.start_date || '--' }}</p>
        <p><strong>تاريخ الانتهاء:</strong> {{ detail.end_date || '--' }}</p>
        <p><strong>الحالة:</strong> <span class="badge" :class="statusClass(detail.status)">{{ statusLabel(detail.status) }}</span></p>
      </div>
    </div>
  </div>
</template>
