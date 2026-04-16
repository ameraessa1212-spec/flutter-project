<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import api from '../../composables/useApi'
import SkeletonLoader from '../../components/SkeletonLoader.vue'
import {
  companyDomains,
  examinerDomains,
  decisionLabels,
  getCompanyDomainScore,
  getCompanyDomainMax,
  getCompanyCriterionScore,
} from '../../utils/rubricConfig'

// --- List View State ---
const students = ref([])
const loading = ref(true)
const searchText = ref('')

const filteredStudents = computed(() => {
  if (!searchText.value) return students.value
  const t = searchText.value.toLowerCase()
  return students.value.filter(s =>
    (s.student_name || '').toLowerCase().includes(t) ||
    (s.company_name || '').toLowerCase().includes(t)
  )
})

// --- Evaluation Form State ---
const selectedStudent = ref(null)
const detailData = ref(null)
const detailLoading = ref(false)
const scores = reactive({})
const decision = ref('pass')
const notes = ref('')
const submitting = ref(false)
const submitMsg = ref('')

const total = computed(() =>
  examinerDomains.reduce((sum, domain) =>
    sum + domain.items.reduce((s, item) => s + (Number(scores[item.key]) || 0), 0), 0)
)

// --- API ---
onMounted(async () => {
  const { data } = await api.get('/examiner/students').catch(() => ({ data: { data: [] } }))
  students.value = data.data || []
  loading.value = false
})

async function openStudent(student) {
  selectedStudent.value = student
  detailLoading.value = true
  detailData.value = null
  submitMsg.value = ''

  // Reset form
  Object.keys(scores).forEach(k => delete scores[k])
  decision.value = 'pass'
  notes.value = ''

  try {
    const { data } = await api.get(`/examiner/students/${student.id}`)
    detailData.value = data.data

    // Pre-populate if examiner already evaluated
    if (data.data.examiner_evaluation) {
      const ev = data.data.examiner_evaluation
      if (ev.rubric_scores) {
        Object.entries(ev.rubric_scores).forEach(([k, v]) => { scores[k] = v })
      }
      decision.value = ev.decision || 'pass'
      notes.value = ev.notes || ''
    }
  } catch (_) {
    detailData.value = null
  }
  detailLoading.value = false
}

function backToList() {
  selectedStudent.value = null
  detailData.value = null
}

function validateScores() {
  for (const domain of examinerDomains) {
    for (const item of domain.items) {
      const v = scores[item.key]
      if (v === undefined || v === null || v === '') return 'يرجى تعبئة جميع الدرجات'
      if (v < 0) return 'الدرجة لا يمكن أن تكون سالبة'
      if (v > item.max) return `الحد الأقصى لـ "${item.label}" هو ${item.max}`
    }
  }
  if (total.value > 70) return 'المجموع لا يمكن أن يتجاوز 70'
  return null
}

function enforceMax(key, max) {
  if (scores[key] > max) scores[key] = max
  if (scores[key] < 0) scores[key] = 0
}

async function submitGrade() {
  const err = validateScores()
  if (err) { submitMsg.value = err; return }

  submitting.value = true
  submitMsg.value = ''
  try {
    await api.post('/examiner/grades', {
      examiner_discussion_id: selectedStudent.value.id,
      rubric_scores: { ...scores },
      total_score: total.value,
      decision: decision.value,
      notes: notes.value || null,
    })
    // Update list status
    const s = students.value.find(x => x.id === selectedStudent.value.id)
    if (s) {
      s.status = `تم التقييم (${total.value}/70)`
      s.has_evaluation = true
      s.total_score = total.value
    }
    submitMsg.value = 'success'
    setTimeout(() => backToList(), 1500)
  } catch (e) {
    submitMsg.value = e.response?.data?.message || 'حدث خطأ أثناء الحفظ.'
  }
  submitting.value = false
}

function getDomainSubtotal(domain) {
  return domain.items.reduce((sum, item) => sum + (Number(scores[item.key]) || 0), 0)
}

function getDomainMax(domain) {
  return domain.items.reduce((sum, item) => sum + item.max, 0)
}
</script>

