import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/core/session/app_session_controller.dart';
import 'package:Waslaa/features/internships/models/internship.dart';
import 'package:Waslaa/features/internships/repositories/internship_repository.dart';
import 'package:Waslaa/features/profile/models/user_profile.dart';
import 'package:Waslaa/features/profile/repositories/profile_repository.dart';

class AccountPage extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const AccountPage({super.key, this.scaffoldKey});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  UserProfile? _profile;
  Internship? _currentInternship;
  List<TimelineItem> _timeline = [];
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
      final profileRepo = context.read<ProfileRepository>();
      final internshipRepo = context.read<InternshipRepository>();

      final results = await Future.wait([
        profileRepo.getProfile(),
        internshipRepo.getCurrentInternship(),
      ]);

      final profile = results[0] as UserProfile;
      final internship = results[1] as Internship?;

      List<TimelineItem> timeline = [];
      if (internship != null) {
        timeline = await internshipRepo.getTimeline(internship.id);
      }

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _currentInternship = internship;
        _timeline = timeline;
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "حسابي",
          style: TextStyle(
            color: primarycolor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadData, child: const Text('إعادة المحاولة')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          _buildProfileHeader(),
                          const SizedBox(height: 30),
                          _buildStatusTimeline(),
                          if (_currentInternship != null) ...[
                            const SizedBox(height: 30),
                            _buildInternshipDates(),
                          ],
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    final sessionUser = context.read<AppSessionController>().currentUser;
    final displayName = _profile?.name ?? sessionUser?.name ?? 'مستخدم';
    final studentNumber = _profile?.studentProfile?.studentNumber;
    final specialization = _profile?.studentProfile?.specializationName;
    final avatarPath = _profile?.studentProfile?.profileImagePath;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primarycolor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: avatarPath != null ? NetworkImage(avatarPath) : null,
            child: avatarPath == null
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (studentNumber != null)
                  Text(
                    'رقم القيد: $studentNumber',
                    style: const TextStyle(color: Colors.grey),
                  ),
                if (specialization != null)
                  Text(
                    specialization,
                    style: TextStyle(
                      color: primarycolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    if (_currentInternship == null && _timeline.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'لا يوجد تدريب نشط حالياً',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    if (_timeline.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "فترة التدريب",
            style: TextStyle(color: primarycolor, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_timeline.length, (index) {
            final item = _timeline[index];
            final isCompleted = item.status == 'completed' || item.status == 'current';
            return Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: index == 0
                              ? Colors.transparent
                              : (isCompleted ? primarycolor : Colors.grey[300]),
                          thickness: 2,
                        ),
                      ),
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.circle,
                        size: 16,
                        color: isCompleted ? primarycolor : Colors.grey[300],
                      ),
                      Expanded(
                        child: Divider(
                          color: index == _timeline.length - 1
                              ? Colors.transparent
                              : (item.status == 'completed' ? primarycolor : Colors.grey[300]),
                          thickness: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _timelineLabel(item.key),
                    style: TextStyle(
                      fontSize: 8,
                      color: isCompleted ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  String _timelineLabel(String key) {
    switch (key) {
      case 'accepted':
        return 'تم القبول';
      case 'started':
        return 'بدء التدريب';
      case 'in_progress':
        return 'قيد التدريب';
      case 'completed':
        return 'انتهاء التدريب';
      case 'report_submitted':
        return 'تسليم التقرير';
      default:
        return key;
    }
  }

  Widget _buildInternshipDates() {
    final internship = _currentInternship!;
    return Column(
      children: [
        _buildDateRow("تاريخ بداية التدريب", internship.startDate),
        const SizedBox(height: 25),
        _buildDateRow("تاريخ نهاية التدريب", internship.endDate),
      ],
    );
  }

  Widget _buildDateRow(String title, String? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.calendar_month, color: primarycolor),
              Text(
                date ?? 'غير محدد',
                style: TextStyle(
                  color: date != null ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
