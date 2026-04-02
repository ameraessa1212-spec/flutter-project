<template>
  <div class="students-requests">
    <div v-if="loading" style="color: #6A5AE0; font-weight: bold; padding: 20px;">جاري التحميل...</div>

    <div class="requests-grid">
      <div class="request-card animate-up" v-for="req in requests" :key="req.id">
        <div class="card-header">
          <div class="avatar">{{ getInitials(req.student?.name || 'طالب') }}</div>
          <div class="main-info">
            <h4>{{ req.full_name_snapshot || req.student?.name || 'اسم غير متوفر' }}</h4>
            <span class="id-tag">{{ req.opportunity?.title || 'عام' }}</span>
          </div>
        </div>

        <div class="card-body">
          <div class="data-item">
            <i class="ri-user-settings-line"></i>
            <div>
              <label>رقم القيد</label>
              <p>{{ req.student?.student_profile?.student_number || '---' }}</p>
            </div>
          </div>
          <div class="data-item">
            <i class="ri-mail-line"></i>
            <div>
              <label>البريد الإلكتروني</label>
              <p>{{ req.email_snapshot || req.student?.email || '---' }}</p>
            </div>
          </div>
          <div class="data-item">
            <i class="ri-phone-line"></i>
            <div>
              <label>رقم الهاتف</label>
              <p>{{ req.phone_snapshot || req.student?.phone || '---' }}</p>
            </div>
          </div>
          <div class="data-item">
            <i class="ri-building-line"></i>
            <div>
              <label>الجامعة</label>
              <p>{{ req.university_snapshot || req.student?.student_profile?.university_name || '---' }}</p>
            </div>
          </div>
          <div class="data-item">
            <i class="ri-book-mark-line"></i>
            <div>
              <label>التخصص</label>
              <p>{{ req.student?.student_profile?.specialization?.name || req.major_snapshot || '---' }}</p>
            </div>
          </div>
        </div>

        <div class="card-footer" v-if="req.status === 'pending' || req.status === 'reviewing'">
          <button class="action-btn accept" @click="updateStatus(req.id, 'accepted')" :disabled="processing === req.id">
            <span v-if="processing !== req.id">قبول </span>
            <span v-else>جاري...</span>
          </button>
          <button class="action-btn reject" @click="updateStatus(req.id, 'rejected')" :disabled="processing === req.id">
            رفض
          </button>
        </div>
        <div class="card-footer" v-else>
          <div class="status-result" :style="req.status === 'accepted' ? 'background: #dcfce7; color: #166534;' : 'background: #fee2e2; color: #991b1b;'">
            {{ req.status === 'accepted' ? 'تم القبول ✅' : 'مرفوض ❌' }}
          </div>
        </div>
      </div>

      <div v-if="!loading && requests.length === 0" class="empty-state">
        <i class="ri-inbox-line" style="font-size: 3rem; color: #cbd5e1;"></i>
        <h3>لا توجد طلبات تدريب حالياً</h3>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'
import { apiFetch } from '../../api'

const emit = defineEmits(['refresh'])
const refreshDashboard = inject('refreshDashboard')

const requests = ref([])
const loading = ref(true)
const processing = ref(null)

onMounted(() => {
  fetchRequests()
})

async function fetchRequests() {
  loading.value = true
  try {
    const response = await apiFetch('/company/requests')
    if (response.ok) {
      requests.value = await response.json()
    }
  } catch (error) {
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

async function updateStatus(id, status) {
  if (status === 'rejected' && !confirm('هل أنت متأكد من رفض هذا الطلب؟')) return

  processing.value = id
  try {
    const response = await apiFetch('/company/requests/' + id + '/status', {
      method: 'PUT',
      body: JSON.stringify({ status })
    })

    if (response.ok) {
      const index = requests.value.findIndex(r => r.id === id)
      if (index !== -1) {
        requests.value[index].status = status
      }
      if (status === 'accepted') {
        emit('refresh')
        if (refreshDashboard) refreshDashboard()
      }
    } else {
      alert('حدث خطأ أثناء التحديث.')
    }
  } catch (error) {
    alert('تعذر الاتصال بالخادم.')
  } finally {
    processing.value = null
  }
}

function getInitials(name) {
  if (!name) return '؟'
  const parts = name.trim().split(' ')
  if (parts.length > 1) {
    return (parts[0][0] + ' ' + parts[1][0]).toUpperCase()
  }
  return name.substring(0, 2).toUpperCase()
}
</script>

<style scoped>
.students-requests {
    padding: 20px;
    font-family: 'Cairo', sans-serif;
    direction: rtl;
}

.requests-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 25px;
    margin-top: 20px;
}

.request-card {
    background: #ffffff;
    border-radius: 25px;
    padding: 25px;
    border: 1px solid rgba(0,0,0,0.03);
    box-shadow: 0 10px 30px rgba(0,0,0,0.02);
    transition: all 0.3s ease;
}

.request-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 15px 35px rgba(138, 43, 226, 0.1);
}

.card-header {
    display: flex;
    align-items: center;
    gap: 15px;
    margin-bottom: 20px;
}

.avatar {
    width: 55px;
    height: 55px;
    background: #6A5AE0;
    color: #fff;
    border-radius: 15px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 900;
    font-size: 18px;
}

.main-info h4 {
    font-size: 18px;
    color: #1e293b;
    margin-bottom: 4px;
}

.id-tag {
    font-size: 11px;
    color: #6A5AE0;
    font-weight: 700;
    background: #f3ebff;
    padding: 2px 8px;
    border-radius: 6px;
}

.card-body {
    display: flex;
    flex-direction: column;
    gap: 15px;
    padding: 15px 0;
    border-top: 1px solid #f8faff;
}

.data-item {
    display: flex;
    align-items: flex-start;
    gap: 12px;
}

.data-item i {
    color: #6A5AE0;
    font-size: 18px;
    margin-top: 2px;
}

.data-item label {
    display: block;
    font-size: 11px;
    color: #94a3b8;
    font-weight: 600;
    margin-bottom: 2px;
}

.data-item p {
    font-size: 14px;
    color: #334155;
    font-weight: 700;
    margin: 0;
}

.card-footer {
    display: flex;
    gap: 10px;
    margin-top: 20px;
}

.action-btn {
    flex: 1;
    padding: 12px;
    border: none;
    border-radius: 12px;
    font-family: 'Cairo';
    font-weight: 700;
    cursor: pointer;
    transition: 0.3s;
}

.action-btn.accept {
    background: #6A5AE0;
    color: #ffffff;
}

.action-btn.accept:hover {
    background: #403a66;
    box-shadow: 0 5px 15px rgba(138, 43, 226, 0.3);
}

.action-btn.reject {
    background: #fff1f2;
    color: #e11d48;
    border: 1px solid #ffe4e6;
}

.action-btn.reject:hover {
    background: #ffe4e6;
    color: #be123c;
}

.status-result {
    text-align: center; width: 100%; padding: 10px;
    border-radius: 12px; font-weight: bold;
}

.empty-state {
    text-align: center; padding: 3rem; color: #64748b;
    width: 100%; grid-column: 1 / -1;
}

.animate-up {
    animation: fadeInUp 0.6s ease forwards; opacity: 0;
}
@keyframes fadeInUp {
    from { transform: translateY(20px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}
</style>
