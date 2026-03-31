<template>
  <div>
    <section class="stats-grid">
      <div class="stat-card purple animate-up">
        <div class="stat-header">
          <div class="icon"><i class="ri-user-follow-line"></i></div>
          <span class="trend">{{ stats.growth }}</span>
        </div>
        <div class="stat-body">
          <h3>{{ stats.activeStudents }}</h3>
          <p>متدرب نشط حالياً</p>
        </div>
      </div>
      <div class="stat-card blue animate-up" style="animation-delay: 0.1s;">
        <div class="stat-header">
          <div class="icon"><i class="ri-file-list-3-line"></i></div>
        </div>
        <div class="stat-body">
          <h3>{{ stats.opportunities }}</h3>
          <p>فرصة تدريب معلنة</p>
        </div>
      </div>
      <div class="stat-card green animate-up" style="animation-delay: 0.2s;">
        <div class="stat-header">
          <div class="icon"><i class="ri-star-smile-line"></i></div>
          <span class="trend">{{ stats.rating }}</span>
        </div>
        <div class="stat-body">
          <h3>{{ stats.pendingRequests }}</h3>
          <p>عدد الطلبات المعلقة</p>
        </div>
      </div>
    </section>

    <div class="dashboard-banner animate-fade" style="animation-delay: 0.3s;">
      <div class="banner-content">
        <h3>إدارة متكاملة لخطتك التدريبية</h3>
        <p>يمكنك مراجعة كافة الطلبات وتقييم المتدربين من مكان واحد.</p>
        <button @click="$router.push('/dashboard/requests')" class="banner-btn">
          عرض الطلبات الجديدة
        </button>
      </div>
    </div>

    <section class="dashboard-body">
      <h3 class="section-title">الطلاب المتدربين حالياً</h3>
      <div class="table-container">
        <table>
          <thead>
            <tr>
              <th>اسم الطالب</th>
              <th>الفرصة التدريبية</th>
              <th>تاريخ البدء</th>
              <th>الحالة</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="student in studentsList" :key="student.id">
              <td>{{ student.student?.name || 'غير معروف' }}</td>
              <td>{{ student.opportunity?.title || 'غير متوفر' }}</td>
              <td>{{ student.start_date || '-' }}</td>
              <td>
                <span class="status-badge">{{ student.status === 'active' ? 'نشط' : student.status }}</span>
              </td>
            </tr>
            <tr v-if="studentsList.length === 0">
              <td colspan="4" class="empty-row">لا يوجد متدربين حالياً</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>

<script setup>
defineProps({
  stats: { type: Object, required: true },
  studentsList: { type: Array, required: true }
})
</script>

<style scoped>
.stats-grid {
    display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px;
}

.stat-card {
    background: white;
    padding: 25px;
    border-radius: 25px;
    box-shadow: 0 10px 20px rgba(0,0,0,0.01);
    border: 2px solid transparent;
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    cursor: pointer;
}

.stat-card:hover {
    transform: translateY(-8px);
    border-color: #8E82EF;
    box-shadow: 0 15px 30px rgba(106, 90, 224, 0.12);
}

.stat-header { display: flex; justify-content: space-between; margin-bottom: 15px; }
.stat-header .icon {
    width: 45px; height: 45px; border-radius: 12px;
    display: flex; align-items: center; justify-content: center; font-size: 20px;
}
.purple .icon { background: #EFE9FF; color: #6A5AE0; }
.blue .icon { background: #E1F5FE; color: #0984E3; }
.green .icon { background: #E8F5E9; color: #27AE60; }

.stat-body h3 { font-size: 28px; font-weight: 900; margin-bottom: 5px; }
.stat-body p { color: #636E72; font-size: 14px; }
.trend { font-size: 12px; font-weight: 800; color: #27AE60; }

.dashboard-banner {
    margin-top: 2rem;
    background: linear-gradient(135deg, #6A5AE0 0%, #4B39C7 100%);
    padding: 2rem;
    border-radius: 20px;
    color: white;
}

.banner-btn {
    background: white; color: #6A5AE0; border: none;
    padding: 0.75rem 1.5rem; border-radius: 10px; font-weight: 700;
    cursor: pointer; margin-top: 1rem; font-family: 'Cairo', sans-serif;
}

.dashboard-body { margin-top: 2rem; }
.section-title { margin-bottom: 1rem; color: #2D3436; }

.table-container {
    background: white; border-radius: 16px; padding: 1.5rem;
    box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
}

table { width: 100%; border-collapse: collapse; text-align: right; }
thead tr { border-bottom: 2px solid #f1f5f9; color: #636E72; }
th { padding: 1rem 0; }
tbody tr { border-bottom: 1px solid #f1f5f9; }
td { padding: 1rem 0; }

.status-badge {
    background: #e0e7ff; color: #3b82f6; padding: 4px 12px;
    border-radius: 20px; font-size: 0.85rem;
}

.empty-row { text-align: center; padding: 2rem; color: #64748b; }

.animate-up {
    animation: fadeInUp 0.6s ease forwards; opacity: 0;
}
.animate-fade {
    animation: fadeInUp 0.6s ease forwards;
}
@keyframes fadeInUp {
    from { transform: translateY(20px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}

@media (max-width: 1024px) {
    .stats-grid { grid-template-columns: 1fr; }
}
</style>