<template>
  <div>
    <!-- ═══════ LIST VIEW ═══════ -->
    <template v-if="!selectedStudent">
      <div class="list-header">
        <div>
          <h1 class="page-title">تقييم الطلاب</h1>
          <p class="page-subtitle">قائمة الطلاب المحولين للمناقشة والتقييم</p>
        </div>
        <input v-model="searchText" class="search-input" placeholder="ابحث باسم الطالب أو الشركة...">
      </div>

      <SkeletonLoader v-if="loading" type="cards" :card-count="6" />
      <div v-else-if="!filteredStudents.length" class="empty">لا يوجد طلاب محولين</div>
      <div v-else class="students-grid">
        <div
          v-for="s in filteredStudents"
          :key="s.id"
          class="student-card"
          :class="{ 'is-evaluated': s.has_evaluation }"
          @click="openStudent(s)"
        >
          <div class="card-top">
            <div class="avatar-circle">{{ (s.student_name || '?').charAt(0) }}</div>
            <div class="card-info">
              <h4>{{ s.student_name }}</h4>
              <span class="text-muted text-sm">{{ s.student_number || '--' }}</span>
            </div>
            <span class="badge" :class="s.has_evaluation ? 'badge-active' : 'badge-pending'">
              {{ s.has_evaluation ? 'مقيّم' : 'بانتظار التقييم' }}
            </span>
          </div>
          <div class="card-meta">
            <div class="meta-tag"><i class="ri-building-4-line"></i> {{ s.company_name || 'غير محدد' }}</div>
            <div class="spec-tag" v-if="s.specialization">{{ s.specialization }}</div>
          </div>
          <div v-if="s.has_company_evaluation" class="company-score-bar">
            <span class="text-sm text-muted">تقييم الشركة</span>
            <strong>{{ s.company_score }}/100</strong>
          </div>
          <div v-if="s.has_evaluation" class="examiner-score-bar">
            <span class="text-sm">درجة الممتحن</span>
            <strong style="color: var(--primary);">{{ s.total_score }}/70</strong>
          </div>
        </div>
      </div>
    </template>

    <!-- ═══════ EVALUATION FORM VIEW ═══════ -->
    <template v-else>
      <button class="back-btn" @click="backToList">
        <i class="ri-arrow-right-line"></i> العودة للقائمة
      </button>

      <div v-if="detailLoading" class="loading" style="padding:60px;">جاري تحميل البيانات...</div>

      <div v-else-if="detailData" class="evaluation-container">
        <!-- Header -->
        <header class="eval-header">
          <div class="college-brand">
            <i class="ri-government-line"></i>
            <div>
              <h1>كلية التقنية الإلكترونية - طرابلس</h1>
              <p>نموذج تقييم أداء الطالب - تقييم الممتحن</p>
            </div>
          </div>
          <div class="doc-info">
            <span>نموذج المناقشة والتقييم</span>
            <small>الفصل الدراسي: خريف 2025</small>
          </div>
        </header>

        <!-- Student Meta -->
        <div class="student-meta-grid">
          <div class="meta-item"><strong>الاسم:</strong> <span>{{ detailData.student?.name }}</span></div>
          <div class="meta-item"><strong>رقم القيد:</strong> <span>{{ detailData.student?.student_number || '--' }}</span></div>
          <div class="meta-item"><strong>جهة التدريب:</strong> <span>{{ detailData.internship?.company_name || '--' }}</span></div>
          <div class="meta-item"><strong>التخصص:</strong> <span>{{ detailData.student?.specialization || '--' }}</span></div>
          <div class="meta-item date-box"><strong>تاريخ البدء:</strong> <span>{{ detailData.internship?.start_date || '--' }}</span></div>
          <div class="meta-item date-box"><strong>تاريخ الانتهاء:</strong> <span>{{ detailData.internship?.end_date || '--' }}</span></div>
        </div>

        <!-- ═══ COMPANY EVALUATION (Read-Only) ═══ -->
        <div v-if="detailData.company_evaluation" class="section-block">
          <div class="section-title-bar">
            <i class="ri-building-line"></i>
            <span>تقييم جهة التدريب (30%)</span>
            <span class="section-score">{{ detailData.company_evaluation.total_score }} / 100</span>
          </div>

          <div v-for="(domain, dIdx) in companyDomains" :key="'cd-'+dIdx" class="domain-section">
            <div class="domain-header" :style="{ background: domain.bg, color: domain.color }">
              {{ dIdx + 1 }}. {{ domain.title }} ({{ domain.maxTitle }})
              <span class="domain-subtotal">{{ getCompanyDomainScore(detailData.company_evaluation.detailed_scores, dIdx) }} / {{ getCompanyDomainMax(dIdx) }}</span>
            </div>
            <div v-for="(criterion, cIdx) in domain.criteria" :key="cIdx" class="criteria-row">
              <span class="c-num">{{ cIdx + 1 }}</span>
              <p class="c-text">{{ criterion.label }}</p>
              <div class="c-grade">
                <span>{{ getCompanyCriterionScore(detailData.company_evaluation.detailed_scores, dIdx, cIdx) }}</span>
                <small>/ {{ criterion.max }}</small>
              </div>
            </div>
          </div>

          <div v-if="detailData.company_evaluation.comments" class="notes-display">
            <strong><i class="ri-edit-2-line"></i> ملاحظات المشرف:</strong>
            <p>{{ detailData.company_evaluation.comments }}</p>
          </div>
        </div>
        <div v-else class="no-eval-notice">
          <i class="ri-information-line"></i> لا يوجد تقييم من جهة التدريب بعد
        </div>

        <!-- ═══ EXAMINER EVALUATION (Editable) ═══ -->
        <div class="section-block examiner-section">
          <div class="section-title-bar examiner">
            <i class="ri-user-star-line"></i>
            <span>تقييم الممتحن (70%)</span>
            <span class="section-score">{{ total }} / 70</span>
          </div>

          <div v-for="(domain, dIdx) in examinerDomains" :key="'ed-'+dIdx" class="domain-section">
            <div class="domain-header" :style="{ background: domain.bg, color: domain.color }">
              {{ dIdx + 1 }}. {{ domain.title }} ({{ domain.maxTitle }})
              <span class="domain-subtotal">{{ getDomainSubtotal(domain) }} / {{ getDomainMax(domain) }}</span>
            </div>
            <div v-for="(item, iIdx) in domain.items" :key="item.key" class="criteria-row">
              <span class="c-num">{{ iIdx + 1 }}</span>
              <p class="c-text">{{ item.label }}</p>
              <div class="c-input-wrapper">
                <input
                  type="number"
                  class="grade-input"
                  v-model.number="scores[item.key]"
                  :min="0"
                  :max="item.max"
                  :placeholder="`${item.max}`"
                  @input="enforceMax(item.key, item.max)"
                >
                <small>/ {{ item.max }}</small>
              </div>
            </div>
          </div>
        </div>

        <!-- Notes -->
        <section class="notes-section">
          <div class="section-banner">
            <i class="ri-edit-2-line"></i> <span>ملاحظات الممتحن</span>
          </div>
          <textarea v-model="notes" class="notes-area" placeholder="اكتب ملاحظاتك حول أداء الطالب في المناقشة..."></textarea>
        </section>

        <!-- Decision -->
        <div class="decision-section">
          <label><strong>القرار:</strong></label>
          <select v-model="decision" class="decision-select">
            <option v-for="(label, val) in decisionLabels" :key="val" :value="val">{{ label }}</option>
          </select>
        </div>

        <!-- Alert Message -->
        <div v-if="submitMsg && submitMsg !== 'success'" class="alert-danger" style="margin-top:16px;">{{ submitMsg }}</div>
        <div v-if="submitMsg === 'success'" class="alert-success" style="margin-top:16px;">تم حفظ التقييم بنجاح</div>

        <!-- Footer -->
        <footer class="eval-footer">
          <div class="total-result">
            <div class="total-text">
              <h3>المجموع العام لدرجات الممتحن</h3>
              <p>النتيجة بناءً على معايير المناقشة والتقييم</p>
            </div>
            <div class="total-circle" :class="{ 'pulse-animation': total > 0 }">
              <span>{{ total }}</span>
              <small>/70</small>
            </div>
          </div>
          <div class="action-buttons">
            <button class="btn-print" @click="() => window.print()"><i class="ri-printer-line"></i> طباعة</button>
            <button class="btn-send" @click="submitGrade" :disabled="submitting">
              <i :class="submitting ? 'ri-loader-4-line spin' : 'ri-checkbox-circle-line'"></i>
              {{ submitting ? 'جاري الحفظ...' : 'اعتماد وإرسال التقييم' }}
            </button>
          </div>
        </footer>
      </div>

      <div v-else class="empty" style="padding:60px;">تعذر تحميل بيانات الطالب</div>
    </template>
  </div>
