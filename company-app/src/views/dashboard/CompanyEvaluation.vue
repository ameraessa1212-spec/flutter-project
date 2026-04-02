<template>
  <div class="evaluation-page">
    <div class="glass-background">
      <div class="glow-sphere s1"></div>
      <div class="glow-sphere s2"></div>
    </div>

    <div class="evaluation-container reveal">
      <header class="eval-header animate-fade">
        <div class="college-brand">
          <div>
            <h1>كلية التقنية الإلكترونية - طرابلس</h1>
            <p>نموذج تقييم أداء الطالب بجهة التدريب (تعبئة المشرف)</p>
          </div>
        </div>
        <div class="doc-info">
          <small>الفصل الدراسي: خريف 2025</small>
        </div>
      </header>

      <div class="student-meta-grid animate-fade delay-1">
        <div class="meta-item">
          <strong>اسم الطالب:</strong>
          <select v-model="selectedInternship">
            <option value="">-- اختر الطالب --</option>
            <option v-for="intern in internships" :key="intern.id" :value="intern.id">
              {{ intern.student?.name || ('طالب ' + intern.id) }}
            </option>
          </select>
        </div>
        <div class="meta-item"><strong>رقم القيد:</strong> <input type="text" placeholder="000000" disabled :value="selectedInternData?.student?.student_profile?.student_number || ''"></div>
        <div class="meta-item"><strong>جهة التدريب:</strong> <input type="text" placeholder="اسم الشركة" disabled :value="companyProfile?.name || ''"></div>
        <div class="meta-item"><strong>المشرف:</strong> <input type="text" placeholder="اسم المشرف المباشر" disabled :value="userProfile?.name || ''"></div>
        <div class="meta-item date-box"><strong>تاريخ بداية التدريب:</strong> <input type="date" disabled :value="selectedInternData?.start_date || ''"></div>
        <div class="meta-item date-box"><strong>تاريخ نهاية التدريب:</strong> <input type="date" disabled :value="selectedInternData?.end_date || ''"></div>
      </div>

      <div class="full-table-wrapper">
        <!-- Domain 1: Knowledge (35 points) -->
        <div class="domain-section animate-slide delay-2">
          <div class="domain-header purple">1. المجال المعرفي (35 درجة)</div>
          <div class="criteria-row" v-for="(item, idx) in domain1" :key="'d1-'+idx">
            <span class="c-num">{{ idx + 1 }}</span>
            <p class="c-text">{{ item.text }}</p>
            <div class="c-input-wrapper">
              <input type="number" class="grade-input" :data-max="item.max" placeholder="0" v-model.number="grades[item.index]" @input="validateGrade(item.index, item.max)">
              <small>/ {{ item.max }}</small>
            </div>
          </div>
        </div>

        <!-- Domain 2: Professional (35 points) -->
        <div class="domain-section animate-slide delay-3">
          <div class="domain-header orange">2. المجال المهني (35 درجة)</div>
          <div class="criteria-row" v-for="(item, idx) in domain2" :key="'d2-'+idx">
            <span class="c-num">{{ idx + 1 }}</span>
            <p class="c-text">{{ item.text }}</p>
            <div class="c-input-wrapper">
              <input type="number" class="grade-input" :data-max="item.max" placeholder="0" v-model.number="grades[item.index]" @input="validateGrade(item.index, item.max)">
              <small>/ {{ item.max }}</small>
            </div>
          </div>
        </div>

        <!-- Domain 3: Skills (30 points) -->
        <div class="domain-section animate-slide delay-4">
          <div class="domain-header green">3. مجال القدرات والمهارات (30 درجة)</div>
          <div class="criteria-row" v-for="(item, idx) in domain3" :key="'d3-'+idx">
            <span class="c-num">{{ idx + 1 }}</span>
            <p class="c-text">{{ item.text }}</p>
            <div class="c-input-wrapper">
              <input type="number" class="grade-input" :data-max="item.max" placeholder="0" v-model.number="grades[item.index]" @input="validateGrade(item.index, item.max)">
              <small>/ {{ item.max }}</small>
            </div>
          </div>
        </div>
      </div>

      <section class="notes-section animate-fade delay-5">
        <div class="section-banner grey"><i class="ri-edit-2-line"></i> <span>ملاحظات المشرف المباشر (إلزامي)</span></div>
        <textarea v-model="supervisorNotes" class="notes-area" placeholder="اكتب تقييماً مختصراً لأداء الطالب خلال فترة التدريب..."></textarea>
      </section>

      <footer class="eval-footer animate-fade delay-6">
        <div class="total-result">
          <div class="total-text">
            <h3>إجمالي درجة التقييم</h3>
            <p>يتم احتساب المجموع  من 100 درجة</p>
          </div>
          <div class="total-circle pulse-animation"><span>{{ totalScore }}</span><small>%</small></div>
        </div>
        <div class="action-buttons">
          <button class="btn-print" @click="printPage"><i class="ri-printer-line"></i> حفظ PDF</button>
          <button class="btn-send" @click="submitEvaluation"><i class="ri-checkbox-circle-line"></i> اعتماد وإرسال التقييم</button>
        </div>
      </footer>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, inject } from 'vue'
