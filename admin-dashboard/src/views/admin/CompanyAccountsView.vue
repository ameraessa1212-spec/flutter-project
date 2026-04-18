<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const companies = ref([])
const loading = ref(true)
const search = ref('')
const statusFilter = ref('')

const filtered = computed(() => {
  let result = companies.value
  
  if (search.value) {
    const t = search.value.toLowerCase()
    result = result.filter(c => 
      (c.name || '').toLowerCase().includes(t) ||
      (c.email || '').toLowerCase().includes(t)
    )
  }
  
  if (statusFilter.value) {
    result = result.filter(c => c.status === statusFilter.value)
  }
  
  return result
})

async function fetchCompanies() {
  loading.value = true
  try {
    const { data } = await api.get('/company-accounts')
    companies.value = data.data || []
  } catch (error) {
    console.error('Error fetching companies:', error)
  } finally {
    loading.value = false
  }
}

async function toggle(c) {
  try {
    const { data } = await api.put(`/company-accounts/${c.id}/toggle-status`)
    c.is_active = data.data.is_active
  } catch (error) {
    alert('حدث خطأ أثناء تغيير حالة الحساب')
  }
}

async function approve(c) {
  if (!confirm(`هل أنت متأكد من قبول شركة "${c.name}"؟`)) return
  try {
    const { data } = await api.put(`/company-accounts/${c.id}/approve`)
    c.status = 'approved'
    c.is_active = true
    alert(data.message)
  } catch (error) {
    alert(error.response?.data?.message || 'حدث خطأ أثناء قبول الشركة')
  }
}

async function reject(c) {
  if (!confirm(`هل أنت متأكد من رفض شركة "${c.name}"؟`)) return
  try {
    const { data } = await api.put(`/company-accounts/${c.id}/reject`)
    c.status = 'rejected'
    c.is_active = false
    alert(data.message)
  } catch (error) {
    alert(error.response?.data?.message || 'حدث خطأ أثناء رفض الشركة')
  }
}

async function deleteCompany(c) {
  if (!confirm(`هل أنت متأكد من حذف شركة "${c.name}"؟ سيتم حذف الحساب نهائياً.`)) return
  try {
    await api.delete(`/company-accounts/${c.id}`)
    await fetchCompanies()
  } catch (error) {
    alert(error.response?.data?.message || 'حدث خطأ أثناء حذف الشركة')
  }
}

onMounted(fetchCompanies)
</script>

