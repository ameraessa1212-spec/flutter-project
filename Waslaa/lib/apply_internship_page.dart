import 'package:flutter/material.dart';
import 'package:Waslaa/const/color.dart';

class ApplyInternshipPage extends StatefulWidget {
  final String opportunityTitle;
  final String companyName;
  final String specialization;
  final String location;
  final String duration;

  const ApplyInternshipPage({
    super.key,
    required this.opportunityTitle,
    required this.companyName,
    required this.specialization,
    required this.location,
    required this.duration,
  });

  @override
  State<ApplyInternshipPage> createState() => _ApplyInternshipPageState();
}

class _ApplyInternshipPageState extends State<ApplyInternshipPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _agreed = false;
  bool _isSubmitting = false;
  String? _selectedCvName;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _levelController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _pickCvFile() {
    setState(() {
      _selectedCvName = "cv_moad_ben_yousef.pdf";
    });
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى الموافقة على صحة البيانات قبل الإرسال"),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("تم إرسال طلب التدريب بنجاح")));

    Navigator.pop(context);
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
        borderSide: BorderSide(color: primarycolor.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primarycolor.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primarycolor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, color: Colors.black),
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
          border: Border.all(color: primarycolor.withValues(alpha: 0.10)),
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
                color: Colors.black.withValues(alpha: 0.50),
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
            "طلب تدريب",
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primarycolor,
                        primarycolor.withValues(alpha: 0.82),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: primarycolor.withValues(alpha: 0.20),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.companyName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.opportunityTitle,
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
                          _miniInfoCard(
                            icon: Icons.school_outlined,
                            title: "التخصص",
                            value: widget.specialization,
                          ),
                          const SizedBox(width: 10),
                          _miniInfoCard(
                            icon: Icons.location_on_outlined,
                            title: "الموقع",
                            value: widget.location,
                          ),
                          const SizedBox(width: 10),
                          _miniInfoCard(
                            icon: Icons.access_time_rounded,
                            title: "المدة",
                            value: widget.duration,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _sectionTitle("بيانات الطالب"),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    "الاسم الكامل",
                    icon: Icons.person_outline,
                  ),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? "يرجى إدخال الاسم"
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(
                    "رقم الهاتف",
                    icon: Icons.phone_outlined,
                  ),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? "يرجى إدخال رقم الهاتف"
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    "البريد الإلكتروني",
                    icon: Icons.email_outlined,
                  ),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? "يرجى إدخال البريد الإلكتروني"
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _universityController,
                  decoration: _inputDecoration(
                    "الجامعة",
                    icon: Icons.account_balance_outlined,
                  ),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? "يرجى إدخال اسم الجامعة"
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _majorController,
                  decoration: _inputDecoration(
                    "التخصص",
                    icon: Icons.menu_book_outlined,
                  ),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? "يرجى إدخال التخصص"
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _levelController,
                  decoration: _inputDecoration(
                    "السنة الدراسية / الفصل",
                    icon: Icons.school_outlined,
                  ),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? "يرجى إدخال السنة الدراسية أو الفصل"
                              : null,
                ),
                const SizedBox(height: 22),
                _sectionTitle("السيرة الذاتية"),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickCvFile,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: primarycolor.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.upload_file_rounded, color: primarycolor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedCvName ??
                                "اختر ملف السيرة الذاتية (PDF / Word)",
                            style: TextStyle(
                              color:
                                  _selectedCvName == null
                                      ? Colors.black.withValues(alpha: 0.55)
                                      : Colors.black,
                              fontSize: 13,
                              fontWeight:
                                  _selectedCvName == null
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _sectionTitle("رسالة تعريفية"),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  maxLines: 5,
                  decoration: _inputDecoration(
                    "اكتب نبذة قصيرة عنك ولماذا ترغب في هذه الفرصة",
                  ),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? "يرجى كتابة رسالة تعريفية قصيرة"
                              : null,
                ),
                const SizedBox(height: 14),
                CheckboxListTile(
                  value: _agreed,
                  onChanged: (value) {
                    setState(() {
                      _agreed = value ?? false;
                    });
                  },
                  activeColor: primarycolor,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "أتعهد بأن جميع البيانات المدخلة صحيحة",
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
                            "إرسال الطلب",
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
