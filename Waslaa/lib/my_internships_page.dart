import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/chat_page.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/applications/models/application.dart';
import 'package:Waslaa/features/applications/repositories/application_repository.dart';
import 'package:Waslaa/features/internships/models/internship.dart';
import 'package:Waslaa/features/internships/repositories/internship_repository.dart';
import 'package:Waslaa/reports_page.dart';

class MyInternshipsPage extends StatefulWidget {
  const MyInternshipsPage({super.key});

  @override
  State<MyInternshipsPage> createState() => _MyInternshipsPageState();
}

class _MyInternshipsPageState extends State<MyInternshipsPage> {
  Internship? _currentInternship;
  List<Application> _applications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final internshipRepo = context.read<InternshipRepository>();
      final applicationRepo = context.read<ApplicationRepository>();

      final results = await Future.wait([
        internshipRepo.getCurrentInternship(),
        applicationRepo.getApplications(perPage: 20),
      ]);

      if (!mounted) return;
      setState(() {
        _currentInternship = results[0] as Internship?;
        _applications = results[1] as List<Application>;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'حدث خطأ أثناء تحميل البيانات';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FC),
        surfaceTintColor: const Color(0xFFF8F8FC),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'تدريباتي',
          style: TextStyle(
            color: primarycolor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildContent() {
    final internship = _currentInternship;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InternshipSummaryCard(
            applicationsCount: _applications.length,
          ),
          const SizedBox(height: 18),

          const _SectionTitle(title: 'التدريب الحالي'),
          const SizedBox(height: 10),

          if (internship != null)
            _CurrentInternshipCard(internship: internship)
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'لا يوجد تدريب نشط حالياً',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),

          const SizedBox(height: 22),
          const _SectionTitle(title: 'إجراءات سريعة'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: 'رفع التقرير',
                  subtitle: 'إرسال التقرير الأسبوعي',
                  icon: Icons.upload_file_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportsPage(
                          internshipId: internship?.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  title: 'التواصل مع المشرف',
                  subtitle: 'فتح المحادثة الحالية',
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          if (_applications.isNotEmpty) ...[
            const SizedBox(height: 22),
            const _SectionTitle(title: 'طلباتي'),
            const SizedBox(height: 10),
            ..._applications.map((app) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ApplicationStatusCard(application: app),
                )),
          ],
        ],
      ),
    );
  }
}

class _InternshipSummaryCard extends StatelessWidget {
  final int applicationsCount;

  const _InternshipSummaryCard({this.applicationsCount = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primarycolor, primarycolor.withOpacity(0.82)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primarycolor.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'متابعة رحلتك التدريبية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اطلع على طلبك، حالة تدريبك الحالي، والتقارير المرفوعة من مكان واحد.',
            style: TextStyle(
                color: Colors.white70, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryMiniBox(
                  title: 'الطلبات',
                  value: applicationsCount.toString(),
                  icon: Icons.description_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMiniBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryMiniBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 19),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CurrentInternshipCard extends StatelessWidget {
  final Internship internship;

  const _CurrentInternshipCard({required this.internship});

  @override
  Widget build(BuildContext context) {
    final company = internship.company;
    final opportunity = internship.opportunity;
    final supervisor = internship.supervisor;
    final location =
        opportunity?.locationText ?? opportunity?.city ?? '';
    final duration = opportunity?.durationText ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(internship.status),
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (company != null)
                Text(
                  company.name,
                  style: TextStyle(
                    color: primarycolor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            internship.title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          if (location.isNotEmpty || duration.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (location.isNotEmpty)
                  Expanded(
                    child: _SmallInfoChip(
                      icon: Icons.location_on_outlined,
                      text: location,
                    ),
                  ),
                if (location.isNotEmpty && duration.isNotEmpty)
                  const SizedBox(width: 8),
                if (duration.isNotEmpty)
                  Expanded(
                    child: _SmallInfoChip(
                      icon: Icons.access_time_rounded,
                      text: duration,
                    ),
                  ),
              ],
            ),
          ],
          if (supervisor != null) ...[
            const SizedBox(height: 12),
            Text(
              'المشرف: ${supervisor.name}',
              style: TextStyle(
                color: Colors.black.withOpacity(0.65),
                fontSize: 13,
              ),
            ),
          ],
          if (internship.reportDueDate != null) ...[
            const SizedBox(height: 6),
            Text(
              'آخر موعد لرفع التقرير: ${internship.reportDueDate}',
              style: TextStyle(
                color: Colors.black.withOpacity(0.65),
                fontSize: 13,
              ),
            ),
          ],
          if (internship.startDate != null || internship.endDate != null) ...[
            const SizedBox(height: 6),
            Text(
              '${internship.startDate ?? ''} - ${internship.endDate ?? ''}',
              style: TextStyle(
                color: Colors.black.withOpacity(0.55),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'نشط الآن';
      case 'completed':
        return 'مكتمل';
      case 'pending':
        return 'معلق';
      default:
        return status;
    }
  }
}

class _SmallInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallInfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primarycolor.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primarycolor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 122,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: primarycolor.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primarycolor, size: 26),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.black.withOpacity(0.55),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationStatusCard extends StatelessWidget {
  final Application application;

  const _ApplicationStatusCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(application.status);
    final statusLabel = _statusLabel(application.status);
    final companyName = application.company?.name ?? '';
    final opportunityTitle = application.opportunity?.title ?? '';
    final date = application.submittedAt != null
        ? _formatDate(application.submittedAt!)
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (companyName.isNotEmpty)
                  Text(
                    companyName,
                    style: TextStyle(
                      color: primarycolor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  opportunityTitle,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'تاريخ التقديم: $date',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.50),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'pending':
        return 'قيد المراجعة';
      default:
        return status;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate.split('T').first;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
