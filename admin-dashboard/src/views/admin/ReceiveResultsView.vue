<script setup>
import { ref, onMounted, computed } from 'vue'
import { api } from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'
import SkeletonLoader from '../../components/SkeletonLoader.vue'
import {
  companyDomains,
  examinerDomains,
  decisionLabels,
  getCompanyDomainScore,
  getCompanyDomainMax,
  getCompanyCriterionScore,
  getExaminerDomainScore,
} from '../../utils/rubricConfig'

const results = ref([])
const loading = ref(true)
const search = ref('')
const specId = ref('')

// Detail view state
const selectedResult = ref(null)
const detailData = ref(null)
const detailLoading = ref(false)

const filtered = computed(() => {
  if (!search.value) return results.value
  const t = search.value.toLowerCase()
  return results.value.filter(r =>
    (r.student_name || '').toLowerCase().includes(t) ||
    (r.company_name || '').toLowerCase().includes(t) ||
    (r.examiner_name || '').toLowerCase().includes(t)
  )
})

async function load() {
  loading.value = true
  const params = {}
  if (specId.value) params.specialization_id = specId.value
  const { data } = await api.get('/evaluation-results', { params }).catch(() => ({ data: { data: [] } }))
  results.value = data.data || []
  loading.value = false
}

async function openDetail(ev) {
  selectedResult.value = ev
  detailLoading.value = true
  detailData.value = null

  if (ev.internship_id) {
    try {
      const { data } = await api.get(`/student-evaluations/${ev.internship_id}`)
      detailData.value = data.data
    } catch (_) {
      // Fallback: use the evaluation result data directly
      detailData.value = null
    }
  }
  detailLoading.value = false
}

function backToList() {
  selectedResult.value = null
  detailData.value = null
}

function onSearch(val) { search.value = val }
function onFilter(val) { specId.value = val; load() }

function getExaminerDomainMax(domainIdx) {
  return examinerDomains[domainIdx].items.reduce((a, item) => a + item.max, 0)
}

onMounted(load)
</script>

