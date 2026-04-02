import { ref } from 'vue'
import api from './useApi'

const specializations = ref([])
const loaded = ref(false)

export async function loadSpecializations() {
  if (loaded.value) return specializations.value
  const { data } = await api.get('/specializations').catch(() => ({ data: { data: [] } }))
  specializations.value = data.data || []
  loaded.value = true
  return specializations.value
}

export function useSpecializations() {
  return { specializations, loadSpecializations }
}
