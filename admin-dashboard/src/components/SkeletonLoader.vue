<script setup>
defineProps({
  type: { type: String, default: 'table', validator: v => ['table', 'cards', 'list'].includes(v) },
  rows: { type: Number, default: 5 },
  columns: { type: Number, default: 4 },
  cardCount: { type: Number, default: 6 },
})
</script>

<template>
  <!-- Table Skeleton -->
  <div v-if="type === 'table'" class="skeleton-table">
    <div class="skeleton-row skeleton-header">
      <div v-for="c in columns" :key="c" class="skeleton-cell skeleton-pulse" style="height:14px;width:80%;"></div>
    </div>
    <div v-for="r in rows" :key="r" class="skeleton-row">
      <div v-for="c in columns" :key="c" class="skeleton-cell">
        <div class="skeleton-pulse" :style="{ width: (50 + Math.random() * 40) + '%', height: '12px' }"></div>
      </div>
    </div>
  </div>

  <!-- Cards Skeleton -->
  <div v-else-if="type === 'cards'" class="skeleton-cards">
    <div v-for="i in cardCount" :key="i" class="skeleton-card">
      <div class="skeleton-pulse" style="width:48px;height:48px;border-radius:50%;margin-bottom:14px;"></div>
      <div class="skeleton-pulse" style="width:70%;height:14px;margin-bottom:10px;"></div>
      <div class="skeleton-pulse" style="width:50%;height:12px;margin-bottom:8px;"></div>
      <div class="skeleton-pulse" style="width:40%;height:12px;"></div>
    </div>
  </div>

  <!-- List Skeleton -->
  <div v-else class="skeleton-list">
    <div v-for="i in rows" :key="i" class="skeleton-list-item">
      <div class="skeleton-pulse" style="width:40px;height:40px;border-radius:50%;flex-shrink:0;"></div>
      <div style="flex:1;">
        <div class="skeleton-pulse" style="width:60%;height:13px;margin-bottom:8px;"></div>
        <div class="skeleton-pulse" style="width:40%;height:11px;"></div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.skeleton-pulse {
  background: linear-gradient(90deg, #f0f0f0 25%, #e8e8e8 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: pulse 1.5s ease-in-out infinite;
  border-radius: 6px;
}

@keyframes pulse {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

.skeleton-table {
  padding: 16px 20px;
}

.skeleton-row {
  display: flex;
  gap: 16px;
  padding: 14px 0;
  border-bottom: 1px solid #f4f6f9;
}

.skeleton-header {
  border-bottom: 2px solid #eee;
}

.skeleton-cell {
  flex: 1;
}

.skeleton-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  padding: 4px;
}

.skeleton-card {
  background: var(--bg-card, #fff);
  border-radius: 16px;
  padding: 24px;
  border: 1px solid var(--border-light, #f0f0f0);
}

.skeleton-list {
  padding: 8px 20px;
}

.skeleton-list-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px 0;
  border-bottom: 1px solid #f4f6f9;
}

@media (max-width: 768px) {
  .skeleton-cards {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
