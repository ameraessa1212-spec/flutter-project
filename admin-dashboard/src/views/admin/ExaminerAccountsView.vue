<script setup>
import { ref, onMounted, computed } from 'vue'
import { api } from '../../composables/useApi'
import SkeletonLoader from '../../components/SkeletonLoader.vue'

const examiners = ref([])
const loading = ref(true)
const search = ref('')
const showModal = ref(false)
const isEditing = ref(false)
const saving = ref(false)
const form = ref({ name: '', email: '', phone: '', password: '' })
const editingId = ref(null)
const formError = ref('')

const filtered = computed(() => {
  if (!search.value) return examiners.value
  const t = search.value.toLowerCase()
  return examiners.value.filter(e => (e.name||'').toLowerCase().includes(t) || (e.email||'').toLowerCase().includes(t))
})

async function loadExaminers() {
  loading.value = true
  const { data } = await api.get('/examiners').catch(() => ({ data: { data: [] } }))
  examiners.value = data.data || []
  loading.value = false
}

onMounted(loadExaminers)

function openCreate() {
  isEditing.value = false
  editingId.value = null
  form.value = { name: '', email: '', phone: '', password: '' }
  formError.value = ''
  showModal.value = true
}

function openEdit(ex) {
  isEditing.value = true
  editingId.value = ex.id
  form.value = { name: ex.name, email: ex.email, phone: ex.phone || '', password: '' }
  formError.value = ''
  showModal.value = true
}

async function saveExaminer() {
  formError.value = ''
  saving.value = true
  try {
    if (isEditing.value) {
      const payload = { name: form.value.name, email: form.value.email, phone: form.value.phone }
      if (form.value.password) payload.password = form.value.password
      await api.put(`/examiners/${editingId.value}`, payload)
    } else {
      await api.post('/examiners', form.value)
    }
    showModal.value = false
    await loadExaminers()
  } catch (e) {
    const msg = e.response?.data?.message || e.response?.data?.errors
    formError.value = typeof msg === 'string' ? msg : 'حدث خطأ أثناء الحفظ.'
  }
  saving.value = false
}

async function deleteExaminer(ex) {
  if (!confirm(`حذف حساب الممتحن "${ex.name}"؟`)) return
  try {
    await api.delete(`/examiners/${ex.id}`)
    await loadExaminers()
  } catch (e) {
    alert(e.response?.data?.message || 'تعذر الحذف.')
  }
}

async function toggle(ex) {
  if (ex.status === 'active' && !confirm(`تعطيل حساب ${ex.name}؟`)) return
  await api.put(`/examiners/${ex.id}/toggle-status`)
  ex.status = ex.status === 'active' ? 'inactive' : 'active'
}
</script>

<template>
  <div>
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
      <h1 class="page-title" style="margin:0;">إدارة حسابات الممتحنين</h1>
      <div style="display:flex;gap:12px;align-items:center;">
        <input v-model="search" class="search-input" placeholder="ابحث عن ممتحن...">
        <button class="btn btn-primary" @click="openCreate">
          <i class="ri-add-line"></i> إضافة ممتحن
        </button>
      </div>
    </div>

    <SkeletonLoader v-if="loading" type="table" :columns="5" />
    <table v-else class="table">
      <thead><tr><th>الممتحن</th><th>البريد</th><th>الهاتف</th><th>الحالة</th><th>الإجراءات</th></tr></thead>
      <tbody>
        <tr v-for="ex in filtered" :key="ex.id">
          <td><strong>{{ ex.name }}</strong></td>
          <td>{{ ex.email || '--' }}</td>
          <td>{{ ex.phone || '--' }}</td>
          <td><span class="badge" :class="ex.status==='active' ? 'badge-active' : 'badge-inactive'">{{ ex.status==='active' ? 'نشط' : 'معطل' }}</span></td>
          <td style="display:flex;gap:6px;">
            <button class="btn btn-sm btn-primary" @click="openEdit(ex)">تعديل</button>
            <button class="btn btn-sm" :class="ex.status==='active' ? 'btn-danger' : 'btn-success'" @click="toggle(ex)">{{ ex.status==='active' ? 'تعطيل' : 'تفعيل' }}</button>
            <button class="btn btn-sm btn-danger" @click="deleteExaminer(ex)">حذف</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Modal -->
    <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
      <div class="modal-card">
        <h2 style="margin-bottom:18px;">{{ isEditing ? 'تعديل ممتحن' : 'إضافة ممتحن جديد' }}</h2>
        <div v-if="formError" class="alert alert-danger" style="margin-bottom:12px;">{{ formError }}</div>
        <div class="form-group">
          <label>الاسم</label>
          <input v-model="form.name" class="form-input" placeholder="الاسم الكامل" required>
        </div>
        <div class="form-group">
          <label>البريد الإلكتروني</label>
          <input v-model="form.email" type="email" class="form-input" placeholder="email@example.com" required>
        </div>
        <div class="form-group">
          <label>الهاتف</label>
          <input v-model="form.phone" class="form-input" placeholder="رقم الهاتف">
        </div>
        <div class="form-group">
          <label>{{ isEditing ? 'كلمة المرور (اتركها فارغة لعدم التغيير)' : 'كلمة المرور' }}</label>
          <input v-model="form.password" type="password" class="form-input" :placeholder="isEditing ? 'اختياري' : 'كلمة المرور'" :required="!isEditing">
        </div>
        <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:18px;">
          <button class="btn btn-secondary" @click="showModal = false">إلغاء</button>
          <button class="btn btn-primary" @click="saveExaminer" :disabled="saving">{{ saving ? 'جاري الحفظ...' : 'حفظ' }}</button>
        </div>
      </div>
    </div>
  </div>
</template>