<template>
  <div>
    <!-- ═══════ LIST VIEW ═══════ -->
    <template v-if="!selectedResult">
      <PageHeader
        title="استلام تقييمات الطلاب"
        show-search
        show-spec-filter
        search-placeholder="ابحث بالاسم أو الشركة أو الممتحن..."
        @search="onSearch"
        @filter="onFilter"
      />

      <SkeletonLoader v-if="loading" type="cards" :card-count="6" />
      <div v-else-if="!filtered.length" class="empty">لا توجد نتائج</div>
      <div v-else class="results-grid">
        <div
          v-for="ev in filtered"
          :key="ev.id"
          class="result-card"
          @click="openDetail(ev)"
        >
          <div class="card-top">
            <div class="avatar-circle">{{ (ev.student_name || '?').charAt(0) }}</div>
            <div class="card-info">
              <h4>{{ ev.student_name }}</h4>
              <span class="text-muted text-sm">{{ ev.student_number || '--' }}</span>
            </div>
          </div>

          <div class="card-details">
            <div class="detail-row" v-if="ev.examiner_name">
              <i class="ri-user-star-line"></i>
              <span>{{ ev.examiner_name }}</span>
            </div>
            <div class="detail-row" v-if="ev.company_name">
              <i class="ri-building-4-line"></i>
              <span>{{ ev.company_name }}</span>
            </div>
            <div class="detail-row" v-if="ev.specialization">
              <span class="spec-tag">{{ ev.specialization }}</span>
            </div>
          </div>

          <div class="score-section">
            <div class="score-display">
              <span class="score-value">{{ ev.total_score }}</span>
              <span class="score-label">/70</span>
            </div>
            <span v-if="ev.decision" class="badge" :class="{
              'badge-active': ev.decision === 'pass',
              'badge-inactive': ev.decision === 'fail',
              'badge-pending': ev.decision === 'conditional_pass',
            }">
              {{ decisionLabels[ev.decision] || ev.decision }}
            </span>
          </div>
        </div>
      </div>
    </template>

    <!-- ═══════ DETAIL VIEW ═══════ -->
    <template v-else>
      <button class="back-btn" @click="backToList">
        <i class="ri-arrow-right-line"></i> العودة للقائمة
      </button>

      <div v-if="detailLoading" class="loading" style="padding:60px;">جاري تحميل التفاصيل...</div>

      <div v-else class="evaluation-container">
        <!-- Header -->
        <header class="eval-header">
          <div class="college-brand">
            <i class="ri-government-line"></i>
            <div>
              <h1>كلية التقنية الإلكترونية - طرابلس</h1>
              <p>مكتب الشؤون العلمية والتقنية / قسم المشاريع والتدريب الميداني</p>
            </div>
          </div>
          <div class="doc-info">
            <span>نموذج تقييم أداء الطالب</span>
            <small>الفصل الدراسي: خريف 2025</small>
          </div>
        </header>

        <!-- Student Meta -->
        <div class="student-meta-grid">
          <template v-if="detailData">
            <div class="meta-item"><strong>الاسم:</strong> <span>{{ detailData.student?.name }}</span></div>
            <div class="meta-item"><strong>رقم القيد:</strong> <span>{{ detailData.student?.student_number || '--' }}</span></div>
            <div class="meta-item"><strong>جهة التدريب:</strong> <span>{{ detailData.company?.name || '--' }}</span></div>
            <div class="meta-item"><strong>التخصص:</strong> <span>{{ detailData.student?.specialization || '--' }}</span></div>
          </template>
          <template v-else>
            <div class="meta-item"><strong>الاسم:</strong> <span>{{ selectedResult.student_name }}</span></div>
            <div class="meta-item"><strong>رقم القيد:</strong> <span>{{ selectedResult.student_number || '--' }}</span></div>
            <div class="meta-item"><strong>جهة التدريب:</strong> <span>{{ selectedResult.company_name || '--' }}</span></div>
            <div class="meta-item"><strong>التخصص:</strong> <span>{{ selectedResult.specialization || '--' }}</span></div>
          </template>
        </div>

        <!-- ═══ COMPANY EVALUATION (Read-Only) ═══ -->
        <template v-if="detailData?.company_evaluation">
          <div class="section-block">
            <div class="section-title-bar company">
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
            <div v-if="detailData.company_evaluation.evaluator_name" class="text-sm text-muted" style="margin-top:8px;">
              المقيّم: {{ detailData.company_evaluation.evaluator_name }}
            </div>
          </div>
        </template>

        <!-- ═══ EXAMINER EVALUATIONS (Read-Only) ═══ -->
        <template v-if="detailData?.examiner_evaluations?.length">
          <div v-for="ev in detailData.examiner_evaluations" :key="ev.id" class="section-block">
            <div class="section-title-bar examiner">
              <i class="ri-user-star-line"></i>
              <span>تقييم الممتحن: {{ ev.examiner_name || 'ممتحن' }} (70%)</span>
              <span class="section-score">{{ ev.total_score }} / 70</span>
            </div>

            <template v-if="ev.rubric_scores">
              <div v-for="(domain, dIdx) in examinerDomains" :key="'ed-'+dIdx" class="domain-section">
                <div class="domain-header" :style="{ background: domain.bg, color: domain.color }">
                  {{ dIdx + 1 }}. {{ domain.title }} ({{ domain.maxTitle }})
                  <span class="domain-subtotal">{{ getExaminerDomainScore(ev.rubric_scores, dIdx) }} / {{ getExaminerDomainMax(dIdx) }}</span>
                </div>
                <div v-for="(item, iIdx) in domain.items" :key="item.key" class="criteria-row">
                  <span class="c-num">{{ iIdx + 1 }}</span>
                  <p class="c-text">{{ item.label }}</p>
                  <div class="c-grade">
                    <span>{{ ev.rubric_scores[item.key] ?? '--' }}</span>
                    <small>/ {{ item.max }}</small>
                  </div>
                </div>
              </div>
            </template>

            <div v-if="ev.notes" class="notes-display">
              <strong><i class="ri-edit-2-line"></i> ملاحظات الممتحن:</strong>
              <p>{{ ev.notes }}</p>
            </div>

            <div v-if="ev.decision" class="decision-display">
              <strong>القرار:</strong>
              <span class="badge" :class="{
                'badge-active': ev.decision === 'pass',
                'badge-inactive': ev.decision === 'fail',
                'badge-pending': ev.decision === 'conditional_pass',
              }">{{ decisionLabels[ev.decision] || ev.decision }}</span>
            </div>
          </div>
        </template>

        <!-- Fallback: show from selectedResult if detail API failed -->
        <template v-else-if="!detailData && selectedResult.rubric_scores">
          <div class="section-block">
            <div class="section-title-bar examiner">
              <i class="ri-user-star-line"></i>
              <span>تقييم الممتحن: {{ selectedResult.examiner_name || 'ممتحن' }} (70%)</span>
              <span class="section-score">{{ selectedResult.total_score }} / 70</span>
            </div>

            <div v-for="(domain, dIdx) in examinerDomains" :key="'ed-'+dIdx" class="domain-section">
              <div class="domain-header" :style="{ background: domain.bg, color: domain.color }">
                {{ dIdx + 1 }}. {{ domain.title }} ({{ domain.maxTitle }})
                <span class="domain-subtotal">{{ getExaminerDomainScore(selectedResult.rubric_scores, dIdx) }} / {{ getExaminerDomainMax(dIdx) }}</span>
              </div>
              <div v-for="(item, iIdx) in domain.items" :key="item.key" class="criteria-row">
                <span class="c-num">{{ iIdx + 1 }}</span>
                <p class="c-text">{{ item.label }}</p>
                <div class="c-grade">
                  <span>{{ selectedResult.rubric_scores[item.key] ?? '--' }}</span>
                  <small>/ {{ item.max }}</small>
                </div>
              </div>
            </div>

            <div v-if="selectedResult.notes" class="notes-display">
              <strong><i class="ri-edit-2-line"></i> ملاحظات الممتحن:</strong>
              <p>{{ selectedResult.notes }}</p>
            </div>

            <div v-if="selectedResult.decision" class="decision-display">
              <strong>القرار:</strong>
              <span class="badge" :class="{
                'badge-active': selectedResult.decision === 'pass',
                'badge-inactive': selectedResult.decision === 'fail',
                'badge-pending': selectedResult.decision === 'conditional_pass',
              }">{{ decisionLabels[selectedResult.decision] || selectedResult.decision }}</span>
            </div>
          </div>
        </template>

        <!-- ═══ COMBINED FINAL SCORE ═══ -->
        <footer class="eval-footer">
          <template v-if="detailData">
            <div class="score-breakdown">
              <div class="breakdown-item">
                <span>تقييم الشركة (30%)</span>
                <strong>{{ detailData.company_weighted }}</strong>
              </div>
              <div class="breakdown-item">
                <span>تقييم الممتحن (70%)</span>
                <strong>{{ detailData.examiner_weighted }}</strong>
              </div>
            </div>
            <div class="total-result">
              <div class="total-text">
                <h3>المعدل النهائي</h3>
                <p>الشركة {{ detailData.company_weighted }} + الممتحن {{ detailData.examiner_weighted }}</p>
              </div>
              <div class="total-circle pulse-animation">
                <span>{{ detailData.final_percentage }}</span>
                <small>%</small>
              </div>
            </div>
          </template>
          <template v-else>
            <div class="total-result">
              <div class="total-text">
                <h3>درجة الممتحن</h3>
                <p>النتيجة بناءً على معايير المناقشة والتقييم</p>
              </div>
              <div class="total-circle pulse-animation">
                <span>{{ selectedResult.total_score }}</span>
                <small>/70</small>
              </div>
            </div>
          </template>

          <div class="action-buttons">
            <button class="btn-print" @click="() => window.print()"><i class="ri-printer-line"></i> طباعة</button>
            <button class="btn-secondary-action" @click="backToList"><i class="ri-arrow-right-line"></i> العودة</button>
          </div>
        </footer>
      </div>
    </template>
  </div>
