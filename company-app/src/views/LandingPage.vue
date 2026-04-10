<template>
  <div class="landing-page">
    <nav class="navbar">
      <div class="logo">WASLAA<span></span></div>
      <div class="nav-auth">
        <router-link to="/login" class="btn-glass">تسجيل الدخول</router-link>
        <router-link to="/signup" class="btn-purple"> سجل شركتك </router-link>
      </div>
    </nav>

    <main class="hero-grid">
      <div class="hero-card info-card fade-up">
        
        <h1>اربط شركتك <br> بـ <span>مستقبل التدريب</span></h1>
        <p>منصة "وصلة" توفر لك لوحة تحكم ذكية لمتابعة نمو الكفاءات وتدريب الطلاب  بأحدث الوسائل التقنية.</p>

        <div class="stats-row">
          <div class="stat-item">
            <h4>+50</h4>
            <p>متدرب</p>
          </div>
          <div class="stat-item">
            <h4>+85</h4>
            <p>شركة ليبية</p>
          </div>
        </div>
      </div>

      <div class="hero-card chart-card fade-up" style="animation-delay: 0.2s;">
        <div class="chart-header">
          <h4>مؤشر نمو التدريب 2026</h4>
          <div class="chart-legend">حيوية النظام</div>
        </div>
        <canvas ref="chartCanvas"></canvas>
      </div>

      <div class="hero-card partners-card fade-up" style="animation-delay: 0.4s;">
        <p>تثق بنا كبرى المؤسسات</p>
        <div class="partners-logos">
          <div class="logo-placeholder">LIBYANA </div>
          <div class="logo-placeholder">AL MADAR</div>
          <div class="logo-placeholder">LTT</div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, ref } from 'vue'
import Chart from 'chart.js/auto'

const chartCanvas = ref(null)
let chartInstance = null
let mouseMoveHandler = null

onMounted(() => {
  // Chart.js
  const ctx = chartCanvas.value.getContext('2d')
  chartInstance = new Chart(ctx, {
    type: 'line',
    data: {
      labels: ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو'],
      datasets: [{
        label: 'نمو الشركات المسجلة',
        data: [12, 19, 15, 25, 22, 35],
        borderColor: '#8a2be2',
        backgroundColor: 'rgba(138, 43, 226, 0.1)',
        borderWidth: 4,
        tension: 0.4,
        fill: true,
        pointRadius: 0
      }]
    },
    options: {
      responsive: true,
      plugins: { legend: { display: false } },
      scales: {
        y: { display: false },
        x: { grid: { display: false } }
      }
    }
  })

  // 3D tilt effect
  const cards = document.querySelectorAll('.hero-card')
  mouseMoveHandler = (e) => {
    let x = (window.innerWidth / 2 - e.pageX) / 50
    let y = (window.innerHeight / 2 - e.pageY) / 50
    cards.forEach(card => {
      card.style.transform = `rotateY(${x}deg) rotateX(${-y}deg)`
    })
  }
  document.addEventListener('mousemove', mouseMoveHandler)
})

onUnmounted(() => {
  if (chartInstance) chartInstance.destroy()
  if (mouseMoveHandler) document.removeEventListener('mousemove', mouseMoveHandler)
})
</script>

<style scoped>
:root {
    --primary: #6A5AE0;
    --bg: #f4f7ff;
    --card-bg: rgba(255, 255, 255, 0.8);
    --text: #1a1a2e;
}

.landing-page {
    background-color: #f4f7ff;
    background-image: radial-gradient(circle at 10% 20%, rgba(138, 43, 226, 0.05) 0%, transparent 50%);
    color: #1a1a2e;
    overflow-x: hidden;
    min-height: 100vh;
    font-family: 'Cairo', sans-serif;
    direction: rtl;
}

.navbar {
    display: flex; justify-content: space-between; align-items: center;
    padding: 25px 5%; background: rgba(255, 255, 255, 0.6);
    backdrop-filter: blur(10px); position: sticky; top: 0; z-index: 100;
}

.logo { font-size: 30px; font-weight: 900; }
.logo span { color: #6A5AE0; }

.btn-purple {
    background: #6A5AE0; color: white; text-decoration: none;
    padding: 12px 28px; border-radius: 12px; font-weight: bold;
    box-shadow: 0 8px 20px rgba(138, 43, 226, 0.2);
}

.btn-glass {
    text-decoration: none; color: #6A5AE0; border: 2px solid #6A5AE0;
    padding: 10px 25px; border-radius: 12px; font-weight: bold; margin-left: 15px;
}

.hero-grid {
    display: grid;
    grid-template-columns: 1.2fr 0.8fr;
    grid-template-rows: auto auto;
    gap: 25px;
    padding: 40px 5%;
    max-width: 1400px; margin: 0 auto;
}

.hero-card {
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(15px);
    border: 1px solid rgba(255, 255, 255, 0.4);
    border-radius: 30px;
    padding: 40px;
    box-shadow: 0 20px 50px rgba(0,0,0,0.03);
}

.info-card h1 { font-size: 3.5rem; line-height: 1.2; margin-bottom: 20px; }
.info-card h1 span { color: #6A5AE0; }
.status-tag {
    background: #e0d4ff; color: #6A5AE0; padding: 5px 15px;
    border-radius: 50px; font-size: 14px; font-weight: bold; display: inline-flex; align-items: center; gap: 8px;
}
.dot { width: 8px; height: 8px; background: #6A5AE0; border-radius: 50%; animation: blink 1s infinite; }

.stats-row { display: flex; gap: 40px; margin-top: 30px; }
.stat-item h4 { font-size: 2rem; color: #6A5AE0; }

.chart-card { display: flex; flex-direction: column; justify-content: center; }
.chart-header { display: flex; justify-content: space-between; margin-bottom: 20px; }

.partners-card { grid-column: span 2; display: flex; justify-content: space-between; align-items: center; padding: 25px 50px; }
.partners-logos { display: flex; gap: 50px; opacity: 0.5; filter: grayscale(1); }
.logo-placeholder { font-weight: 900; letter-spacing: 2px; }

@keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } }
.fade-up { opacity: 0; transform: translateY(30px); animation: fadeUp 0.8s forwards ease-out; }
@keyframes fadeUp { to { opacity: 1; transform: translateY(0); } }

@media (max-width: 900px) {
    .hero-grid { grid-template-columns: 1fr; }
    .partners-card { grid-column: span 1; flex-direction: column; gap: 20px; }
    .info-card h1 { font-size: 2.5rem; }
}
</style>
