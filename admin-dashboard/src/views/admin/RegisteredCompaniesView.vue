<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../composables/useApi'
import PageHeader from '../../components/PageHeader.vue'

const companies = ref([])
const loading = ref(true)
const search = ref('')
// المصفوفة الخاصة بالألوان كما هي في كودك الأصلي
const colors = ['linear-gradient(135deg,#6C5CE7,#A29BFE)','linear-gradient(135deg,#00B894,#55EFC4)','linear-gradient(135deg,#E17055,#FAB1A0)','linear-gradient(135deg,#0984E3,#74B9FF)','linear-gradient(135deg,#FDCB6E,#F39C12)']

const filtered = computed(() => {
  if (!search.value) return companies.value
  const t = search.value.toLowerCase()
  return companies.value.filter(c => (c.name || '').toLowerCase().includes(t))
})

async function load(specialization) {
  loading.value = true
  const params = {}
  if (specialization) params.specialization = specialization
  const { data } = await api.get('/registered-companies', { params }).catch(() => ({ data: { data: [] } }))
  companies.value = data.data || []
  loading.value = false
}

function onSearch(val) { search.value = val }
function onFilter(val) { load(val ? val : undefined) }

onMounted(() => load())
</script>

<template>
  <div class="page-container">
    <div class="page-title-section">
        <h2>الشركات المسجلة</h2>
    </div>

    <div class="actions-bar">
      <div class="search-wrapper">
        <i class="ri-search-line"></i>
        <input 
          type="text" 
          v-model="search" 
          placeholder="بحث عن شركة..." 
          @input="onSearch($event.target.value)"
        >
      </div>

      <select class="filter-select" @change="e => onFilter(e.target.value)">
        <option value="">كل التخصصات</option>
        <option value="it">هندسة برمجيات</option>
        <option value="network">شبكات</option>
        <option value="elec">إلكترونات</option>
      </select>
    </div>

    <div v-if="!loading" class="mb-md">
      <span class="badge badge-purple">
        <i class="ri-building-line"></i> {{ filtered.length }} شركة
      </span>
    </div>

    <div v-if="loading" class="loading">جاري التحميل...</div>
    <div v-else-if="!filtered.length" class="empty">لا توجد شركات</div>
    
    <div v-else class="grid-3">
      <div v-for="(c, i) in filtered" :key="c.id" class="card" style="text-align:center;">
        <div 
          class="avatar-circle" 
          :style="{ 
            background: colors[i % colors.length], 
            width: '56px', 
            height: '56px', 
            fontSize: '22px', 
            margin: '0 auto 14px' 
          }"
        >
          {{ (c.name||'').charAt(0) }}
        </div>
        <strong style="font-size:16px;">{{ c.name }}</strong>
        <p class="text-sm text-muted" style="margin:8px 0;">
          <i class="ri-map-pin-2-fill"></i> {{ c.city || '--' }}
        </p>
        <div class="badge badge-active" style="margin-top:4px;">
          <i class="ri-group-line"></i> {{ c.internships_count }} متدرب
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page-container {
  padding: 20px;
}

.page-title-section {
    margin-bottom: 20px;
}

.page-title-section h2 {
    font-size: 20px;
    font-weight: 800;
    color: #1e293b;
}

/* التنسيق المطلوب: البحث والفلتر في سطر واحد */
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
  outline: none;
  background: white;
  transition: 0.2s;
}

.filter-select {
  padding: 10px 15px;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  background-color: white;
  color: #64748b;
  outline: none;
  cursor: pointer;
  min-width: 150px;
}

/* تنسيقات الشبكة والكروت الأصلية */
.grid-3 {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 20px;
}

.card {
  background: white;
  border-radius: 20px;
  padding: 20px;
  border: 1px solid #f1f5f9;
  transition: 0.3s;
}

.card:hover {
  box-shadow: 0 10px 20px rgba(0,0,0,0.05);
}

.avatar-circle {
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: bold;
  border-radius: 50%;
}

.badge {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 4px 12px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
}

.badge-purple { background: #f3ebff; color: #6a5ae0; }
.badge-active { background: #f0fdfa; color: #0d9488; }
.mb-md { margin-bottom: 15px; }
.text-muted { color: #64748b; }
.text-sm { font-size: 13px; }
.loading, .empty { text-align: center; padding: 50px; color: #94a3b8; }
</style>