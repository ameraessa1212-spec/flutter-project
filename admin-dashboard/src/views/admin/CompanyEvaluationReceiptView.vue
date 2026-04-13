<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api } from '../../composables/useApi'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const route = useRoute()
const router = useRouter()
const data = ref(null)
const loading = ref(true)

onMounted(async () => {
  try {
    const res = await api.get(`/student-evaluations/${route.params.id}`)
    data.value = res.data.data
  } catch (_) {}
  loading.value = false
})

function printReceipt() {
  window.print()
}

const criteriaLabels = [
  'المعرفة بالأنشطة التخصصية',
  'المعرفة بالنظام المؤسسي وقوانين العمل',
  'توظيف المعرفة النظرية والتقنية',
  'التعرف على تقنيات تخصصية جديدة',
  'المعرفة بسوق العمل',
  'جودة الأداء المهني',
  'الالتزام بالقوانين وأخلاقيات المهنة',
  'الالتزام بمواعيد العمل',
  'تقبل النقد والتوجيه',
  'العلاقة مع الرؤساء والزملاء',
  'إبراز الشخصية الهندسية',
  'القدرة على التعلم الذاتي',
  'القدرة على الاتصال الفعال',
  'القدرة على تقديم العروض المرئية',
  'جودة الأعمال الموثقة',
  'جودة الأداء في العمل الجماعي',
]
</script>

<template>
  <div>
    <div class="no-print" style="margin-bottom:20px;display:flex;gap:10px;">
      <button class="btn btn-secondary btn-sm" @click="router.push('/evaluation')">
        <i class="ri-arrow-right-line"></i> العودة
      </button>
      <button v-if="data" class="btn btn-primary btn-sm" @click="printReceipt">
        <i class="ri-printer-line"></i> طباعة الإيصال
      </button>
    </div>

    <SkeletonLoader v-if="loading" type="list" :rows="8" />
    <div v-else-if="!data" class="empty">تعذر تحميل بيانات التقييم</div>
    <template v-else>
      <div class="receipt-container">
        <!-- Header -->
        <div class="receipt-header">
          <h2>إيصال تقييم الشركة</h2>
          <p class="text-muted">تقييم أداء المتدرب من قبل جهة التدريب</p>
        </div>

        <!-- Student & Company Info -->
        <div class="info-grid">
          <div class="info-item"><span class="info-label">اسم الطالب</span><span class="info-value">{{ data.student?.name }}</span></div>
          <div class="info-item"><span class="info-label">رقم القيد</span><span class="info-value">{{ data.student?.student_number || '--' }}</span></div>
          <div class="info-item"><span class="info-label">التخصص</span><span class="info-value">{{ data.student?.specialization || '--' }}</span></div>
          <div class="info-item"><span class="info-label">جهة التدريب</span><span class="info-value">{{ data.company?.name }}</span></div>
        </div>

        <!-- Company Evaluation -->
        <div v-if="data.company_evaluation" class="receipt-section">
          <h3>تقييم الشركة (30%)</h3>
          <table class="receipt-table">
            <thead><tr><th>المعيار</th><th>الدرجة</th></tr></thead>
            <tbody>
              <tr v-for="(score, idx) in (data.company_evaluation.detailed_scores || [])" :key="idx">
                <td>{{ criteriaLabels[idx] || `معيار ${idx + 1}` }}</td>
                <td class="score-cell">{{ score }}</td>
              </tr>
              <tr class="total-row">
                <td><strong>المجموع</strong></td>
                <td class="score-cell"><strong>{{ data.company_evaluation.total_score }}</strong></td>
              </tr>
            </tbody>
          </table>
          <p v-if="data.company_evaluation.evaluator_name" class="text-sm text-muted" style="margin-top:8px;">المقيّم: {{ data.company_evaluation.evaluator_name }}</p>
          <p v-if="data.company_evaluation.created_at" class="text-sm text-muted">تاريخ التقييم: {{ new Date(data.company_evaluation.created_at).toLocaleDateString('ar-LY') }}</p>
        </div>
        <div v-else class="receipt-section">
          <h3>تقييم الشركة (30%)</h3>
          <div style="padding:24px;text-align:center;background:#fff7ed;border-radius:12px;border:1px dashed #c2410c;">
            <i class="ri-error-warning-line" style="font-size:32px;color:#c2410c;display:block;margin-bottom:8px;"></i>
            <p style="color:#c2410c;font-weight:600;margin:0;">لم يتم تقييم الطالب من قبل الشركة بعد</p>
            <p class="text-sm text-muted" style="margin-top:4px;">يجب أن تقوم الشركة بتعبئة نموذج التقييم من خلال لوحة تحكم الشركة</p>
          </div>
        </div>

        <!-- Examiner Evaluations -->
        <div v-if="data.examiner_evaluations?.length" class="receipt-section">
          <h3>تقييم الممتحن (70%)</h3>
          <div v-for="ev in data.examiner_evaluations" :key="ev.id" style="margin-bottom:16px;">
            <p class="text-sm"><strong>{{ ev.examiner_name || 'ممتحن' }}</strong> — الدرجة: {{ ev.total_score }}/70 — القرار: {{ ev.decision === 'pass' ? 'ناجح' : ev.decision === 'fail' ? 'راسب' : 'ناجح مشروط' }}</p>
          </div>
        </div>

        <!-- Final Score -->
        <div class="receipt-footer">
          <div class="final-score-box">
            <span class="text-sm text-muted">المعدل النهائي</span>
            <span class="final-score">{{ Math.round(data.final_score || data.final_percentage || 0) }}%</span>
            <span class="text-sm text-muted">الشركة: {{ data.company_weighted }} | الممتحن: {{ data.examiner_weighted }}</span>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.receipt-container {
  background: white;
  border-radius: 16px;
  padding: 40px;
  border: 1px solid #e2e8f0;
  max-width: 800px;
}

.receipt-header {
  text-align: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #6C5CE7;
}
.receipt-header h2 { color: #1e293b; margin: 0 0 6px; }

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-bottom: 30px;
  padding: 20px;
  background: #f8fafc;
  border-radius: 12px;
}
.info-item { display: flex; flex-direction: column; gap: 4px; }
.info-label { font-size: 12px; color: #64748b; font-weight: 600; }
.info-value { font-size: 15px; color: #1e293b; font-weight: 700; }

.receipt-section {
  margin-bottom: 24px;
}
.receipt-section h3 {
  font-size: 16px;
  color: #1e293b;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #e2e8f0;
}

.receipt-table {
  width: 100%;
  border-collapse: collapse;
}
.receipt-table th, .receipt-table td {
  padding: 10px 14px;
  text-align: right;
  border-bottom: 1px solid #f1f5f9;
  font-size: 14px;
}
.receipt-table th { background: #f8fafc; color: #64748b; font-weight: 700; }
.score-cell { text-align: center; font-weight: 600; }
.total-row { background: #f8fafc; }

.receipt-footer {
  margin-top: 30px;
  padding-top: 20px;
  border-top: 2px solid #6C5CE7;
  text-align: center;
}
.final-score-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}
.final-score {
  font-size: 40px;
  font-weight: 900;
  color: #6C5CE7;
}

@media print {
  .no-print { display: none !important; }
  .receipt-container { border: none; padding: 0; box-shadow: none; }
}
</style>
