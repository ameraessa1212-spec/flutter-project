<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const reports = ref([])
const loading = ref(true)
const search = ref('')
const status = ref('')

// 1. دالة تجميع الملفات حسب الطالب لضمان ظهور كارد واحد لكل طالب
const groupedStudents = computed(() => {
  const groups = {}
  reports.value.forEach(report => {
    const studentId = report.student?.student_number || report.student?.id 
    if (!groups[studentId]) {
      groups[studentId] = {
        student: report.student,
        files: [],
        _notifying: false // حالة التحميل الخاصة بالكارد بالكامل
      }
    }
    groups[studentId].files.push(report)
  })
  return Object.values(groups)
})

async function load() {
  loading.value = true
  const params = {}
  if (search.value) params.search = search.value
  if (status.value) params.status = status.value
  try {
    const { data } = await api.get('/student-reports', { params })
    reports.value = data.data || []
  } catch (error) {
    reports.value = []
  }
  loading.value = false
}

function onSearch(val) { search.value = val; load() }
function onStatus(val) { status.value = val; load() }

// 2. إصلاح دالة الإبلاغ لتحديث الحالة في المصفوفة الأصلية ليعمل الـ Computed بشكل صحيح
async function notify(group) {
  const firstFile = group.files[0]
  if (!firstFile || group.files.every(f => f._notified)) return

  group._notifying = true 
  
  try {
    // إرسال طلب الإبلاغ للملف الأساسي
    await api.post(`/student-reports/${firstFile.id}/notify`)
    
    // تحديث حالة 'تم الإبلاغ' لجميع ملفات هذا الطالب في المصفوفة الأصلية
    reports.value.forEach(report => {
      const reportStudentId = report.student?.student_number || report.student?.id
      const groupStudentId = group.student?.student_number || group.student?.id
      if (reportStudentId === groupStudentId) {
        report._notified = true
      }
    })
  } catch (error) {
    console.error("خطأ في عملية الإبلاغ:", error)
  } finally {
    group._notifying = false
  }
}

onMounted(load)
</script>

<template>
  <div class="reports-page">
    <PageHeader 
      title="تقارير الطلاب" 
      show-search 
      show-status-filter 
      search-placeholder="ابحث باسم الطالب..." 
      :status-options="[{value:'submitted',label:'مرسل'},{value:'reviewed',label:'مراجع'}]" 
      @search="onSearch" 
      @status-filter="onStatus" 
    />

    <SkeletonLoader v-if="loading" type="cards" :card-count="6" />
    
    <div v-else-if="!groupedStudents.length" class="empty-state">لا توجد تقارير حالياً</div>

    <div v-else class="grid-3">
      <div v-for="group in groupedStudents" :key="group.student.id" class="student-glass-card">
        
        <div class="card-top-section">
          <div class="student-info-main">
            <h3 class="student-name-text">{{ group.student?.name }}</h3>
            <span class="student-id-sub">رقم القيد: {{ group.student?.student_number }}</span>
          </div>
          <div class="avatar-icon-box">
            <i class="ri-user-received-2-line"></i>
          </div>
        </div>

        <div class="files-container-list">
          <div v-for="file in group.files" :key="file.id" class="file-item-glass">
            <div class="file-content-inner">
              <div class="file-text-details">
                <span class="file-type-title">{{ file.report_type === 'scientific_research' ? 'البحث العلمي' : 'التدريب الميداني' }}</span>
                <span class="file-receive-date">استلم: {{ file.submitted_at ? new Date(file.submitted_at).toLocaleDateString('ar-LY') : '--' }}</span>
              </div>
              <div class="file-icon-status" :class="file.report_type">
                <i :class="file.report_type === 'scientific_research' ? 'ri-microscope-line' : 'ri-building-line'"></i>
              </div>
            </div>
            <a v-if="file.download_url" :href="file.download_url" target="_blank" class="download-mini-btn">
              <i class="ri-download-2-line"></i>
            </a>
          </div>
        </div>

        <button 
          class="btn-notify-full" 
          :class="{ 'is-notified': group.files.every(f => f._notified) }"
          :disabled="group._notifying || group.files.every(f => f._notified)" 
          @click="notify(group)"
        >
          <template v-if="group._notifying">
            <i class="ri-loader-4-line spin"></i> جاري الإرسال...
          </template>
          <template v-else-if="group.files.every(f => f._notified)">
            <i class="ri-checkbox-circle-fill"></i> تم إبلاغ الطالب بالاستلام
          </template>
          <template v-else>
            <i class="ri-send-plane-fill"></i> إبلاغ الطالب بالاستلام
          </template>
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* التنسيقات العصرية المطابقة للصورة */
.reports-page { padding: 20px; }
.grid-3 { 
  display: grid; 
  /* تم تغيير 1fr إلى 320px لجعل الكارد لا يتمدد بشكل مبالغ فيه */
  grid-template-columns: repeat(auto-fill, minmax(280px, 320px)); 
  gap: 20px; 
 
  margin-top: 20px; 
}

.student-glass-card {
  background: white;
  border-radius: 40px;
  padding: 30px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.05);
  border: 1px solid #f0f0f5;
  display: flex;
  flex-direction: column;
  gap: 20px;
  transition: transform 0.3s ease;
}

.student-glass-card:hover { transform: translateY(-5px); }

.card-top-section { display: flex; justify-content: flex-end; align-items: center; gap: 15px; }
.student-info-main { text-align: right; }
.student-name-text { margin: 0; font-size: 20px; font-weight: 800; color: #333; }
.student-id-sub { color: #999; font-size: 13px; }

.avatar-icon-box {
  width: 55px; height: 55px; background: #6c5ce7; border-radius: 18px;
  display: flex; align-items: center; justify-content: center; color: white; font-size: 24px;
}

.file-item-glass {
  background: #ffffff; border: 1px solid #f3f3f9; border-radius: 22px;
  padding: 12px 18px; margin-bottom: 10px; display: flex; justify-content: space-between; align-items: center;
}

.file-content-inner { display: flex; align-items: center; gap: 12px; flex-direction: row-reverse; }
.file-text-details { text-align: right; }
.file-type-title { display: block; font-weight: 700; font-size: 16px; color: #444; }
.file-receive-date { font-size: 11px; color: #bbb; }

.file-icon-status.scientific_research { color: #00cec9; }
.file-icon-status.field_training { color: #e17055; }

.download-mini-btn {
  width: 32px; height: 32px; background: #f8f9fb; border-radius: 8px;
  display: flex; align-items: center; justify-content: center; color: #aaa; text-decoration: none;
}

.btn-notify-full {
  width: 100%; padding: 16px; background: #6c5ce7; color: white; border: none;
  border-radius: 22px; font-family: 'Cairo', sans-serif; font-weight: 700; font-size: 15px;
  display: flex; align-items: center; justify-content: center; gap: 8px; cursor: pointer;
  box-shadow: 0 8px 20px rgba(108, 92, 231, 0.25); transition: 0.3s;
}

.btn-notify-full.is-notified {
  background: #2ed573; box-shadow: 0 8px 20px rgba(46, 213, 115, 0.2); cursor: default;
}

.spin { animation: rotate 1s linear infinite; }
@keyframes rotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

.empty-state { text-align: center; padding: 60px; color: #999; font-size: 18px; }
</style>