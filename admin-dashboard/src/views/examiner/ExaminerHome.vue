<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'
import { useAuth } from '../../composables/useApi'

const { user } = useAuth()
const data = ref(null)
const loading = ref(true)

onMounted(async () => {
  const res = await api.get('/examiner/dashboard').catch(() => null)
  if (res?.data?.data) data.value = res.data.data
  loading.value = false
})

const today = new Date().toLocaleDateString('ar-LY', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })
</script>

<template>
  <div>
    <div class="card" style="background:linear-gradient(135deg,#6A5AE0,#8B7CF0);color:white;margin-bottom:25px;padding:30px;">
      <h2 style="color:white;margin-bottom:6px;">أهلاً بك، {{ user?.name || 'الممتحن' }}</h2>
      <p v-if="data">لديك اليوم <strong>{{ data.today_discussions?.length || 0 }}</strong> مناقشات و <strong>{{ data.pending_reports }}</strong> تقريراً بانتظار التقييم.</p>
      <small style="opacity:.7;">{{ today }}</small>
    </div>

    <div v-if="loading" class="loading">جاري التحميل...</div>
    <template v-else-if="data">
      <div class="grid-3" style="margin-bottom:25px;">
        <div class="stat-card"><div class="icon purple"><i class="ri-group-line"></i></div><div><h3>{{ data.evaluated_count }}</h3><p>طلاب تم تقييمهم</p></div></div>
        <div class="stat-card"><div class="icon orange"><i class="ri-file-warning-line"></i></div><div><h3>{{ data.pending_reports }}</h3><p>تقارير معلقة</p></div></div>
        <div class="stat-card"><div class="icon green"><i class="ri-medal-2-line"></i></div><div><h3>{{ data.average_score }}</h3><p>متوسط الدرجات</p></div></div>
      </div>

      <div class="grid-2">
        <div class="card">
          <h3 style="margin-bottom:12px;">تنبيهات</h3>
          <div v-if="!data.alerts?.length" class="empty" style="padding:20px;">لا توجد تنبيهات</div>
          <div v-for="a in data.alerts" :key="a.id" style="padding:10px;border-radius:8px;margin-bottom:6px;background:#f8f9fd;">
            <strong style="font-size:14px;">{{ a.title }}</strong><br><small style="color:#777;">{{ a.body }}</small>
          </div>
        </div>

        <div class="card">
          <h3 style="margin-bottom:12px;">مناقشات اليوم</h3>
          <div v-if="!data.today_discussions?.length" class="empty" style="padding:20px;">لا توجد مناقشات اليوم</div>
          <table v-else class="table">
            <thead><tr><th>الطالب</th><th>الوقت</th><th>القاعة</th></tr></thead>
            <tbody><tr v-for="d in data.today_discussions" :key="d.id"><td>{{ d.student_name }}</td><td>{{ d.time || '--' }}</td><td>{{ d.location || '--' }}</td></tr></tbody>
          </table>
        </div>
      </div>
    </template>
  </div>
</template>
