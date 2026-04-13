<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const students = ref([])
const loading = ref(true)
const search = ref('')
const specFilter = ref('')

// دالة التحميل من السيرفر
async function load() {
  loading.value = true
  try {
    const { data } = await api.get('/students')
    students.value = data.data || []
  } catch (error) {
    console.error('Error fetching students:', error)
  } finally {
    loading.value = false
  }
}

// فلترة البيانات محلياً (أو يمكنك الاعتماد على البحث من السيرفر كما في كودك الأصلي)
const filteredStudents = computed(() => {
  return students.value.filter(s => {
    const matchesSearch = !search.value || 
                          s.name.toLowerCase().includes(search.value.toLowerCase()) || 
                          (s.student_number && s.student_number.includes(search.value))
    const matchesSpec = !specFilter.value || s.specialization === specFilter.value
    return matchesSearch && matchesSpec
  })
})

async function toggleStatus(id) {
  if (!confirm('هل أنت متأكد من تغيير حالة هذا الحساب؟')) return
  try {
    const { data } = await api.put(`/students/${id}/toggle-status`)
    const student = students.value.find(s => s.id === id)
    if (student) student.status = data.data.status
  } catch (e) {
    alert(e.response?.data?.message || 'حدث خطأ أثناء تغيير حالة الحساب')
  }
}

async function changePassword(id) {
  const pw = prompt('كلمة المرور الجديدة (8 أحرف على الأقل):')
  if (!pw || pw.length < 8) return
  try {
    await api.put(`/students/${id}/password`, { password: pw, password_confirmation: pw })
    alert('تم تغيير كلمة المرور بنجاح')
  } catch (e) {
    alert('حدث خطأ أثناء تغيير كلمة المرور')
  }
}

onMounted(load)
</script>

<template>
  <div class="page-container">
    <div class="top-header">
      <div class="header-info">
        <h1 class="page-title">إدارة حسابات الطلاب</h1>
        <p class="page-subtitle">إدارة صلاحيات وصول الطلاب ومتابعة حالات حساباتهم الدراسية</p>
      </div>
    </div>

    <div class="actions-bar">
      <div class="search-wrapper">
        <i class="ri-search-line"></i>
        <input 
          type="text" 
          v-model="search" 
          placeholder="بحث بالاسم أو رقم القيد..." 
        >
      </div>

      <select v-model="specFilter" class="filter-select">
        <option value="">كل التخصصات</option>
        <option value="حاسب آلي">حاسب آلي</option>
        <option value="اتصالات">اتصالات</option>
        <option value="تحكم">تحكم</option>
      </select>
    </div>

    <div class="main-card">
      <SkeletonLoader v-if="loading" type="table" :columns="5" />
      
      <div v-else-if="filteredStudents.length === 0" class="empty-state">
        <i class="ri-user-search-line"></i>
        <p>لا يوجد طلاب يطابقون معايير البحث</p>
      </div>

      <div v-else class="table-responsive">
        <table class="custom-table">
          <thead>
            <tr>
              <th>الطالب</th>
              <th>رقم القيد</th>
              <th>التخصص</th>
              <th>الحالة</th>
              <th>الإجراءات</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="s in filteredStudents" :key="s.id">
              <td>
                <div class="student-cell">
                  <div class="user-avatar">
                    {{ s.name.charAt(0) }}
                  </div>
                  <span class="student-name">{{ s.name }}</span>
                </div>
              </td>
              <td class="text-mono">{{ s.student_number || '--' }}</td>
              <td>
                <span v-if="s.specialization" class="badge-spec">
                  {{ s.specialization }}
                </span>
                <span v-else>--</span>
              </td>
              <td>
                <span :class="['status-badge', s.status === 'active' ? 'active' : 'inactive']">
                  {{ s.status === 'active' ? 'نشط' : 'موقف' }}
                </span>
              </td>
              <td>
                <div class="actions-buttons">
                  <button class="btn-icon" @click="changePassword(s.id)" title="تغيير كلمة المرور">
                    <i class="ri-lock-password-line"></i>
                  </button>
                  <button 
                    class="btn-status-toggle" 
                    :class="s.status === 'active' ? 'btn-stop' : 'btn-start'"
                    @click="toggleStatus(s.id)"
                  >
                    {{ s.status === 'active' ? 'إيقاف' : 'تفعيل' }}
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page-container {
  padding: 25px;
  direction: rtl;
}

/* الهيدر العلوي */
.top-header {
  display: flex;
  justify-content: flex-start;
  align-items: center;
  margin-bottom: 30px;
}

.page-title {
  font-size: 24px;
  font-weight: 900;
  color: #1e293b;
  margin: 0;
}

.page-subtitle {
  color: #64748b;
  font-size: 14px;
  margin-top: 5px;
}

/* شريط البحث والفلترة */
.actions-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 25px;
}

.search-wrapper {
  position: relative;
  flex: 1;
  max-width: 320px;
}

.search-wrapper i {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #94a3b8;
}

.search-wrapper input {
  width: 100%;
  padding: 10px 40px 10px 15px;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  background: white;
  outline: none;
}

.filter-select {
  padding: 10px 15px;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  background: white;
  color: #64748b;
  min-width: 160px;
  cursor: pointer;
  outline: none;
}

/* الكارد والجدول */
.main-card {
  background: white;
  border-radius: 20px;
  padding: 10px;
  border: 1px solid #f1f5f9;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
}

.custom-table {
  width: 100%;
  border-collapse: collapse;
  text-align: right;
}

.custom-table th {
  padding: 15px;
  background: #f8fafc;
  color: #64748b;
  font-weight: 700;
  font-size: 13px;
  border-bottom: 1px solid #f1f5f9;
}

.custom-table td {
  padding: 15px;
  border-bottom: 1px solid #f1f5f9;
  color: #334155;
  font-size: 14px;
}

/* عناصر الجدول */
.student-cell {
  display: flex;
  align-items: center;
  gap: 10px;
}

.user-avatar {
  width: 35px;
  height: 35px;
  background: #f1f0ff;
  color: #6a5ae0;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.student-name {
  font-weight: 700;
}

.badge-spec {
  background: #f1f0ff;
  color: #6a5ae0;
  padding: 4px 10px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
}

/* شارات الحالة */
.status-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
}
.status-badge.active { background: #f0fdf4; color: #15803d; }
.status-badge.inactive { background: #fef2f2; color: #b91c1c; }

/* الأزرار */
.actions-buttons {
  display: flex;
  gap: 8px;
}

.btn-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  background: white;
  color: #64748b;
  cursor: pointer;
}

.btn-status-toggle {
  padding: 6px 15px;
  border-radius: 8px;
  border: none;
  font-weight: 600;
  font-size: 12px;
  cursor: pointer;
}

.btn-stop { background: #fee2e2; color: #ef4444; }
.btn-start { background: #dcfce7; color: #22c55e; }

.loading-state, .empty-state {
  padding: 50px;
  text-align: center;
  color: #94a3b8;
}
</style>