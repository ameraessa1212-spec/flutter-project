<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '../../composables/useApi'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const route = useRoute()
const router = useRouter()
const company = ref(null)
const loading = ref(true)

onMounted(async () => {
  try {
    const { data } = await api.get(`/registered-companies/${route.params.id}`)
    company.value = data.data
  } catch (_) {}
  loading.value = false
})

async function toggleSupervisor(s) {
  try {
    const { data } = await api.put(`/supervisors/${s.id}/toggle-status`)
    s.is_active = data.data.is_active
  } catch (_) {
    alert('حدث خطأ أثناء تغيير حالة المشرف')
  }
}
</script>

<template>
  <div>
    <button class="btn btn-secondary btn-sm" style="margin-bottom:20px;" @click="router.push('/registered-companies')">
      <i class="ri-arrow-right-line"></i> العودة للقائمة
    </button>

    <SkeletonLoader v-if="loading" type="list" :rows="6" />
    <div v-else-if="!company" class="empty">لم يتم العثور على الشركة</div>
    <template v-else>
      <!-- Company Header -->
      <div class="card mb-lg" style="display:flex;align-items:center;gap:20px;">
        <div class="avatar-circle" style="width:64px;height:64px;font-size:26px;background:linear-gradient(135deg,#6C5CE7,#A29BFE);flex-shrink:0;">
          {{ (company.name||'').charAt(0) }}
        </div>
        <div style="flex:1;">
          <h2 style="margin:0 0 4px;">{{ company.name }}</h2>
          <p class="text-muted text-sm" style="margin:0;">
            <i class="ri-map-pin-line"></i> {{ company.city || '--' }} · {{ company.address || '' }}
          </p>
          <div style="display:flex;gap:16px;margin-top:8px;flex-wrap:wrap;">
            <span class="text-sm" v-if="company.email"><i class="ri-mail-line" style="color:var(--primary);"></i> {{ company.email }}</span>
            <span class="text-sm" v-if="company.phone"><i class="ri-phone-line" style="color:var(--primary);"></i> {{ company.phone }}</span>
            <a v-if="company.website_url" :href="company.website_url" target="_blank" class="text-sm" style="color:var(--primary);"><i class="ri-global-line"></i> الموقع</a>
          </div>
        </div>
        <span class="badge" :class="company.is_active ? 'badge-active' : 'badge-inactive'">
          {{ company.is_active ? 'نشط' : 'معطل' }}
        </span>
      </div>

      <!-- Description -->
      <div v-if="company.description" class="card mb-lg">
        <h3 style="margin-bottom:10px;font-size:15px;"><i class="ri-information-line" style="color:var(--primary);margin-left:6px;"></i> نبذة عن الشركة</h3>
        <p class="text-sm" style="color:#555;line-height:1.8;">{{ company.description }}</p>
      </div>

      <!-- Training Opportunities -->
      <div class="card mb-lg">
        <div class="card-header">
          <span class="card-title"><i class="ri-briefcase-line" style="color:var(--primary);margin-left:6px;"></i> عروض التدريب</span>
          <span class="badge badge-purple">{{ company.opportunities?.length || 0 }}</span>
        </div>
        <div v-if="!company.opportunities?.length" class="empty" style="padding:24px;">لا توجد عروض تدريب</div>
        <div v-else style="overflow-x:auto;">
          <table class="table">
            <thead><tr><th>العنوان</th><th>التخصص</th><th>المقاعد</th><th>الحالة</th><th>تاريخ البدء</th><th>تاريخ الانتهاء</th></tr></thead>
            <tbody>
              <tr v-for="o in company.opportunities" :key="o.id">
                <td><strong>{{ o.title }}</strong></td>
                <td>{{ o.specialization || '--' }}</td>
                <td>{{ o.seats_count }}</td>
                <td>
                  <span class="badge" :class="{ 'badge-active': o.status==='approved', 'badge-pending': o.status==='pending', 'badge-inactive': o.status==='rejected' }">
                    {{ o.status === 'approved' ? 'مقبول' : o.status === 'pending' ? 'معلق' : 'مرفوض' }}
                  </span>
                </td>
                <td>{{ o.start_date || '--' }}</td>
                <td>{{ o.end_date || '--' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Current Students -->
      <div class="card mb-lg">
        <div class="card-header">
          <span class="card-title"><i class="ri-group-line" style="color:var(--success);margin-left:6px;"></i> الطلاب المتدربون حالياً</span>
          <span class="badge badge-active">{{ company.students?.length || 0 }}</span>
        </div>
        <div v-if="!company.students?.length" class="empty" style="padding:24px;">لا يوجد طلاب متدربون حالياً</div>
        <div v-else style="overflow-x:auto;">
          <table class="table">
            <thead><tr><th>الطالب</th><th>رقم القيد</th><th>التخصص</th><th>تاريخ البدء</th><th>الحالة</th></tr></thead>
            <tbody>
              <tr v-for="s in company.students" :key="s.id">
                <td><strong>{{ s.name }}</strong></td>
                <td>{{ s.student_number || '--' }}</td>
                <td>{{ s.specialization || '--' }}</td>
                <td>{{ s.start_date || '--' }}</td>
                <td><span class="badge badge-active">{{ s.status }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Supervisors -->
      <div class="card">
        <div class="card-header">
          <span class="card-title"><i class="ri-user-star-line" style="color:var(--warning);margin-left:6px;"></i> المشرفون</span>
          <span class="badge badge-purple">{{ company.supervisors?.length || 0 }}</span>
        </div>
        <div v-if="!company.supervisors?.length" class="empty" style="padding:24px;">لا يوجد مشرفون</div>
        <div v-else style="overflow-x:auto;">
          <table class="table">
            <thead><tr><th>الاسم</th><th>البريد</th><th>الهاتف</th><th>القسم</th><th>الحالة</th><th>الإجراء</th></tr></thead>
            <tbody>
              <tr v-for="s in company.supervisors" :key="s.id">
                <td><strong>{{ s.name }}</strong></td>
                <td>{{ s.email || '--' }}</td>
                <td>{{ s.phone || '--' }}</td>
                <td>{{ s.department || '--' }}</td>
                <td><span class="badge" :class="s.is_active ? 'badge-active' : 'badge-inactive'">{{ s.is_active ? 'نشط' : 'معطل' }}</span></td>
                <td>
                  <button class="btn btn-sm" :class="s.is_active ? 'btn-danger' : 'btn-success'" @click="toggleSupervisor(s)">
                    {{ s.is_active ? 'تعطيل' : 'تفعيل' }}
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </template>
  </div>
</template>
