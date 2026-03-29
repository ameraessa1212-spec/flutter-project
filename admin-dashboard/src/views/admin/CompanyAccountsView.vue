<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'

const companies = ref([])
const loading = ref(true)
const search = ref('')
const statusFilter = ref('')

const filtered = computed(() => {
  let result = companies.value
  
  if (search.value) {
    result = result.filter(c => 
      (c.name || '').toLowerCase().includes(search.value.toLowerCase()) ||
      (c.email || '').toLowerCase().includes(search.value.toLowerCase())
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

onMounted(fetchCompanies)
</script>

<template>
  <div class="company-accounts-page">
    <div class="page-header">
      <div>
        <h1 class="page-title">إدارة حسابات الشركات</h1>
        <p class="page-subtitle">مراجعة طلبات الانضمام وإدارة صلاحيات وصول الشركات إلى المنصة</p>
      </div>
      <div class="header-actions">
        <select v-model="statusFilter" class="form-select status-filter">
          <option value="">كل الحالات</option>
          <option value="pending">قيد الانتظار</option>
          <option value="approved">مقبول</option>
          <option value="rejected">مرفوض</option>
        </select>
        <div class="search-box">
          <input v-model="search" class="search-input" placeholder="بحث عن شركة أو بريد إلكتروني...">
        </div>
      </div>
    </div>

    <div class="card">
      <div v-if="loading" class="loading">جاري تحميل البيانات...</div>
      
      <div v-else-if="filtered.length === 0" class="empty">
        <i class="ri-building-line" style="font-size: 48px; display: block; margin-bottom: 10px; opacity: 0.2;"></i>
        <p>لا توجد شركات تطابق بحثك</p>
      </div>

      <div v-else class="table-container">
        <table class="table">
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
                <div class="company-info">
                  <div class="company-avatar">
                   <img v-if="c.logo_path" :src="c.logo_path" class="logo-img">
                   <span v-else>{{ c.name.charAt(0) }}</span>
                  </div>
                  <strong>{{ c.name }}</strong>
                </div>
              </td>
              <td>
                <div class="contact-info">
                  <div class="email"><i class="ri-mail-line"></i> {{ c.email || '--' }}</div>
                  <div class="phone" v-if="c.phone"><i class="ri-phone-line"></i> {{ c.phone }}</div>
                </div>
              </td>
              <td>{{ c.city || '--' }}</td>
              <td>{{ c.created_at || '--' }}</td>
              <td>
                <span v-if="c.status === 'pending'" class="badge badge-pending">قيد الانتظار</span>
                <span v-else-if="c.status === 'approved'" class="badge badge-active">مقبول</span>
                <span v-else-if="c.status === 'rejected'" class="badge badge-inactive">مرفوض</span>
                
                <div v-if="c.status === 'approved'" class="mt-sm">
                  <span class="badge" :class="c.is_active ? 'badge-purple' : 'badge-inactive'">
                    {{ c.is_active ? 'الحساب نشط' : 'الحساب معطل' }}
                  </span>
                </div>
              </td>
              <td class="actions-cell">
                <!-- Actions for Pending Companies -->
                <div v-if="c.status === 'pending'" class="flex gap-sm">
                  <button class="btn btn-sm btn-success" @click="approve(c)">
                    <i class="ri-check-line"></i> قبول
                  </button>
                  <button class="btn btn-sm btn-danger" @click="reject(c)">
                    <i class="ri-close-line"></i> رفض
                  </button>
                </div>

                <!-- Actions for Approved Companies -->
                <div v-else-if="c.status === 'approved'">
                  <button class="btn btn-sm" :class="c.is_active ? 'btn-outline' : 'btn-primary'" @click="toggle(c)">
                    <i :class="c.is_active ? 'ri-lock-line' : 'ri-lock-unlock-line'"></i>
                    {{ c.is_active ? 'تعطيل الدخول' : 'تفعيل الدخول' }}
                  </button>
                </div>

                <!-- Actions for Rejected Companies (Allow reconsideration) -->
                <div v-else-if="c.status === 'rejected'">
                  <button class="btn btn-sm btn-outline" @click="approve(c)">
                    إعادة مراجعة (قبول)
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
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.status-filter {
  width: 150px;
  padding: 10px;
}

.company-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.company-avatar {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  background: var(--primary-bg);
  color: var(--primary);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  overflow: hidden;
}

.logo-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.contact-info {
  font-size: 13px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.contact-info i {
  color: var(--primary);
  margin-left: 4px;
}

.actions-cell {
  min-width: 180px;
}

.mt-sm {
  margin-top: 5px;
}

.table-container {
  overflow-x: auto;
}
</style>
