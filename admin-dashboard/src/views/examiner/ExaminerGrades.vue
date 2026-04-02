<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'

const students = ref([])
const loading = ref(true)
const modal = ref(false)
const current = ref(null)
const scores = ref({})
const decision = ref('pass')
const total = computed(() => Object.values(scores.value).reduce((a, b) => a + (Number(b) || 0), 0))

const fields = [
  { group: 'المجال المعرفي (15)', items: ['knowledge_1','knowledge_2','knowledge_3','knowledge_4','knowledge_5'], max: 3 },
  { group: 'القدرات والمهارات (10)', items: ['skills_1','skills_2','skills_3','skills_4'], max: 3 },
  { group: 'التوثيق (15)', items: ['doc_1','doc_2','doc_3','doc_4'], max: 4 },
  { group: 'المناقشة (15)', items: ['disc_1','disc_2','disc_3'], max: 5 },
  { group: 'البحث العلمي (15)', items: ['research_1','research_2','research_3','research_4','research_5'], max: 4 },
]

onMounted(async () => {
  const { data } = await api.get('/examiner/students').catch(() => ({ data: { data: [] } }))
  students.value = data.data || []
  loading.value = false
})

function openGrade(s) {
  current.value = s; scores.value = {}; decision.value = 'pass'; modal.value = true
}

function validateScores() {
  for (const f of fields) {
    for (const key of f.items) {
      const v = scores.value[key]
      if (v === undefined || v === null || v === '') return 'يرجى تعبئة جميع الدرجات'
      if (v < 0) return `الدرجة لا يمكن أن تكون سالبة`
      if (v > f.max) return `الحد الأقصى للدرجة هو ${f.max}`
    }
  }
  if (total.value > 70) return 'المجموع لا يمكن أن يتجاوز 70'
  return null
}

async function submitGrade() {
  const err = validateScores()
  if (err) return alert(err)
  await api.post('/examiner/grades', {
    examiner_discussion_id: current.value.id,
    rubric_scores: scores.value,
    total_score: total.value,
    decision: decision.value,
  })
  const s = students.value.find(x => x.id === current.value.id)
  if (s) s.status = `تم التقييم (${total.value}/70)`
  modal.value = false
  alert(`تم الحفظ: ${total.value}/70`)
}
</script>

<template>
  <div>
    <h1 class="page-title">نتائج التقييم</h1>
    <div v-if="loading" class="loading">جاري التحميل...</div>
    <div v-else-if="!students.length" class="empty">لا يوجد طلاب</div>
    <table v-else class="table">
      <thead><tr><th>الطالب</th><th>رقم القيد</th><th>الحالة</th><th>الإجراء</th></tr></thead>
      <tbody>
        <tr v-for="s in students" :key="s.id">
          <td><strong>{{ s.student_name }}</strong></td>
          <td>{{ s.student_number || '--' }}</td>
          <td><span class="badge badge-purple">{{ s.status }}</span></td>
          <td><button class="btn btn-sm btn-primary" @click="openGrade(s)">رصد الدرجات</button></td>
        </tr>
      </tbody>
    </table>

    <!-- Grade Modal -->
    <div v-if="modal" class="modal-backdrop" @click.self="modal = false">
      <div class="modal-box" style="max-width:600px;">
        <div class="modal-header"><h3>تقييم: {{ current?.student_name }}</h3><button class="modal-close" @click="modal = false">&times;</button></div>
        <form @submit.prevent="submitGrade">
          <div v-for="f in fields" :key="f.group" style="border:1px solid #f0f0f0;border-radius:10px;padding:12px;margin-bottom:10px;">
            <strong style="font-size:14px;">{{ f.group }}</strong>
            <div style="display:flex;flex-wrap:wrap;gap:8px;margin-top:8px;">
              <input v-for="key in f.items" :key="key" v-model.number="scores[key]" type="number" min="0" :max="f.max" :placeholder="`(${f.max})`"
                style="width:55px;padding:8px;border:1px solid #ddd;border-radius:8px;text-align:center;font-family:Cairo;">
            </div>
          </div>
          <div style="margin-top:12px;">
            <strong style="font-size:14px;">القرار</strong>
            <select v-model="decision" style="width:100%;padding:10px;border:1px solid #ddd;border-radius:8px;margin-top:6px;font-family:Cairo;">
              <option value="pass">ناجح</option>
              <option value="fail">راسب</option>
              <option value="conditional_pass">ناجح مشروط</option>
            </select>
          </div>
          <div style="display:flex;justify-content:space-between;align-items:center;margin-top:15px;">
            <span style="font-size:18px;font-weight:700;">المجموع: <span style="color:#6A5AE0;">{{ total }}</span>/70</span>
            <button type="submit" class="btn btn-primary">حفظ التقييم</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
