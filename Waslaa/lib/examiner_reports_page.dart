import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Waslaa/features/reports/models/report.dart';
import 'package:Waslaa/features/reports/repositories/report_repository.dart';

class ExaminerReportsPage extends StatefulWidget {
  const ExaminerReportsPage({super.key});

  @override
  State<ExaminerReportsPage> createState() => _ExaminerReportsPageState();
}

class _ExaminerReportsPageState extends State<ExaminerReportsPage> {
  static const Color _primary = Color(0xFF6A5AE0);

  List<Report> _reports = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = 'all';

  final List<Map<String, String>> _statusFilters = [
    {'label': 'الكل', 'value': 'all'},
    {'label': 'قيد الانتظار', 'value': 'pending'},
    {'label': 'مقبول', 'value': 'approved'},
    {'label': 'مرفوض', 'value': 'rejected'},
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<ReportRepository>();
      final list = await repo.getExaminerReports(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );
      if (!mounted) return;
      setState(() {
        _reports = list;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'حدث خطأ أثناء تحميل التقارير';
        _isLoading = false;
      });
    }
  }

  Future<void> _openFile(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showEvaluationDialog(Report report) async {
    final notesController = TextEditingController(text: report.reviewNotes);
    String selectedAction = 'approved';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  'تقييم التقرير',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      report.title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (report.studentName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'الطالب: ${report.studentName}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'القرار:',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionChip(
                            label: 'قبول',
                            icon: Icons.check_circle_outline,
                            selected: selectedAction == 'approved',
                            color: Colors.green,
                            onTap: () =>
                                setDialogState(() => selectedAction = 'approved'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionChip(
                            label: 'رفض',
                            icon: Icons.cancel_outlined,
                            selected: selectedAction == 'rejected',
                            color: Colors.red,
                            onTap: () =>
                                setDialogState(() => selectedAction = 'rejected'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      style: const TextStyle(fontFamily: 'Cairo'),
                      decoration: InputDecoration(
                        hintText: 'ملاحظات المراجعة (اختياري)',
                        hintStyle: const TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _primary),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _submitEvaluation(
                        report: report,
                        status: selectedAction,
                        notes: notesController.text.trim(),
                      );
                    },
                    child: const Text(
                      'حفظ',
                      style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitEvaluation({
    required Report report,
    required String status,
    String? notes,
  }) async {
    try {
      final repo = context.read<ReportRepository>();
      final updated = await repo.evaluateReport(
        reportId: report.id,
        status: status,
        reviewNotes: notes,
      );
      if (!mounted) return;
      setState(() {
        final idx = _reports.indexWhere((r) => r.id == report.id);
        if (idx >= 0) _reports[idx] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved' ? 'تم قبول التقرير بنجاح' : 'تم رفض التقرير',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: status == 'approved' ? Colors.green : Colors.red,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'حدث خطأ أثناء حفظ التقييم',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F7FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 70,
          title: const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'تقييم التقارير',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: _primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: _primary, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: Column(
          children: [
            // Status filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  children: _statusFilters.map((filter) {
                    final isSelected = _selectedStatus == filter['value'];
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(
                          filter['label']!,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: isSelected ? Colors.white : _primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: _primary,
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: _primary),
                        onSelected: (_) {
                          setState(() => _selectedStatus = filter['value']!);
                          _loadReports();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadReports,
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'لا توجد تقارير في الوقت الحالي',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey[500],
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _reports.length,
        itemBuilder: (_, index) => _ReportCard(
          report: _reports[index],
          onEvaluate: () => _showEvaluationDialog(_reports[index]),
          onOpenFile: () => _openFile(_reports[index].filePath),
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: selected ? color : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.onEvaluate,
    required this.onOpenFile,
  });

  final Report report;
  final VoidCallback onEvaluate;
  final VoidCallback onOpenFile;

  static const Color _primary = Color(0xFF6A5AE0);

  Color get _statusColor {
    switch (report.status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String get _statusLabel {
    switch (report.status) {
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'قيد الانتظار';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (report.studentName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'الطالب: ${report.studentName}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (report.submittedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'تاريخ التسليم: ${report.submittedAt!.split('T').first}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (report.reviewNotes != null &&
                report.reviewNotes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  'ملاحظة: ${report.reviewNotes}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (report.filePath != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onOpenFile,
                      icon: const Icon(Icons.download_outlined, size: 16),
                      label: const Text(
                        'عرض الملف',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: _primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                if (report.filePath != null) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEvaluate,
                    icon: const Icon(Icons.rate_review_outlined, size: 16),
                    label: const Text(
                      'تقييم',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
