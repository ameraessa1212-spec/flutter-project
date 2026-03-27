import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/applications/repositories/application_repository.dart';
import 'package:Waslaa/features/opportunities/models/opportunity.dart';

class ApplyInternshipPage extends StatefulWidget {
  final Opportunity opportunity;

  const ApplyInternshipPage({super.key, required this.opportunity});

  @override
  State<ApplyInternshipPage> createState() => _ApplyInternshipPageState();
}

class _ApplyInternshipPageState extends State<ApplyInternshipPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();

  bool _agreed = false;
  bool _isSubmitting = false;
  String? _selectedCvPath;
  String? _selectedCvName;
  List<int>? _selectedCvBytes;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickCvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (kIsWeb) {
          _selectedCvBytes = result.files.first.bytes;
        } else {
          _selectedCvPath = result.files.first.path;
        }
        _selectedCvName = result.files.first.name;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCvPath == null && _selectedCvBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إرفاق السيرة الذاتية (PDF) قبل الإرسال'),
        ),
      );
      return;
    }

    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الموافقة على صحة البيانات قبل الإرسال'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<ApplicationRepository>();
      await repo.apply(
        opportunityId: widget.opportunity.id,
        notes:
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
        cvFilePath: _selectedCvPath,
        cvFileBytes: _selectedCvBytes,
        cvFileName: _selectedCvName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال طلب التدريب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'حدث خطأ أثناء إرسال الطلب'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      prefixIcon: icon != null ? Icon(icon, color: primarycolor) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primarycolor.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primarycolor.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primarycolor, width: 1.5),
      ),
    );
  }

  Widget _miniInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primarycolor.withOpacity(0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primarycolor, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black.withOpacity(0.50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opp = widget.opportunity;
    final companyName = opp.company?.name ?? '';
    final spec = opp.specialization?.name ?? '';
    final location = opp.locationText ?? opp.city ?? '';
    final duration = opp.durationText ?? '';

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
            'طلب تدريب',
            style: TextStyle(color: primarycolor, fontSize: 20),
          ),
          iconTheme: IconThemeData(color: primarycolor),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقة الفرصة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primarycolor, primarycolor.withOpacity(0.82)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: primarycolor.withOpacity(0.20),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (companyName.isNotEmpty)
                        Text(
                          companyName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        opp.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (spec.isNotEmpty)
                            _miniInfoCard(
                              icon: Icons.school_outlined,
                              title: 'التخصص',
                              value: spec,
                            ),
                          if (spec.isNotEmpty && location.isNotEmpty)
                            const SizedBox(width: 10),
                          if (location.isNotEmpty)
                            _miniInfoCard(
                              icon: Icons.location_on_outlined,
                              title: 'الموقع',
                              value: location,
                            ),
                          if (location.isNotEmpty && duration.isNotEmpty)
                            const SizedBox(width: 10),
                          if (duration.isNotEmpty)
                            _miniInfoCard(
                              icon: Icons.access_time_rounded,
                              title: 'المدة',
                              value: duration,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // السيرة الذاتية
                const Text(
                  'السيرة الذاتية',
                  style: TextStyle(fontSize: 17, color: Colors.black),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickCvFile,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: primarycolor.withOpacity(0.12)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.upload_file_rounded, color: primarycolor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedCvName ??
                                'اختر ملف السيرة الذاتية (PDF / Word)',
                            style: TextStyle(
                              color:
                                  _selectedCvName == null
                                      ? Colors.black.withOpacity(0.55)
                                      : Colors.black,
                              fontSize: 13,
                              fontWeight:
                                  _selectedCvName == null
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_selectedCvName != null)
                          GestureDetector(
                            onTap:
                                () => setState(() {
                                  _selectedCvPath = null;
                                  _selectedCvBytes = null;
                                  _selectedCvName = null;
                                }),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // رسالة تعريفية
                const Text(
                  'رسالة تعريفية',
                  style: TextStyle(fontSize: 17, color: Colors.black),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  maxLines: 5,
                  decoration: _inputDecoration(
                    'اكتب نبذة قصيرة عنك ولماذا ترغب في هذه الفرصة',
                  ),
                ),

                const SizedBox(height: 14),
                CheckboxListTile(
                  value: _agreed,
                  onChanged:
                      (value) => setState(() => _agreed = value ?? false),
                  activeColor: primarycolor,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'أتعهد بأن جميع البيانات المدخلة صحيحة',
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primarycolor,
                    disabledBackgroundColor: Colors.grey.shade300,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.3,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'إرسال الطلب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