</template>

<style scoped>
/* ═══ List View ═══ */
.list-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 16px;
}

.students-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.student-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  padding: 20px;
  border: 2px solid transparent;
  box-shadow: var(--shadow-sm);
  cursor: pointer;
  transition: all 0.3s;
}
.student-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-md);
  border-color: var(--primary-bg-hover);
}
.student-card.is-evaluated {
  border-color: var(--success-bg);
}

.card-top {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 14px;
}
.card-info {
  flex: 1;
}
.card-info h4 {
  margin: 0;
  font-size: 15px;
  font-weight: 700;
}

.card-meta {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  margin-bottom: 12px;
}
.meta-tag {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 12px;
  color: var(--text-secondary);
}
.spec-tag {
  padding: 3px 10px;
  background: var(--primary-bg);
  color: var(--primary);
  border-radius: var(--radius-full);
  font-size: 11px;
  font-weight: 700;
}

.company-score-bar,
.examiner-score-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: var(--bg-body);
  border-radius: var(--radius-sm);
  margin-top: 8px;
  font-size: 13px;
}

/* ═══ Back Button ═══ */
.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  background: var(--bg-card);
  border: 1.5px solid var(--border);
  border-radius: var(--radius-md);
  font-family: 'Cairo';
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  margin-bottom: 20px;
  transition: all 0.2s;
  color: var(--text-secondary);
}
.back-btn:hover {
  border-color: var(--primary);
  color: var(--primary);
  background: var(--primary-bg);
}

