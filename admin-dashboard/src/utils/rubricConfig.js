// Shared evaluation rubric definitions used across admin and examiner views

// Company evaluation: 3 domains, 16 criteria, 100 points total
export const companyDomains = [
  {
    title: 'المجال المعرفي',
    maxTitle: '35 درجة',
    color: '#6A5AE0',
    bg: '#eeeaff',
    criteria: [
      { label: 'مدى المعرفة بالأنشطة التخصصية المختلفة في بيئة العمل', max: 7 },
      { label: 'مدى المعرفة بالنظام المؤسسي وقوانين وأخلاقيات العمل', max: 7 },
      { label: 'القدرة على توظيف المعرفة النظرية والتقنية في التدريب', max: 7 },
      { label: 'التعرف على تقنيات تخصصية جديدة أثناء التدريب', max: 7 },
      { label: 'مدى المعرفة بسوق العمل في مجال التخصص', max: 7 },
    ],
  },
  {
    title: 'المجال المهني',
    maxTitle: '35 درجة',
    color: '#FF9F43',
    bg: '#fff4e8',
    criteria: [
      { label: 'جودة الأداء المهني في بيئة العمل', max: 6 },
      { label: 'الالتزام بالقوانين وأخلاقيات المهنة', max: 6 },
      { label: 'الالتزام بمواعيد العمل', max: 6 },
      { label: 'تقبل النقد والتوجيه', max: 6 },
      { label: 'العلاقة مع الرؤساء والزملاء والعملاء', max: 6 },
      { label: 'إبراز الشخصية الهندسية في بيئة العمل', max: 5 },
    ],
  },
  {
    title: 'مجال القدرات والمهارات',
    maxTitle: '30 درجة',
    color: '#2ecc71',
    bg: '#e8f7f0',
    criteria: [
      { label: 'القدرة على التعلم الذاتي وتحصيل المعرفة', max: 6 },
      { label: 'القدرة على الاتصال الفعال والحوار البناء', max: 6 },
      { label: 'القدرة على تقديم العروض المرئية والمناقشة', max: 6 },
      { label: 'جودة الأعمال الموثقة (المقترحات والتقارير)', max: 6 },
      { label: 'جودة الأداء في العمل الجماعي ضمن فريق', max: 6 },
    ],
  },
]

// Examiner discussion evaluation: 5 domains, 21 criteria, 70 points total
export const examinerDomains = [
  {
    title: 'المجال المعرفي',
    maxTitle: '15 درجة',
    color: '#6A5AE0',
    bg: '#eeeaff',
    items: [
      { key: 'knowledge_1', label: 'مدى إلمام الطالب بالمفاهيم الأساسية للتخصص', max: 3 },
      { key: 'knowledge_2', label: 'القدرة على ربط المعرفة النظرية بالتطبيق العملي', max: 3 },
      { key: 'knowledge_3', label: 'الإلمام بالمصطلحات التقنية والمهنية', max: 3 },
      { key: 'knowledge_4', label: 'المعرفة بالتقنيات والأدوات المستخدمة', max: 3 },
      { key: 'knowledge_5', label: 'مستوى الثقافة العامة في مجال التخصص', max: 3 },
    ],
  },
  {
    title: 'القدرات والمهارات',
    maxTitle: '10 درجات',
    color: '#FF9F43',
    bg: '#fff4e8',
    items: [
      { key: 'skills_1', label: 'القدرة على التحليل وحل المشكلات', max: 3 },
      { key: 'skills_2', label: 'مهارات التواصل والعرض', max: 3 },
      { key: 'skills_3', label: 'القدرة على العمل ضمن فريق', max: 2 },
      { key: 'skills_4', label: 'مهارات التفكير النقدي', max: 2 },
    ],
  },
  {
    title: 'التوثيق',
    maxTitle: '15 درجة',
    color: '#2ecc71',
    bg: '#e8f7f0',
    items: [
      { key: 'doc_1', label: 'جودة التوثيق الفني والتقارير', max: 4 },
      { key: 'doc_2', label: 'تنظيم المحتوى وترتيبه', max: 4 },
      { key: 'doc_3', label: 'المراجع والمصادر المستخدمة', max: 4 },
      { key: 'doc_4', label: 'سلامة اللغة والأسلوب', max: 3 },
    ],
  },
  {
    title: 'المناقشة',
    maxTitle: '15 درجة',
    color: '#0984E3',
    bg: '#e8f4ff',
    items: [
      { key: 'disc_1', label: 'القدرة على عرض وتقديم العمل', max: 5 },
      { key: 'disc_2', label: 'الإجابة على أسئلة لجنة المناقشة', max: 5 },
      { key: 'disc_3', label: 'الثقة بالنفس وإدارة الوقت', max: 5 },
    ],
  },
  {
    title: 'البحث العلمي',
    maxTitle: '15 درجة',
    color: '#E17055',
    bg: '#fff0ec',
    items: [
      { key: 'research_1', label: 'وضوح مشكلة البحث وأهدافه', max: 4 },
      { key: 'research_2', label: 'المنهجية المتبعة في البحث', max: 3 },
      { key: 'research_3', label: 'تحليل النتائج واستخلاص التوصيات', max: 3 },
      { key: 'research_4', label: 'الإبداع والابتكار في الحلول المقترحة', max: 3 },
      { key: 'research_5', label: 'القيمة العلمية والتطبيقية للبحث', max: 2 },
    ],
  },
]

export const decisionLabels = {
  pass: 'ناجح',
  fail: 'راسب',
  conditional_pass: 'ناجح مشروط',
}

// Helper: get company domain score from flat detailed_scores array
export function getCompanyDomainScore(detailedScores, domainIdx) {
  if (!detailedScores?.length) return 0
  let startIdx = 0
  for (let i = 0; i < domainIdx; i++) startIdx += companyDomains[i].criteria.length
  const endIdx = startIdx + companyDomains[domainIdx].criteria.length
  return detailedScores.slice(startIdx, endIdx).reduce((a, b) => a + (b || 0), 0)
}

// Helper: get max possible score for a company domain
export function getCompanyDomainMax(domainIdx) {
  return companyDomains[domainIdx].criteria.reduce((a, c) => a + c.max, 0)
}

// Helper: get company score at a specific criterion index within a domain
export function getCompanyCriterionScore(detailedScores, domainIdx, criterionIdx) {
  if (!detailedScores?.length) return '--'
  let startIdx = 0
  for (let i = 0; i < domainIdx; i++) startIdx += companyDomains[i].criteria.length
  return detailedScores[startIdx + criterionIdx] ?? '--'
}

// Helper: calculate examiner domain subtotal from rubric_scores object
export function getExaminerDomainScore(rubricScores, domainIdx) {
  if (!rubricScores) return 0
  return examinerDomains[domainIdx].items.reduce((sum, item) => sum + (Number(rubricScores[item.key]) || 0), 0)
}