<template>
  <div class="page-container">
    <div class="top-header">
      <div class="header-info">
        <h1 class="page-title">إدارة حسابات الشركات</h1>
        <p class="page-subtitle">مراجعة طلبات الانضمام وإدارة صلاحيات وصول الشركات</p>
      </div>
    </div>

    <div class="actions-bar">
      <div class="search-wrapper">
        <i class="ri-search-line"></i>
        <input 
          type="text" 
          v-model="search" 
          placeholder="بحث عن شركة أو بريد..." 
        >
      </div>

      <select v-model="statusFilter" class="filter-select">
        <option value="">كل الحالات</option>
        <option value="pending">قيد الانتظار</option>
        <option value="approved">مقبول</option>
        <option value="rejected">مرفوض</option>
      </select>
    </div>

    <div class="main-card">
      <SkeletonLoader v-if="loading" type="table" :columns="6" />
      
      <div v-else-if="filtered.length === 0" class="empty-state">
        <i class="ri-building-line"></i>
        <p>لا توجد شركات تطابق بحثك</p>
      </div>

      <div v-else class="table-responsive">
        <table class="custom-table">
          <thead>
            <tr>
              <th>الشركة</th>
              <th>معلومات التواصل</th>
              <th>المدينة</th>
              <th>تاريخ الطلب</th>
              <th>الحالة</th>
              <th>الإجراءات</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="c in filtered" :key="c.id">
              <td>
                <div class="company-cell">
                  <div class="company-avatar">
                    <img v-if="c.logo_path" :src="c.logo_path" class="logo-img">
                    <span v-else>{{ c.name.charAt(0) }}</span>
                  </div>
                  <span class="company-name">{{ c.name }}</span>
                </div>
              </td>
              <td>
                <div class="contact-cell">
                  <span class="email"><i class="ri-mail-line"></i> {{ c.email || '--' }}</span>
                  <span class="phone" v-if="c.phone"><i class="ri-phone-line"></i> {{ c.phone }}</span>
                </div>
              </td>
              <td>{{ c.city || '--' }}</td>
              <td>{{ c.created_at || '--' }}</td>
              <td>
                <div class="status-cell">
                    <span v-if="c.status === 'pending'" class="badge badge-pending">قيد الانتظار</span>
                    <span v-else-if="c.status === 'approved'" class="badge badge-success">مقبول</span>
                    <span v-else-if="c.status === 'rejected'" class="badge badge-danger">مرفوض</span>
                    
                    <div v-if="c.status === 'approved'" class="activity-status">
                      <span :class="c.is_active ? 'text-purple' : 'text-muted'">
                        {{ c.is_active ? '• الحساب نشط' : '• الحساب معطل' }}
                      </span>
                    </div>
                </div>
              </td>
              <td>
                <div class="actions-buttons">
                  <template v-if="c.status === 'pending'">
                    <button class="btn-icon btn-approve" @click="approve(c)" title="قبول">
                      <i class="ri-check-line"></i>
                    </button>
                    <button class="btn-icon btn-reject" @click="reject(c)" title="رفض">
                      <i class="ri-close-line"></i>
                    </button>
                  </template>

                  <template v-else-if="c.status === 'approved'">
                    <button
                      class="btn-action"
                      :class="c.is_active ? 'btn-disable' : 'btn-enable'"
                      @click="toggle(c)"
                    >
                      <i :class="c.is_active ? 'ri-lock-line' : 'ri-lock-unlock-line'"></i>
                      {{ c.is_active ? 'تعطيل الدخول' : 'تفعيل الدخول' }}
                    </button>
                  </template>

                  <template v-else-if="c.status === 'rejected'">
                    <button class="btn-text" @click="approve(c)">إعادة مراجعة</button>
                  </template>

                  <button class="btn-icon btn-delete" @click="deleteCompany(c)" title="حذف">
                    <i class="ri-delete-bin-line"></i>
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
/* إعدادات الصفحة العامة */
.page-container {
  padding: 25px;
  direction: rtl;
}

/* الهيدر العلوي بدون زوائد */
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

/* شريط البحث والفلترة جنب لجنب جهة اليسار */
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
  outline: none;
  cursor: pointer;
}

/* الجدول والكارد الرئيسي */
.main-card {
  background: white;
  border-radius: 20px;
  padding: 10px;
  border: 1px solid #f1f5f9;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
}

.table-responsive {
  overflow-x: auto;
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

/* تصميم خلية الشركة والـ Avatar */
.company-cell {
  display: flex;
  align-items: center;
  gap: 10px;
}

.company-avatar {
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

.logo-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 8px;
}

.company-name {
  font-weight: 700;
}

.contact-cell {
  display: flex;
  flex-direction: column;
  font-size: 12px;
  gap: 2px;
}

.contact-cell i {
  color: #6a5ae0;
  margin-left: 4px;
}

/* الحالات (Badges) */
.badge {
  padding: 4px 10px;
  border-radius: 8px;
  font-size: 11px;
  font-weight: 700;
}

.badge-pending { background: #fff7ed; color: #c2410c; }
.badge-success { background: #f0fdf4; color: #15803d; }
.badge-danger { background: #fef2f2; color: #b91c1c; }

.activity-status {
  margin-top: 4px;
  font-size: 11px;
}

.text-purple { color: #6a5ae0; font-weight: 600; }
.text-muted { color: #94a3b8; }

/* الأزرار */
.actions-buttons {
  display: flex;
  gap: 8px;
}

.btn-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.btn-approve { background: #f0fdf4; color: #15803d; }
.btn-reject { background: #fef2f2; color: #b91c1c; }
.btn-delete { background: #fef2f2; color: #b91c1c; }

.btn-action {
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
}

.btn-disable { background: #f1f5f9; color: #475569; }
.btn-enable { background: #6a5ae0; color: white; }

.btn-text {
  background: none;
  border: none;
  color: #6a5ae0;
  font-weight: 600;
  text-decoration: underline;
  cursor: pointer;
}

.loading-state, .empty-state {
  padding: 50px;
  text-align: center;
  color: #94a3b8;
}
</style>