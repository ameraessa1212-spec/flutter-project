<script setup>
import { ref, onMounted, computed } from 'vue'
import { api } from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const students = ref([])
const examiners = ref([])
const loading = ref(true)
const selectedIds = ref(new Set())
const showAssignModal = ref(false)
const selectedExaminerId = ref('')
const assigning = ref(false)
const assignMsg = ref('')

const hasSelected = computed(() => selectedIds.value.size > 0)
const search = ref('')
const specFilter = ref('')

function onSearch(val) { search.value = val; loadData() }
function onFilter(val) { specFilter.value = val; loadData() }

async function loadData() {
  loading.value = true
  const params = {}
  if (search.value) params.search = search.value
  if (specFilter.value) params.specialization = specFilter.value
  const [studentsRes, examinersRes] = await Promise.all([
    api.get('/evaluation-list', { params }).catch(() => ({ data: { data: [] } })),
    api.get('/examiners').catch(() => ({ data: { data: [] } })),
  ])
  students.value = studentsRes.data.data || []
  examiners.value = (examinersRes.data.data || []).filter(e => e.status === 'active')
  loading.value = false
}

onMounted(loadData)

function toggleSelect(id) {
  const s = new Set(selectedIds.value)
  s.has(id) ? s.delete(id) : s.add(id)
  selectedIds.value = s
}

function selectAll() {
  if (selectedIds.value.size === students.value.length) {
    selectedIds.value = new Set()
  } else {
    selectedIds.value = new Set(students.value.map(s => s.student_id))
  }
}

function openAssign() {
  selectedExaminerId.value = ''
  assignMsg.value = ''
  showAssignModal.value = true
}

async function assignExaminer() {
  if (!selectedExaminerId.value) return
  assigning.value = true
  assignMsg.value = ''
  try {
    const { data } = await api.post('/evaluation-list/send-to-examiner', {
      student_ids: Array.from(selectedIds.value),
      examiner_id: selectedExaminerId.value,
    })
    assignMsg.value = data.message || 'تم التعيين بنجاح.'
    selectedIds.value = new Set()
    setTimeout(() => { showAssignModal.value = false }, 1200)
    await loadData()
  } catch (e) {
    assignMsg.value = e.response?.data?.message || 'حدث خطأ أثناء التعيين.'
  }
  assigning.value = false
}
</script>

<template>
  <div>
    <PageHeader title="تحويل التقارير للممتحنين" show-search show-spec-filter search-placeholder="ابحث باسم الطالب..." @search="onSearch" @filter="onFilter" />
    <div style="display:flex;justify-content:flex-end;gap:10px;margin-bottom:16px;">
      <button v-if="students.length" class="btn btn-secondary btn-sm" @click="selectAll">
        {{ selectedIds.size === students.length ? 'إلغاء الكل' : 'تحديد الكل' }}
      </button>
      <button v-if="hasSelected" class="btn btn-primary" @click="openAssign">
        <i class="ri-user-add-line"></i> تعيين ممتحن ({{ selectedIds.size }})
      </button>
    </div>

    <SkeletonLoader v-if="loading" type="cards" :card-count="6" />
    <div v-else-if="!students.length" class="empty">لا يوجد طلاب</div>
    <div v-else class="grid-3">
      <div
        v-for="s in students"
        :key="s.id"
        class="card"
        :style="{ border: selectedIds.has(s.student_id) ? '2px solid var(--primary)' : '', cursor: 'pointer' }"
        @click="toggleSelect(s.student_id)"
      >
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px;">
          <input
            type="checkbox"
            :checked="selectedIds.has(s.student_id)"
            @click.stop="toggleSelect(s.student_id)"
            style="width:18px;height:18px;accent-color:var(--primary);"
          >
          <div class="avatar-circle">{{ (s.student_name||'').charAt(0) }}</div>
          <div><strong>{{ s.student_name }}</strong><br><small style="color:#999;">{{ s.student_number || '--' }}</small></div>
        </div>
        <p style="font-size:13px;color:#777;"><i class="ri-building-line"></i> {{ s.company_name || '--' }}</p>
        <span class="badge badge-purple" style="margin-top:8px;">{{ s.specialization || '--' }}</span>
      </div>
    </div>

    <!-- Assign Modal -->
    <div v-if="showAssignModal" class="modal-overlay" @click.self="showAssignModal = false">
      <div class="modal-card">
        <h2 style="margin-bottom:16px;">تعيين ممتحن</h2>
        <p class="text-sm text-muted" style="margin-bottom:14px;">سيتم تعيين {{ selectedIds.size }} طالب للممتحن المحدد.</p>

        <div v-if="assignMsg" class="alert" :class="assignMsg.includes('خطأ') ? 'alert-danger' : 'alert-success'" style="margin-bottom:12px;">{{ assignMsg }}</div>

        <div class="form-group">
          <label>اختر الممتحن</label>
          <select v-model="selectedExaminerId" class="form-input">
            <option value="" disabled>-- اختر ممتحن --</option>
            <option v-for="ex in examiners" :key="ex.id" :value="ex.id">{{ ex.name }} ({{ ex.email }})</option>
          </select>
        </div>

        <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:18px;">
          <button class="btn btn-secondary" @click="showAssignModal = false">إلغاء</button>
          <button class="btn btn-primary" @click="assignExaminer" :disabled="assigning || !selectedExaminerId">
            {{ assigning ? 'جاري التعيين...' : 'تعيين' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