/* ═══ Evaluation Container ═══ */
.evaluation-container {
  max-width: 900px;
  margin: 0 auto;
  background: var(--bg-card);
  padding: 35px;
  border-radius: 28px;
  box-shadow: var(--shadow-md);
}

/* ═══ Header ═══ */
.eval-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  padding-bottom: 20px;
  border-bottom: 2px solid var(--border-light);
}
.college-brand {
  display: flex;
  align-items: center;
  gap: 12px;
}
.college-brand i {
  font-size: 32px;
  color: var(--primary);
}
.college-brand h1 {
  font-size: 17px;
  font-weight: 800;
  margin: 0;
  color: var(--text-primary);
}
.college-brand p {
  font-size: 12px;
  color: var(--text-secondary);
  margin: 2px 0 0;
}
.doc-info {
  text-align: left;
  font-size: 13px;
  color: var(--primary);
  font-weight: 700;
}
.doc-info small {
  display: block;
  color: var(--text-muted);
  font-weight: 500;
  margin-top: 2px;
}

/* ═══ Student Meta Grid ═══ */
.student-meta-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 14px;
  background: var(--bg-body);
  padding: 20px;
  border-radius: var(--radius-lg);
  margin-bottom: 28px;
}
.meta-item {
  font-size: 14px;
}
.meta-item strong {
  color: var(--text-secondary);
  font-weight: 600;
}
.meta-item span {
  color: var(--primary);
  font-weight: 700;
  margin-right: 4px;
}

/* ═══ Section Blocks ═══ */
.section-block {
  margin-bottom: 28px;
}
.section-title-bar {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 20px;
  background: linear-gradient(135deg, #FF9F43, #FFD093);
  color: white;
  border-radius: var(--radius-md) var(--radius-md) 0 0;
  font-weight: 700;
  font-size: 15px;
}
.section-title-bar.examiner {
  background: linear-gradient(135deg, var(--primary), var(--primary-light));
}
.section-score {
  margin-right: auto;
  font-size: 14px;
  opacity: 0.9;
}

.no-eval-notice {
  padding: 20px;
  background: var(--warning-bg);
  border-radius: var(--radius-md);
  color: #E17055;
  font-weight: 600;
  margin-bottom: 28px;
  display: flex;
  align-items: center;
  gap: 8px;
}

/* ═══ Domain Sections ═══ */
.domain-section {
  margin-bottom: 16px;
  border: 1px solid var(--border-light);
  border-radius: var(--radius-md);
  overflow: hidden;
}
.domain-header {
  padding: 12px 20px;
  font-weight: 700;
  font-size: 14px;
  display: flex;
  align-items: center;
}
.domain-subtotal {
  margin-right: auto;
  font-size: 13px;
  opacity: 0.85;
}

/* ═══ Criteria Rows ═══ */
.criteria-row {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  border-bottom: 1px solid var(--border-light);
}
.criteria-row:last-child {
  border-bottom: none;
}
.c-num {
  font-weight: 800;
  color: var(--text-muted);
  margin-left: 12px;
  min-width: 22px;
  font-size: 13px;
}
.c-text {
  flex: 1;
  font-size: 14px;
  color: var(--text-secondary);
  margin: 0;
}
.c-grade {
  font-weight: 800;
  color: var(--primary);
  min-width: 55px;
  text-align: center;
  font-size: 15px;
}
.c-grade small {
  color: var(--text-muted);
  font-weight: 600;
  font-size: 12px;
}

/* ═══ Grade Input ═══ */
.c-input-wrapper {
  display: flex;
  align-items: center;
  gap: 5px;
  font-weight: 800;
  color: var(--primary);
}
.grade-input {
  width: 52px;
  padding: 8px;
  border-radius: 10px;
  border: 2px solid var(--border-light);
  text-align: center;
  font-family: 'Cairo';
  font-weight: 800;
  font-size: 15px;
  color: var(--primary);
  outline: none;
  transition: all 0.2s;
  -moz-appearance: textfield;
}
.grade-input::-webkit-outer-spin-button,
.grade-input::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}
.grade-input:focus {
  border-color: var(--primary);
  background: var(--primary-bg);
}
.c-input-wrapper small {
  color: var(--text-muted);
  font-weight: 600;
  font-size: 12px;
}

