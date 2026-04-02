<script setup>
import { ref, onMounted, computed } from 'vue'
import { api } from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'

const items = ref([])
const loading = ref(true)
const search = ref('')
const specId = ref('')
const showDetail = ref(false)
const detailLoading = ref(false)
const detail = ref(null)

const filtered = computed(() => {
  let list = items.value
  if (search.value) {
    const t = search.value.toLowerCase()
    list = list.filter(i => i.student.name.toLowerCase().includes(t) || i.company.name.toLowerCase().includes(t))
  }
  return list
})

async function load() {
  loading.value = true
  const params = {}
  if (specId.value) params.specialization_id = specId.value
  const { data } = await api.get('/student-evaluations', { params }).catch(() => ({ data: { data: [] } }))
  items.value = data.data || []
  loading.value = false
}

async function openDetail(item) {
  showDetail.value = true
  detailLoading.value = true
  detail.value = null
  try {
    const { data } = await api.get(`/student-evaluations/${item.id}`)
    detail.value = data.data
  } catch (_) {
    detail.value = null
  }
  detailLoading.value = false
}

function onSearch(val) { search.value = val }
function onFilter(val) { specId.value = val; load() }

onMounted(load)

const rubricLabels = {
  knowledge: 'المعرفة',
  skills: 'المهارات',
  documentation: 'التوثيق',
  discussion: 'المناقشة',
  research: 'البحث',
}
</script>

