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
  if (specFilter.value) params.specialization_id = specFilter.value
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
    setTimeout(() => { showAssignModal.value = false; loadData() }, 1200)
  } catch (e) {
    assignMsg.value = e.response?.data?.message || 'حدث خطأ أثناء التعيين.'
  }
  assigning.value = false
}
</script>

<template>
  <div class="reports-transfer-page">
    <PageHeader 
      title="تحويل التقارير للممتحنين" 
      show-search 
      show-spec-filter 
      search-placeholder="ابحث باسم الطالب..." 
      @search="onSearch" 
      @filter="onFilter" 
    />

    <div class="actions-bar">
      <button v-if="students.length" class="btn-select-all" @click="selectAll">
        <i :class="selectedIds.size === students.length ? 'ri-checkbox-multiple-fill' : 'ri-checkbox-multiple-line'"></i>
        {{ selectedIds.size === students.length ? 'إلغاء الكل' : 'تحديد الكل' }}
      </button>
      
      <transition name="fade">
        <button v-if="hasSelected" class="btn-assign-main" @click="openAssign">
          <i class="ri-user-shared-2-line"></i>
          تعيين ممتحن لـ ({{ selectedIds.size }}) طالب
        </button>
      </transition>
    </div>

    <SkeletonLoader v-if="loading" type="cards" :card-count="6" />
    <div v-else-if="!students.length" class="empty-state">لا يوجد طلاب بانتظار التحويل</div>

    <div v-else class="grid-transfer">
      <div
        v-for="s in students"
        :key="s.id"
        class="transfer-card"
        :class="{ 'is-selected': selectedIds.has(s.student_id) }"
        @click="toggleSelect(s.student_id)"
      >
        <div class="selection-overlay">
          <div class="custom-checkbox" :class="{ 'checked': selectedIds.has(s.student_id) }">
            <i v-if="selectedIds.has(s.student_id)" class="ri-check-line"></i>
          </div>
        </div>

        <div class="card-body">
          <div class="avatar-box-small">
            <i class="ri-user-line"></i>
          </div>
          <div class="student-details">
            <h4 class="name">{{ s.student_name }}</h4>
            <span class="number">{{ s.student_number || '--' }}</span>
          </div>
        </div>

        <div class="card-footer">
          <div class="info-tag">
            <i class="ri-building-4-line"></i>
            <span>{{ s.company_name || 'غير محدد' }}</span>
          </div>
          <div class="spec-badge">
            {{ s.specialization || '--' }}
          </div>
        </div>
      </div>
    </div>

    <div v-if="showAssignModal" class="modal-overlay" @click.self="showAssignModal = false">
      <div class="modal-card">
        <div class="modal-header">
           <h3>تعيين ممتحن</h3>
           <i class="ri-close-line close-icon" @click="showAssignModal = false"></i>
        </div>
        
        <p class="modal-desc">سيتم تحويل ملفات ({{ selectedIds.size }}) طالب للممتحن المختار:</p>

        <div v-if="assignMsg" class="alert-box" :class="assignMsg.includes('خطأ') ? 'err' : 'success'">
          {{ assignMsg }}
        </div>

        <div class="form-group">
          <label>قائمة الممتحنين النشطين</label>
          <select v-model="selectedExaminerId" class="modern-select">
            <option value="" disabled>-- اختر ممتحن من القائمة --</option>
            <option v-for="ex in examiners" :key="ex.id" :value="ex.id">
              {{ ex.name }}
            </option>
          </select>
        </div>

        <div class="modal-actions">
          <button class="btn-cancel" @click="showAssignModal = false">إلغاء</button>
          <button class="btn-confirm" @click="assignExaminer" :disabled="assigning || !selectedExaminerId">
            <i v-if="assigning" class="ri-loader-4-line spin"></i>
            {{ assigning ? 'جاري التحويل...' : 'تأكيد التحويل' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* تحسين الشبكة لتكون الكاردات صغيرة */
.grid-transfer {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 310px));
  gap: 20px;
  justify-content: center;
  margin-top: 20px;
}

.transfer-card {
  background: white;
  border-radius: 25px;
  padding: 20px;
  border: 2px solid transparent;
  box-shadow: 0 8px 25px rgba(0,0,0,0.03);
  cursor: pointer;
  position: relative;
  transition: 0.3s;
}

.transfer-card:hover { transform: translateY(-5px); }
.transfer-card.is-selected { border-color: #6c5ce7; background: #fbfaff; }

/* تصميم التشيك بوكس المخصص */
.selection-overlay { position: absolute; top: 15px; left: 15px; }
.custom-checkbox {
  width: 22px; height: 22px; border: 2px solid #ddd; border-radius: 7px;
  display: flex; align-items: center; justify-content: center; transition: 0.2s;
}
.custom-checkbox.checked { background: #6c5ce7; border-color: #6c5ce7; color: white; }

.card-body { display: flex; align-items: center; gap: 15px; margin-bottom: 20px; margin-top: 5px; }
.avatar-box-small {
  width: 45px; height: 45px; background: #f0edff; color: #6c5ce7;
  border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 20px;
}

.student-details .name { margin: 0; font-size: 16px; color: #333; font-weight: 800; }
.student-details .number { font-size: 12px; color: #999; }

.card-footer { border-top: 1px solid #f5f5f5; padding-top: 15px; }
.info-tag { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #777; margin-bottom: 10px; }
.spec-badge {
  display: inline-block; padding: 4px 12px; background: #f3ebff;
  color: #6c5ce7; border-radius: 10px; font-size: 11px; font-weight: bold;
}

/* شريط الأفعال */
.actions-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding: 0 10px; }
.btn-select-all {
  background: white; border: 1px solid #eee; padding: 8px 16px; border-radius: 12px;
  cursor: pointer; color: #666; font-family: 'Cairo'; font-weight: bold; display: flex; align-items: center; gap: 8px;
}

.btn-assign-main {
  background: #6c5ce7; color: white; border: none; padding: 10px 20px;
  border-radius: 15px; cursor: pointer; font-family: 'Cairo'; font-weight: bold;
  display: flex; align-items: center; gap: 8px; box-shadow: 0 10px 20px rgba(108, 92, 231, 0.2);
}

/* المودال */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 2000; }
.modal-card { background: white; width: 90%; max-width: 450px; border-radius: 30px; padding: 30px; }
.modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
.modern-select { width: 100%; padding: 12px; border-radius: 12px; border: 1px solid #ddd; font-family: 'Cairo'; outline: none; }
.modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 25px; }

.btn-confirm { background: #6c5ce7; color: white; border: none; padding: 12px 25px; border-radius: 12px; cursor: pointer; font-weight: bold; }
.btn-cancel { background: #f5f5f5; border: none; padding: 12px 25px; border-radius: 12px; cursor: pointer; }

.spin { animation: rotate 1s linear infinite; }
@keyframes rotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
</style>