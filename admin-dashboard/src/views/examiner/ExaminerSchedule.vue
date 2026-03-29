<script setup>
import { ref, onMounted } from 'vue'
import api from '../../composables/useApi'

const imageUrl = ref('')
const loading = ref(true)

onMounted(async () => {
  const { data } = await api.get('/discussion-schedules').catch(() => ({ data: { data: [] } }))
  if (data.data?.length && data.data[0].image_url) imageUrl.value = data.data[0].image_url
  loading.value = false
})
</script>

<template>
  <div>
    <h1 class="page-title">جدول المناقشة</h1>
    <div v-if="loading" class="loading">جاري التحميل...</div>
    <div v-else-if="imageUrl" class="card" style="text-align:center;">
      <img :src="imageUrl" style="max-width:100%;border-radius:12px;">
    </div>
    <div v-else class="empty">لا يوجد جدول منشور حالياً</div>
  </div>
</template>