</template>

<style scoped>
/* ═══ List View ═══ */
.results-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.result-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  padding: 20px;
  border: 1px solid var(--border-light);
  box-shadow: var(--shadow-sm);
  cursor: pointer;
  transition: all 0.3s;
}
.result-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-md);
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

.card-details {
  margin-bottom: 14px;
}
.detail-row {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: var(--text-secondary);
  margin-bottom: 6px;
}
.detail-row i {
  color: var(--text-muted);
}
.spec-tag {
  padding: 3px 10px;
  background: var(--primary-bg);
  color: var(--primary);
  border-radius: var(--radius-full);
  font-size: 11px;
  font-weight: 700;
}

.score-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background: var(--bg-body);
  border-radius: var(--radius-md);
}
.score-display {
  display: flex;
  align-items: baseline;
  gap: 2px;
}
.score-value {
  font-size: 28px;
  font-weight: 900;
  color: var(--primary);
}
.score-label {
  font-size: 14px;
  color: var(--text-muted);
  font-weight: 600;
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

/* ═══ Student Meta ═══ */
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
  border-radius: var(--radius-md) var(--radius-md) 0 0;
  font-weight: 700;
  font-size: 15px;
  color: white;
}
.section-title-bar.company {
  background: linear-gradient(135deg, #FF9F43, #FFD093);
}
.section-title-bar.examiner {
  background: linear-gradient(135deg, var(--primary), var(--primary-light));
}
.section-score {
  margin-right: auto;
  font-size: 14px;
  opacity: 0.9;
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

/* ═══ Notes & Decision ═══ */
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

.decision-display {
  margin-top: 12px;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  background: var(--bg-body);
  border-radius: var(--radius-md);
  font-size: 14px;
}

/* ═══ Footer ═══ */
.eval-footer {
  margin-top: 30px;
}

.score-breakdown {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
}
.breakdown-item {
  flex: 1;
  padding: 14px;
  background: var(--bg-body);
  border-radius: var(--radius-md);
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
}
.breakdown-item strong {
  color: var(--primary);
  font-size: 18px;
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
.btn-secondary-action {
  background: var(--text-primary);
  color: white;
}
.btn-secondary-action:hover {
  opacity: 0.9;
}

/* ═══ Print ═══ */
@media print {
  .back-btn,
  .action-buttons {
    display: none !important;
  }
  .evaluation-container {
    box-shadow: none;
    border: none;
    padding: 20px;
    max-width: 100%;
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
  .score-breakdown {
    flex-direction: column;
  }
  .total-result {
    flex-direction: column;
    text-align: center;
    gap: 16px;
  }
}
</style>
