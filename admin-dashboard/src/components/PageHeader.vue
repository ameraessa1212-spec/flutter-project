<script setup>
import { onMounted, ref } from 'vue'
import { useSpecializations } from '../composables/useSpecializations'

const props = defineProps({
  title: String,
  showSearch: { type: Boolean, default: false },
  showSpecFilter: { type: Boolean, default: false },
  showStatusFilter: { type: Boolean, default: false },
  statusOptions: {
    type: Array,
    default: () => [
      { value: 'pending', label: 'معلق' },
      { value: 'approved', label: 'مقبول' },
      { value: 'rejected', label: 'مرفوض' },
    ],
  },
 
  searchPlaceholder: { type: String, default: 'بحث...' },
})

const emit = defineEmits(['search', 'filter', 'statusFilter'])

const { specializations, loadSpecializations } = useSpecializations()

let searchTimeout = null
function onSearch(e) {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => emit('search', e.target.value), 300)
}

onMounted(() => {
  if (props.showSpecFilter) loadSpecializations()
})
</script>

<template>
  <div class="flex-between mb-lg" style="flex-wrap:wrap;gap:12px;">
    <h1 class="page-title" style="margin:0;">{{ title }}</h1>
    <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
      <select
        v-if="showStatusFilter"
        class="form-input"
        style="max-width:180px;padding:10px 14px;border-radius:999px;"
        @change="emit('statusFilter', $event.target.value)"
      >
        <option value="">كل الحالات</option>
        <option v-for="opt in statusOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
      </select>
      <select
        v-if="showSpecFilter"
        class="form-input"
        style="max-width:200px;padding:10px 14px;border-radius:999px;"
        @change="emit('filter', $event.target.value)"
      >
        <option value="">كل التخصصات</option>
        <option v-for="s in specializations" :key="s.id" :value="s.id">{{ s.name }}</option>
      </select>
      <input
        v-if="showSearch"
        class="search-input"
        :placeholder="searchPlaceholder"
        @input="onSearch"
      >
    </div>
  </div>
</template>
