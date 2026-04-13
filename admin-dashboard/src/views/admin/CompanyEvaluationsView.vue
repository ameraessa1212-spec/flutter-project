<script setup>
import { ref, onMounted, computed } from 'vue'
import { api } from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const items = ref([])
const loading = ref(true)
const search = ref('')
const specId = ref('')
const showDetail = ref(false)
const detailData = ref(null)
const detailLoading = ref(false)

// Criteria labels matching the company evaluation form (16 scores, 3 domains)
const domains = [
  {
    title: 'المجال المعرفي',
    color: '#6A5AE0',
    bg: '#eeeaff',
    criteria: [
      { label: 'مدى المعرفة بالأنشطة التخصصية المختلفة في بيئة العمل', max: 7 },
      { label: 'مدى المعرفة بالنظام المؤسسي وقوانين وأخلاقيات العمل', max: 7 },
      { label: 'القدرة على توظيف المعرفة النظرية والتقنية في التدريب', max: 7 },
      { label: 'التعرف على تقنيات تخصصية جديدة أثناء التدريب', max: 7 },
      { label: 'مدى المعرفة بسوق العمل في مجال التخصص', max: 7 },
    ],
  },
  {
    title: 'المجال المهني',
    color: '#FF9F43',
    bg: '#fff4e8',
    criteria: [
      { label: 'جودة الأداء المهني في بيئة العمل', max: 6 },
      { label: 'الالتزام بالقوانين وأخلاقيات المهنة', max: 6 },
      { label: 'الالتزام بمواعيد العمل', max: 6 },
      { label: 'تقبل النقد والتوجيه', max: 6 },
      { label: 'العلاقة مع الرؤساء والزملاء والعملاء', max: 6 },
      { label: 'إبراز الشخصية الهندسية في بيئة العمل', max: 5 },
    ],
  },
  {
    title: 'مجال القدرات والمهارات',
    color: '#2ecc71',
    bg: '#e8f7f0',
    criteria: [
      { label: 'القدرة على التعلم الذاتي وتحصيل المعرفة', max: 6 },
      { label: 'القدرة على الاتصال الفعال والحوار البناء', max: 6 },
      { label: 'القدرة على تقديم العروض المرئية والمناقشة', max: 6 },
      { label: 'جودة الأعمال الموثقة (المقترحات والتقارير)', max: 6 },
      { label: 'جودة الأداء في العمل الجماعي ضمن فريق', max: 6 },
    ],
  },
]

const filtered = computed(() => {
  if (!search.value) return items.value
  const t = search.value.toLowerCase()
  return items.value.filter(i =>
    (i.student?.name || '').toLowerCase().includes(t) ||
    (i.company?.name || '').toLowerCase().includes(t)
  )
})

async function load() {
  loading.value = true
  const params = {}
  if (specId.value) params.specialization_id = specId.value
  const { data } = await api.get('/student-evaluations', { params }).catch(() => ({ data: { data: [] } }))
  // Only show items that have a company evaluation
  items.value = (data.data || []).filter(i => i.company_score > 0)
  loading.value = false
}

async function openDetail(item) {
  showDetail.value = true
  detailLoading.value = true
  detailData.value = null
  try {
    const { data } = await api.get(`/student-evaluations/${item.id}`)
    detailData.value = data.data
  } catch (_) {}
  detailLoading.value = false
}

function onSearch(val) { search.value = val }
function onFilter(val) { specId.value = val; load() }

function getScoreForDomain(scores, domainIdx) {
  if (!scores?.length) return 0
  let startIdx = 0
  for (let i = 0; i < domainIdx; i++) startIdx += domains[i].criteria.length
  const endIdx = startIdx + domains[domainIdx].criteria.length
  return scores.slice(startIdx, endIdx).reduce((a, b) => a + (b || 0), 0)
}

function getDomainMax(domainIdx) {
  return domains[domainIdx].criteria.reduce((a, c) => a + c.max, 0)
}

onMounted(load)
</script>

