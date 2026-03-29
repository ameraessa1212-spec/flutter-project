import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/reports/models/report.dart';
import 'package:Waslaa/features/reports/repositories/report_repository.dart';

class ReportsPage extends StatefulWidget {
  final int? internshipId;

  const ReportsPage({super.key, this.internshipId});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final Color primaryColor = primarycolor;
  List<PlatformFile> selectedFiles = [];
  List<Report> _submittedReports = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String _selectedReportType = 'field_report';

  static const Map<String, String> _reportTypeLabels = {
    'field_report': 'التقرير الميداني',
    'research_paper': 'البحث العلمي',
  };

  @override
  void initState() {
    super.initState();
    if (widget.internshipId != null) {
      _loadReports();
    }
  }

  Future<void> _loadReports() async {
    if (widget.internshipId == null) return;
    setState(() => _isLoading = true);
    try {
      final repo = context.read<ReportRepository>();
      final list = await repo.getReports(widget.internshipId!);
      if (!mounted) return;
      setState(() {
        _submittedReports = list;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFiles() async {
    if (widget.internshipId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد تدريب نشط متاح لرفع التقارير.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (selectedFiles.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "يمكنك رفع ملفين فقط: التقرير والبحث العلمي.",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        selectedFiles.add(result.files.first);
      });
    }
  }

  void _clearFiles() {
    setState(() {
      selectedFiles.clear();
    });
  }

  Set<String> get _submittedReportTypes {
    return _submittedReports.map((r) => r.reportType).toSet();
  }

  List<String> get _availableReportTypes {
    return _reportTypeLabels.keys
        .where((type) => !_submittedReportTypes.contains(type))
        .toList();
  }

  Future<void> _submitFiles() async {
    if (selectedFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار ملف أولاً')));
      return;
    }

    if (widget.internshipId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد تدريب نشط مرتبط برفع التقارير.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_submittedReportTypes.contains(_selectedReportType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لقد تم رفع هذا النوع من التقارير مسبقاً.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = context.read<ReportRepository>();
      for (final file in selectedFiles) {
        if (file.path == null && file.bytes == null) continue;
        await repo.submitReport(
          internshipId: widget.internshipId!,
          title: _reportTypeLabels[_selectedReportType] ?? file.name,
          reportType: _selectedReportType,
          filePath: file.path,
          fileBytes: file.bytes,
          fileName: file.name,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال التقرير بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => selectedFiles.clear());
      _loadReports();
    } on DioException catch (e) {
      if (!mounted) return;
      final errorMsg = e.response?.data is Map
          ? (e.response!.data as Map)['message'] as String?
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg ?? e.message ?? 'حدث خطأ أثناء الإرسال'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F8FC),
          surfaceTintColor: const Color(0xFFF8F8FC),
          elevation: 0,
          centerTitle: true,
          title: Text(
            "التقارير",
            style: TextStyle(fontSize: 20, color: primaryColor),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 18),
              _buildReportTypeSelector(),
              const SizedBox(height: 18),
              _buildUploadSection(),
              const SizedBox(height: 18),
              if (selectedFiles.isNotEmpty) ...[
                const _SectionTitle(title: "الملفات المختارة"),
                const SizedBox(height: 10),
                ...selectedFiles.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildSelectedFileCard(entry.value, entry.key),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        "إلغاء الكل",
                        Colors.redAccent,
                        _clearFiles,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionButton(
                        "إرسال الملفات",
                        primaryColor,
                        _isSubmitting ? null : _submitFiles,
                      ),
                    ),
                  ],
                ),
              ],
              if (_isLoading) ...[
                const SizedBox(height: 18),
                const Center(child: CircularProgressIndicator()),
              ] else if (_submittedReports.isNotEmpty) ...[
                const SizedBox(height: 22),
                const _SectionTitle(title: "التقارير المرفوعة"),
                const SizedBox(height: 10),
                ..._submittedReports.map(
                  (report) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildSubmittedReportCard(report),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.82)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "رفع التقارير الأكاديمية",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "يمكنك من هنا رفع التقرير الميداني والبحث العلمي بصيغة PDF أو Word، ثم إرسالها للمراجعة.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.7),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    final available = _availableReportTypes;
    if (available.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.20)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'تم رفع جميع أنواع التقارير المطلوبة.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    // Auto-select first available type if current selection is already submitted
    if (_submittedReportTypes.contains(_selectedReportType) && available.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedReportType = available.first);
      });
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نوع التقرير',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 12),
          ..._reportTypeLabels.entries.map((entry) {
            final isSubmitted = _submittedReportTypes.contains(entry.key);
            final isSelected = _selectedReportType == entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: isSubmitted ? null : () => setState(() => _selectedReportType = entry.key),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSubmitted
                        ? Colors.grey.withValues(alpha: 0.08)
                        : isSelected
                            ? primaryColor.withValues(alpha: 0.10)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSubmitted
                          ? Colors.grey.withValues(alpha: 0.20)
                          : isSelected
                              ? primaryColor.withValues(alpha: 0.40)
                              : primaryColor.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSubmitted
                            ? Icons.check_circle_rounded
                            : isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                        color: isSubmitted ? Colors.green : isSelected ? primaryColor : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSubmitted ? Colors.grey : Colors.black,
                        ),
                      ),
                      if (isSubmitted) ...[
                        const Spacer(),
                        const Text(
                          'تم الرفع',
                          style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 220),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FC),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.18),
                width: 1.2,
              ),
            ),
            child:
                selectedFiles.isEmpty
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: 40,
                            color: Colors.blue.shade400,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "رفع ملفات التقرير الميداني والبحث العلمي",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "الملفات المسموح بها: PDF - DOC - DOCX\nالحد الأقصى: ملفان فقط",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.black.withValues(alpha: 0.55),
                            height: 1.7,
                          ),
                        ),
                      ],
                    )
                    : Column(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 42,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "تم اختيار الملفات بنجاح",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "يمكنك مراجعة الملفات المختارة بالأسفل قبل الإرسال",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.black.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 190,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _pickFiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.attach_file_rounded, color: Colors.white),
              label: const Text(
                "اختيار ملف",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFileCard(PlatformFile file, int index) {
    final isPdf = file.extension?.toLowerCase() == 'pdf';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color:
                  isPdf
                      ? Colors.red.withValues(alpha: 0.10)
                      : Colors.blue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
              color: isPdf ? Colors.redAccent : Colors.blueAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 1,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "جاهز للإرسال",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.black.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => setState(() => selectedFiles.removeAt(index)),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedReportCard(Report report) {
    final statusColor =
        report.status == 'approved'
            ? Colors.green
            : report.status == 'rejected'
            ? Colors.red
            : report.status == 'submitted'
            ? Colors.blue
            : Colors.orange;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.description_rounded,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.submittedAt != null
                      ? 'تم الرفع: ${report.submittedAt!.split('T').first}'
                      : 'معلق',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.black.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _reportStatusLabel(report.status),
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

  String _reportStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'pending':
        return 'قيد المراجعة';
      case 'submitted':
        return 'تم الإرسال';
      case 'reviewed':
        return 'تمت المراجعة';
      case 'draft':
        return 'مسودة';
      default:
        return status;
    }
  }

  Widget _actionButton(String label, Color color, VoidCallback? onTap) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
