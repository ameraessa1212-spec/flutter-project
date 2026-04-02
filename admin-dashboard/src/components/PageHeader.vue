<script setup>
import { onMounted } from 'vue'
import { useSpecializations } from '../composables/useSpecializations'

const props = defineProps({
  title: String,
  showSearch: { type: Boolean, default: false },
  showSpecFilter: { type: Boolean, default: false },
  searchPlaceholder: { type: String, default: 'بحث...' },
})

const emit = defineEmits(['search', 'filter'])

const { specializations, loadSpecializations } = useSpecializations()

onMounted(() => {
  if (props.showSpecFilter) loadSpecializations()
})
</script>

<template>
  <div class="flex-between mb-lg" style="flex-wrap:wrap;gap:12px;">
    <h1 class="page-title" style="margin:0;">{{ title }}</h1>
    <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
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
        @input="emit('search', $event.target.value)"
      >
    </div>
  </div>
</template>