import { apiFetch } from '../../api'

const refreshDashboard = inject('refreshDashboard')

const internships = ref([])
const selectedInternship = ref('')
const companyProfile = ref(null)
const userProfile = ref(null)
const supervisorNotes = ref('')

// 16 grade inputs: 5 (domain1) + 6 (domain2) + 5 (domain3)
const grades = reactive(new Array(16).fill(0))

const domain1 = [
  { text: 'مدى المعرفة بالأنشطة التخصصية المختلفة في بيئة العمل.', max: 7, index: 0 },
  { text: 'مدى المعرفة بالنظام المؤسسي وقوانين وأخلاقيات العمل.', max: 7, index: 1 },
  { text: 'القدرة على توظيف المعرفة النظرية والتقنية في التدريب.', max: 7, index: 2 },
  { text: 'التعرف على تقنيات تخصصية جديدة أثناء التدريب.', max: 7, index: 3 },
  { text: 'مدى المعرفة بسوق العمل في مجال التخصص.', max: 7, index: 4 },
]

const domain2 = [
  { text: 'جودة الأداء المهني في بيئة العمل.', max: 6, index: 5 },
  { text: 'الالتزام بالقوانين وأخلاقيات المهنة.', max: 6, index: 6 },
  { text: 'الالتزام بمواعيد العمل.', max: 6, index: 7 },
  { text: 'تقبل النقد والتوجيه.', max: 6, index: 8 },
  { text: 'العلاقة مع الرؤساء والزملاء والعملاء.', max: 6, index: 9 },
  { text: 'إبراز الشخصية الهندسية في بيئة العمل.', max: 5, index: 10 },
]

const domain3 = [
  { text: 'القدرة على التعلم الذاتي وتحصيل المعرفة.', max: 6, index: 11 },
  { text: 'القدرة على الاتصال الفعال والحوار البناء.', max: 6, index: 12 },
  { text: 'القدرة على تقديم العروض المرئية والمناقشة.', max: 6, index: 13 },
  { text: 'جودة الأعمال الموثقة (المقترحات والتقارير).', max: 6, index: 14 },
  { text: 'جودة الأداء في العمل الجماعي ضمن فريق.', max: 6, index: 15 },
]

const totalScore = computed(() => {
  return Math.round(grades.reduce((sum, g) => sum + (g || 0), 0))
})

const selectedInternData = computed(() => {
  if (!selectedInternship.value) return null
  return internships.value.find(i => i.id == selectedInternship.value) || null
})

function validateGrade(index, max) {
  if (grades[index] > max) {
    alert(`القيمة العظمى لهذا البند هي ${max}`)
    grades[index] = max
  }
  if (grades[index] < 0) {
    grades[index] = 0
  }
}

function printPage() {
  window.print()
}

async function loadInternships() {
  const response = await apiFetch('/company/internships?status=active')
  if (response.ok) {
    internships.value = await response.json()
  }
}

onMounted(async () => {
  try {
    const prof = localStorage.getItem('company_profile')
    const usr = localStorage.getItem('company_user')
    if (prof) companyProfile.value = JSON.parse(prof)
    if (usr) userProfile.value = JSON.parse(usr)

    await loadInternships()
  } catch (e) {
    console.error('Failed to load internships', e)
  }
})

async function submitEvaluation() {
  if (!selectedInternship.value) {
    alert('الرجاء اختيار الطالب من القائمة')
    return
  }

  const detailedScores = [...grades]

  if (confirm(`هل أنت متأكد من اعتماد التقييم بمجموع ${totalScore.value}؟`)) {
    try {
      const response = await apiFetch('/company/evaluations', {
        method: 'POST',
        body: JSON.stringify({
          internship_id: parseInt(selectedInternship.value),
          detailed_scores: detailedScores,
          total_score: totalScore.value,
          comments: supervisorNotes.value
        })
      })

      if (response.ok) {
        alert('تم إرسال التقييم بنجاح.')
        await loadInternships()
        selectedInternship.value = ''
        grades.fill(0)
        supervisorNotes.value = ''
        if (refreshDashboard) refreshDashboard()
      } else {
        const errData = await response.json().catch(() => ({}))
        alert('خطأ: ' + (errData.message || 'حدث خطأ أثناء الإرسال.'))
      }
    } catch (e) {
      alert('خطأ في الاتصال بالخادم.')
    }
  }
}
</script>

