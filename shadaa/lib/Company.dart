// ignore: file_names
import 'package:flutter/material.dart';
import 'package:shadaa/company_details.dart';
import 'package:shadaa/const/color.dart';

class CompanyPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CompanyPage({super.key, required this.scaffoldKey});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  final List<Map<String, dynamic>> allOpportunities = [
    {
      'title': 'تدريب ميداني في خدمات الاتصالات',
      'company': 'هاتف ليبيا',
      'image': 'assets/images/phone_libya.JPG',
      'desc':
          'فرصة تدريب ميداني للطلاب داخل أقسام الهاتف الثابت وخدمات الإنترنت.',
      'isAvailable': true,
      'specialization': 'اتصالات',
      'location': 'طرابلس',
      'duration': 'شهرين',
    },
    {
      'title': 'تدريب في تشغيل الشبكات',
      'company': 'المدار الجديد',
      'image': 'assets/images/madar.JPG',
      'desc':
          'تدريب داخل أقسام تشغيل الشبكات وخدمة العملاء للطلبة المهتمين بمجال الاتصالات.',
      'isAvailable': false,
      'specialization': 'اتصالات',
      'location': 'بنغازي',
      'duration': 'شهر',
    },
    {
      'title': 'تدريب في أنظمة التحكم الصناعي',
      'company': 'الواحة للنفط',
      'image': 'assets/images/waha.JPG',
      'desc':
          'فرصة مميزة للتدريب في مجالات التحكم الآلي والأنظمة الصناعية داخل الشركة.',
      'isAvailable': true,
      'specialization': 'تحكم آلي',
      'location': 'سرت',
      'duration': '3 أشهر',
    },
    {
      'title': 'تدريب في الدعم الفني والشبكات',
      'company': 'ليبيانا',
      'image': 'assets/images/libyana.JPG',
      'desc':
          'تدريب ميداني موجه لطلبة الاتصالات وتقنية المعلومات داخل أقسام الدعم الفني.',
      'isAvailable': true,
      'specialization': 'اتصالات',
      'location': 'طرابلس',
      'duration': 'شهرين',
    },
    {
      'title': 'تدريب في أنظمة التشغيل والتحكم',
      'company': 'مليته للنفط',
      'image': 'assets/images/oil.JPG',
      'desc':
          'برنامج تدريب ميداني للطلاب المهتمين بمجال التحكم الآلي داخل قطاع النفط والغاز.',
      'isAvailable': false,
      'specialization': 'تحكم آلي',
      'location': 'مليته',
      'duration': 'شهرين',
    },
    {
      'title': 'تدريب في الأنظمة المصرفية',
      'company': 'مصرف الجمهورية',
      'image': 'assets/images/bank.jpg',
      'desc':
          'فرصة تدريب للطلاب في مجالات الحاسب الآلي والأنظمة البنكية والدعم التقني.',
      'isAvailable': false,
      'specialization': 'حاسب آلي',
      'location': 'طرابلس',
      'duration': 'شهر',
    },
  ];

  List<Map<String, dynamic>> displayedOpportunities = [];
  String selectedCompany = "الكل";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    displayedOpportunities = allOpportunities;
  }

  void _applyFilters() {
    setState(() {
      displayedOpportunities =
          allOpportunities.where((item) {
            final title = item['title'].toString().toLowerCase();
            final company = item['company'].toString().toLowerCase();

            final matchesSearch =
                title.contains(searchQuery.toLowerCase()) ||
                company.contains(searchQuery.toLowerCase());

            final matchesCompany =
                selectedCompany == "الكل" || item['company'] == selectedCompany;

            return matchesSearch && matchesCompany;
          }).toList();
    });
  }

  List<String> get companyFilters {
    final companies =
        allOpportunities.map((e) => e['company'].toString()).toSet().toList();
    companies.sort();
    return ['الكل', ...companies];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FC),
        surfaceTintColor: const Color(0xFFF8F8FC),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "فرص التدريب",
              style: TextStyle(
                color: primarycolor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "استعرض الفرص المتاحة حسب الشركة",
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.45),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 18),
            _buildSearchAndFilterRow(),
            const SizedBox(height: 18),
            Expanded(
              child:
                  displayedOpportunities.isEmpty
                      ? const _EmptyState()
                      : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.74,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: displayedOpportunities.length,
                        itemBuilder: (context, index) {
                          final item = displayedOpportunities[index];
                          return _buildOpportunityCard(
                            context,
                            title: item['title'],
                            company: item['company'],
                            imagePath: item['image'],
                            desc: item['desc'],
                            isAvailable: item['isAvailable'],
                            specialization: item['specialization'],
                            location: item['location'],
                            duration: item['duration'],
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primarycolor.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: PopupMenuButton<String>(
            borderRadius: BorderRadius.circular(16),
            icon: Icon(
              Icons.filter_list_rounded,
              color: primarycolor,
              size: 24,
            ),
            onSelected: (String newValue) {
              selectedCompany = newValue;
              _applyFilters();
            },
            itemBuilder:
                (BuildContext context) =>
                    companyFilters
                        .map(
                          (company) => PopupMenuItem<String>(
                            value: company,
                            child: Text(company),
                          ),
                        )
                        .toList(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primarycolor.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              textAlign: TextAlign.right,
              onChanged: (value) {
                searchQuery = value;
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: "ابحث عن فرصة أو شركة...",
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                border: InputBorder.none,
                suffixIcon: Icon(Icons.search_rounded, color: primarycolor),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOpportunityCard(
    BuildContext context, {
    required String title,
    required String company,
    required String imagePath,
    required String desc,
    required bool isAvailable,
    required String specialization,
    required String location,
    required String duration,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CompanyDetailsPage(
                  opportunityTitle: title,
                  companyName: company,
                  description: desc,
                  logoPath: imagePath,
                  isAvailable: isAvailable,
                  specialization: specialization,
                  location: location,
                  duration: duration,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(imagePath, fit: BoxFit.cover),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.82),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isAvailable
                                  ? Colors.green.withValues(alpha: 0.18)
                                  : Colors.red.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isAvailable ? "متاح" : "مغلق",
                          style: TextStyle(
                            color:
                                isAvailable
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      left: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  children: [
                    _infoRow(icon: Icons.school_outlined, text: specialization),
                    const SizedBox(height: 6),
                    _infoRow(icon: Icons.location_on_outlined, text: location),
                    const SizedBox(height: 6),
                    _infoRow(icon: Icons.access_time_rounded, text: duration),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: primarycolor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.70),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 52,
            color: Colors.grey.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          const Text(
            "لا توجد فرص مطابقة",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "جرّب تغيير البحث أو اختيار شركة مختلفة",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