/* ═══ Notes ═══ */
.notes-section {
  margin-top: 24px;
}
.section-banner {
  padding: 10px 15px;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--text-secondary);
  font-size: 14px;
}
.notes-area {
  width: 100%;
  min-height: 100px;
  padding: 15px;
  border-radius: var(--radius-md);
  border: 2px dashed var(--border);
  font-family: 'Cairo';
  font-size: 14px;
  margin-top: 8px;
  outline: none;
  resize: vertical;
  transition: border-color 0.2s;
  box-sizing: border-box;
}
.notes-area:focus {
  border-color: var(--primary);
}

.notes-display {
  margin-top: 12px;
  padding: 14px;
  background: var(--bg-body);
  border-radius: var(--radius-md);
}
.notes-display strong {
  font-size: 13px;
  color: var(--text-secondary);
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 6px;
}
.notes-display p {
  font-size: 14px;
  line-height: 1.8;
  color: var(--text-secondary);
  margin: 0;
}

/* ═══ Decision ═══ */
.decision-section {
  margin-top: 20px;
  display: flex;
  align-items: center;
  gap: 14px;
}
.decision-section label {
  font-size: 14px;
}
.decision-select {
  flex: 1;
  max-width: 250px;
  padding: 10px 14px;
  border: 1.5px solid var(--border);
  border-radius: var(--radius-md);
  font-family: 'Cairo';
  font-size: 14px;
  font-weight: 600;
  outline: none;
  transition: border-color 0.2s;
}
.decision-select:focus {
  border-color: var(--primary);
}

/* ═══ Footer ═══ */
.eval-footer {
  margin-top: 30px;
}
.total-result {
  background: linear-gradient(135deg, var(--primary), #8e84f3);
  padding: 25px;
  border-radius: var(--radius-lg);
  color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.total-text h3 {
  font-size: 16px;
  margin: 0 0 4px;
}
.total-text p {
  font-size: 12px;
  opacity: 0.8;
  margin: 0;
}
.total-circle {
  width: 80px;
  height: 80px;
  background: rgba(255, 255, 255, 0.2);
  border: 2px solid white;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.total-circle span {
  font-size: 26px;
  font-weight: 900;
  line-height: 1;
}
.total-circle small {
  font-size: 12px;
  opacity: 0.8;
}

.pulse-animation {
  animation: pulse 2s ease-in-out infinite;
}
@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.action-buttons {
  display: flex;
  gap: 12px;
  margin-top: 20px;
  justify-content: flex-end;
}
.action-buttons button {
  padding: 12px 24px;
  border-radius: var(--radius-md);
  border: none;
  font-family: 'Cairo';
  font-weight: 700;
  font-size: 14px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
}
.btn-print {
  background: var(--bg-body);
  color: var(--text-secondary);
}
.btn-print:hover {
  background: var(--border);
}
.btn-send {
  background: var(--text-primary);
  color: white;
}
.btn-send:hover {
  opacity: 0.9;
}
.btn-send:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.spin {
  animation: rotate 1s linear infinite;
}
@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* ═══ Print Styles ═══ */
@media print {
  .back-btn,
  .action-buttons,
  .list-header .search-input {
    display: none !important;
  }
  .evaluation-container {
    box-shadow: none;
    border: none;
    padding: 20px;
    max-width: 100%;
  }
  .grade-input {
    border: none;
    background: none;
  }
}

/* ═══ Responsive ═══ */
@media (max-width: 768px) {
  .student-meta-grid {
    grid-template-columns: 1fr;
  }
  .eval-header {
    flex-direction: column;
    gap: 12px;
  }
  .total-result {
    flex-direction: column;
    text-align: center;
    gap: 16px;
  }
}
</style>