<style scoped>
:root {
    --primary: #6A5AE0;
    --orange: #FF9F43;
    --green: #2ecc71;
    --dark: #2d3436;
    --border: #f0f0f5;
    --primary-light: #f0eeff;
    --shadow: 0 10px 30px rgba(106, 90, 224, 0.1);
}

.evaluation-page {
    font-family: 'Cairo', sans-serif;
    direction: rtl;
    padding: 20px;
    overflow-x: hidden;
    position: relative;
}

.glass-background { position: fixed; inset: 0; z-index: -1; }
.glow-sphere { position: absolute; border-radius: 50%; filter: blur(100px); opacity: 0.15; }
.s1 { width: 500px; height: 500px; background: #6A5AE0; top: -100px; left: -100px; }
.s2 { width: 400px; height: 400px; background: #FF9F43; bottom: -100px; right: -50px; }

.evaluation-container { max-width: 900px; margin: auto; background: white; padding: 35px; border-radius: 40px; box-shadow: 0 20px 60px rgba(0,0,0,0.05); }

.eval-header { margin-bottom: 20px; }
.eval-header h1 { font-size: 18px; margin: 0; }
.eval-header p { font-size: 13px; color: #666; margin: 0; }

.student-meta-grid {
    display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px;
    background: #f8f9ff; padding: 20px; border-radius: 25px; margin-bottom: 30px;
}
.meta-item { font-size: 14px; }
.meta-item input, .meta-item select {
    border: 1px solid #ccc; padding: 5px; border-radius: 5px; width: 150px;
    background: transparent; font-family: 'Cairo'; color: #6A5AE0; font-weight: bold; outline: none;
}
.meta-item input[disabled] {
    border: none; border-bottom: 1px dashed #ccc;
}

.criteria-row { display: flex; align-items: center; padding: 12px 20px; border-bottom: 1px solid #f0f0f5; }
.c-num { font-weight: 800; color: #999; margin-left: 10px; min-width: 20px; }
.c-text { flex: 1; font-size: 14px; color: #444; }
.c-input-wrapper { display: flex; align-items: center; gap: 5px; font-weight: 800; color: #6A5AE0; }

.grade-input {
    width: 50px; padding: 8px; border-radius: 10px; border: 2px solid #f0eeff;
    text-align: center; font-family: 'Cairo'; font-weight: 800; color: #6A5AE0; outline: none;
}
.grade-input:focus { border-color: #6A5AE0; background: #f0eeff; }

.domain-header { padding: 12px 20px; font-weight: 700; border-radius: 15px 15px 0 0; }
.purple { background: #eeeaff; color: #6A5AE0; }
.orange { background: #fff4e8; color: #FF9F43; }
.green { background: #e8f7f0; color: #2ecc71; }

.domain-section { margin-bottom: 20px; }

.notes-area {
    width: 100%; min-height: 100px; padding: 15px; border-radius: 15px;
    border: 2px dashed #ddd; font-family: 'Cairo'; margin-top: 10px; outline: none;
    box-sizing: border-box;
}

.section-banner { padding: 10px 15px; font-weight: 700; display: flex; align-items: center; gap: 8px; }

.total-result {
    background: linear-gradient(135deg, #6A5AE0, #8e84f3); padding: 25px; border-radius: 25px;
    color: white; display: flex; justify-content: space-between; align-items: center; margin-top: 30px;
}
.total-circle {
    width: 80px; height: 80px; background: rgba(255,255,255,0.2); border: 2px solid white;
    border-radius: 50%; display: flex; flex-direction: column; align-items: center;
    justify-content: center; font-size: 28px; font-weight: 800;
}

.action-buttons { display: flex; gap: 15px; margin-top: 25px; justify-content: flex-end; }
.action-buttons button {
    padding: 12px 25px; border-radius: 12px; border: none; font-family: 'Cairo';
    font-weight: 700; cursor: pointer; display: flex; align-items: center; gap: 8px;
}
.btn-print { background: #f0f0f5; color: #555; }
.btn-send { background: #2d3436; color: white; }

.animate-fade { animation: fadeIn 0.6s ease forwards; }
.animate-slide { animation: slideIn 0.6s ease forwards; }
.delay-1 { animation-delay: 0.1s; }
.delay-2 { animation-delay: 0.2s; }
.delay-3 { animation-delay: 0.3s; }
.delay-4 { animation-delay: 0.4s; }
.delay-5 { animation-delay: 0.5s; }
.delay-6 { animation-delay: 0.6s; }

@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
@keyframes slideIn { from { opacity: 0; transform: translateX(-20px); } to { opacity: 1; transform: translateX(0); } }

@media print {
    .action-buttons, .glass-background { display: none; }
    .evaluation-page { padding: 0; }
    .evaluation-container { box-shadow: none; border: none; width: 100%; }
}
</style>