<template>
  <div>
    <PageHeader title="لوحة النتائج النهائية" show-search show-spec-filter search-placeholder="ابحث باسم الطالب أو الشركة..." @search="onSearch" @filter="onFilter" />
    <div v-if="loading" class="loading">جاري التحميل...</div>
    <div v-else-if="!filtered.length" class="empty">لا توجد نتائج</div>
    <div v-else class="grid-3">
      <div v-for="item in filtered" :key="item.id" class="card" style="cursor:pointer;" @click="openDetail(item)">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px;">
          <div class="avatar-circle">{{ item.student.name.charAt(0) }}</div>
          <div>
            <strong>{{ item.student.name }}</strong><br>
            <small class="text-muted">{{ item.student.student_number || '--' }}</small>
          </div>
        </div>
        <p class="text-sm text-muted mb-sm"><i class="ri-building-line"></i> {{ item.company.name }}</p>
        <div class="mb-sm">
          <div class="flex-between text-sm"><span>الشركة (30%)</span><strong>{{ item.company_weighted }}</strong></div>
          <div class="progress" style="margin-top:4px;"><div class="progress-fill orange" :style="{ width: Math.min(item.company_score/30*100, 100)+'%' }"></div></div>
        </div>
        <div class="mb-sm">
          <div class="flex-between text-sm"><span>الممتحن (70%)</span><strong>{{ item.examiner_weighted }}</strong></div>
          <div class="progress" style="margin-top:4px;"><div class="progress-fill green" :style="{ width: Math.min(item.examiner_score/70*100, 100)+'%' }"></div></div>
        </div>
        <div style="text-align:center;padding:12px;background:var(--bg-body);border-radius:var(--radius-md);margin-top:8px;">
          <small class="text-muted">المعدل النهائي</small><br>
          <strong style="font-size:28px;color:var(--primary);">{{ item.final_percentage }}%</strong>
        </div>
      </div>
    </div>

    <!-- Detail Modal -->
    <div v-if="showDetail" class="modal-overlay" @click.self="showDetail = false">
      <div class="modal-card" style="max-width:640px;max-height:85vh;overflow-y:auto;">
        <div v-if="detailLoading" class="loading" style="padding:40px;">جاري التحميل...</div>
        <template v-else-if="detail">
          <h2 style="margin-bottom:4px;">تفاصيل التقييم</h2>
          <p class="text-muted text-sm" style="margin-bottom:18px;">{{ detail.student.name }} — {{ detail.company.name }}</p>

          <!-- Company Evaluation -->
          <div style="margin-bottom:20px;">
            <h3 style="margin-bottom:10px;font-size:15px;"><i class="ri-building-line"></i> تقييم الشركة (30%)</h3>
            <template v-if="detail.company_evaluation">
              <div v-if="detail.company_evaluation.detailed_scores && detail.company_evaluation.detailed_scores.length">
                <div v-for="(score, idx) in detail.company_evaluation.detailed_scores" :key="idx" style="display:flex;justify-content:space-between;padding:6px 0;border-bottom:1px solid var(--border-light);">
                  <span class="text-sm">{{ score.label || score.criterion || `معيار ${idx+1}` }}</span>
                  <strong class="text-sm">{{ score.score ?? score.value ?? '--' }}</strong>
                </div>
              </div>
              <div style="margin-top:8px;padding:10px;background:var(--bg-body);border-radius:var(--radius-sm);text-align:center;">
                <small class="text-muted">المجموع</small><br>
                <strong style="font-size:20px;color:var(--warning);">{{ detail.company_evaluation.total_score }}</strong>
              </div>
              <p v-if="detail.company_evaluation.evaluator_name" class="text-muted text-sm" style="margin-top:6px;">المقيّم: {{ detail.company_evaluation.evaluator_name }}</p>
            </template>
            <p v-else class="text-muted text-sm">لا يوجد تقييم من الشركة بعد.</p>
          </div>

          <!-- Examiner Evaluations -->
          <div style="margin-bottom:20px;">
            <h3 style="margin-bottom:10px;font-size:15px;"><i class="ri-user-star-line"></i> تقييم الممتحن (70%)</h3>
            <template v-if="detail.examiner_evaluations && detail.examiner_evaluations.length">
              <div v-for="ev in detail.examiner_evaluations" :key="ev.id" style="margin-bottom:14px;padding:12px;border:1px solid var(--border);border-radius:var(--radius-md);">
                <div style="display:flex;justify-content:space-between;margin-bottom:8px;">
                  <strong>{{ ev.examiner_name || 'ممتحن' }}</strong>
                  <span class="badge badge-active">{{ ev.total_score }}/70</span>
                </div>
                <div v-if="ev.rubric_scores">
                  <div v-for="(scores, category) in ev.rubric_scores" :key="category" style="margin-bottom:6px;">
                    <div class="text-sm" style="font-weight:600;margin-bottom:2px;">{{ rubricLabels[category] || category }}</div>
                    <div v-if="Array.isArray(scores)" style="display:flex;gap:6px;flex-wrap:wrap;">
                      <span v-for="(s, si) in scores" :key="si" class="text-sm" style="background:var(--primary-bg);padding:2px 8px;border-radius:12px;">{{ s }}</span>
                    </div>
                    <span v-else class="text-sm">{{ scores }}</span>
                  </div>
                </div>
                <p v-if="ev.notes" class="text-sm text-muted" style="margin-top:8px;"><strong>ملاحظات:</strong> {{ ev.notes }}</p>
                <p v-if="ev.decision" class="text-sm" style="margin-top:4px;"><strong>القرار:</strong> {{ ev.decision }}</p>
              </div>
            </template>
            <p v-else class="text-muted text-sm">لا يوجد تقييم من الممتحن بعد.</p>
          </div>

          <!-- Final Score -->
          <div style="text-align:center;padding:16px;background:var(--primary-bg);border-radius:var(--radius-md);">
            <small class="text-muted">المعدل النهائي</small><br>
            <strong style="font-size:32px;color:var(--primary);">{{ Math.round(detail.final_score) }}%</strong>
            <div class="text-sm text-muted" style="margin-top:4px;">
              الشركة: {{ detail.company_weighted }} | الممتحن: {{ detail.examiner_weighted }}
            </div>
          </div>

          <div style="text-align:left;margin-top:16px;">
            <button class="btn btn-secondary" @click="showDetail = false">إغلاق</button>
          </div>
        </template>
        <div v-else class="text-muted" style="padding:40px;text-align:center;">تعذر تحميل التفاصيل.</div>
      </div>
    </div>
  </div>
</template>