<template>
  <div>
    <PageHeader title="تقييمات الشركات للطلاب" show-search show-spec-filter search-placeholder="ابحث باسم الطالب أو الشركة..." @search="onSearch" @filter="onFilter" />

    <SkeletonLoader v-if="loading" type="cards" :card-count="6" />
    <div v-else-if="!filtered.length" class="empty">لا توجد تقييمات من الشركات بعد</div>
    <div v-else class="grid-3">
      <div v-for="item in filtered" :key="item.id" class="card eval-card" @click="openDetail(item)">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px;">
          <div class="avatar-circle">{{ (item.student?.name || '?').charAt(0) }}</div>
          <div>
            <strong>{{ item.student?.name }}</strong><br>
            <small class="text-muted">{{ item.student?.student_number || '--' }}</small>
          </div>
        </div>
        <p class="text-sm text-muted" style="margin-bottom:12px;"><i class="ri-building-line"></i> {{ item.company?.name }}</p>
        <div class="score-circle">
          <span class="score-value">{{ item.company_score }}</span>
          <span class="score-label">/ 100</span>
        </div>
        <div class="text-sm text-muted" style="text-align:center;margin-top:6px;">درجة تقييم الشركة</div>
      </div>
    </div>

    <!-- Detail Modal -->
    <div v-if="showDetail" class="modal-overlay" @click.self="showDetail = false">
      <div class="modal-card" style="max-width:720px;max-height:85vh;overflow-y:auto;">
        <div v-if="detailLoading" class="loading" style="padding:40px;">جاري التحميل...</div>
        <template v-else-if="detailData?.company_evaluation">
          <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:20px;">
            <div>
              <h2 style="margin:0 0 4px;">تقييم الشركة</h2>
              <p class="text-muted text-sm" style="margin:0;">{{ detailData.student?.name }} — {{ detailData.company?.name }}</p>
            </div>
            <div class="modal-score-badge">{{ detailData.company_evaluation.total_score }}<small>/100</small></div>
          </div>

          <div v-if="detailData.company_evaluation.evaluator_name" style="margin-bottom:16px;padding:10px 16px;background:#f8f9fd;border-radius:10px;">
            <span class="text-sm"><strong>المقيّم:</strong> {{ detailData.company_evaluation.evaluator_name }}</span>
            <span v-if="detailData.company_evaluation.created_at" class="text-sm text-muted" style="margin-right:16px;">{{ new Date(detailData.company_evaluation.created_at).toLocaleDateString('ar-LY') }}</span>
          </div>

          <!-- Domains breakdown -->
          <div v-for="(domain, dIdx) in domains" :key="dIdx" class="domain-block">
            <div class="domain-title" :style="{ background: domain.bg, color: domain.color }">
              {{ domain.title }}
              <span style="margin-right:auto;font-size:13px;">{{ getScoreForDomain(detailData.company_evaluation.detailed_scores, dIdx) }} / {{ getDomainMax(dIdx) }}</span>
            </div>
            <div v-for="(criterion, cIdx) in domain.criteria" :key="cIdx" class="criterion-row">
              <span class="criterion-num">{{ cIdx + 1 }}</span>
              <span class="criterion-label">{{ criterion.label }}</span>
              <span class="criterion-score">
                {{ detailData.company_evaluation.detailed_scores?.[domains.slice(0, dIdx).reduce((a, d) => a + d.criteria.length, 0) + cIdx] ?? '--' }}
                <small>/ {{ criterion.max }}</small>
              </span>
            </div>
          </div>

          <!-- Comments -->
          <div v-if="detailData.company_evaluation.comments" style="margin-top:16px;">
            <h4 style="margin-bottom:8px;font-size:14px;"><i class="ri-edit-2-line" style="color:var(--primary);"></i> ملاحظات المشرف</h4>
            <div style="padding:14px;background:#f8f9fd;border-radius:12px;font-size:14px;line-height:1.8;color:#555;">
              {{ detailData.company_evaluation.comments }}
            </div>
          </div>

          <div style="text-align:left;margin-top:20px;">
            <button class="btn btn-secondary" @click="showDetail = false">إغلاق</button>
          </div>
        </template>
        <div v-else class="text-muted" style="padding:40px;text-align:center;">لا يوجد تقييم من الشركة لهذا الطالب</div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.eval-card {
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}
.eval-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.08);
}

.score-circle {
  text-align: center;
  padding: 16px;
  background: linear-gradient(135deg, #f0eeff, #f8f7ff);
  border-radius: 14px;
  margin-top: 8px;
}
.score-value {
  font-size: 36px;
  font-weight: 900;
  color: #6A5AE0;
}
.score-label {
  font-size: 16px;
  color: #999;
  font-weight: 600;
}

.modal-score-badge {
  background: linear-gradient(135deg, #6A5AE0, #8e84f3);
  color: white;
  padding: 10px 18px;
  border-radius: 14px;
  font-size: 24px;
  font-weight: 900;
}
.modal-score-badge small {
  font-size: 14px;
  opacity: 0.7;
}

.domain-block {
  margin-bottom: 16px;
  border: 1px solid #f0f0f5;
  border-radius: 14px;
  overflow: hidden;
}

.domain-title {
  padding: 10px 16px;
  font-weight: 700;
  font-size: 14px;
  display: flex;
  align-items: center;
}

.criterion-row {
  display: flex;
  align-items: center;
  padding: 8px 16px;
  border-bottom: 1px solid #f8f8f8;
  font-size: 13px;
}
.criterion-row:last-child {
  border-bottom: none;
}

.criterion-num {
  width: 24px;
  font-weight: 800;
  color: #999;
  flex-shrink: 0;
}

.criterion-label {
  flex: 1;
  color: #444;
}

.criterion-score {
  font-weight: 800;
  color: #6A5AE0;
  min-width: 50px;
  text-align: center;
}
.criterion-score small {
  color: #999;
  font-weight: 600;
}
</style>
