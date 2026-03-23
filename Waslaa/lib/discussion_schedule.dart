import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/features/discussion_schedules/models/discussion_schedule.dart';
import 'package:Waslaa/features/discussion_schedules/repositories/discussion_schedule_repository.dart';

class DiscussionSchedulePage extends StatefulWidget {
  const DiscussionSchedulePage({super.key});

  @override
  State<DiscussionSchedulePage> createState() => _DiscussionSchedulePageState();
}

class _DiscussionSchedulePageState extends State<DiscussionSchedulePage> {
  List<DiscussionSchedule> _schedules = [];
  bool _isLoading = true;
  String? _error;

  static const Color primary = Color(0xFF6A5AE0);

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<DiscussionScheduleRepository>();
      final list = await repo.getSchedules();
      if (!mounted) return;
      setState(() {
        _schedules = list;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'حدث خطأ أثناء تحميل المواعيد';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,
        title: const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            'جدول مواعيد المناقشات',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: primary, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSchedules,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    if (_schedules.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد مواعيد مناقشات حاليًا',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: ListView.builder(
        padding: const EdgeInsets.only(
            top: 20.0, left: 20.0, right: 20.0, bottom: 40.0),
        itemCount: _schedules.length,
        itemBuilder: (context, index) =>
            _buildScheduleCard(_schedules[index]),
      ),
    );
  }

  Widget _buildScheduleCard(DiscussionSchedule schedule) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // عنوان وتخصص
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (schedule.academicTerm != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    schedule.academicTerm!,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: primary,
                    ),
                  ),
                ),
              Text(
                schedule.title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),

          if (schedule.specializationName != null) ...[
            const SizedBox(height: 6),
            Text(
              schedule.specializationName!,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],

          if (schedule.description != null && schedule.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              schedule.description!,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                height: 1.6,
                color: Color(0xFF616161),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // صورة الجدول إن وجدت
          if (schedule.scheduleImagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                schedule.scheduleImagePath!,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
              ),
            )
          else
            _buildImagePlaceholder(),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_search_outlined,
              size: 50, color: primary.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text(
            'سيتم عرض صورة الجدول هنا عند توفرها',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: primary),
          ),
        ],
      ),
    );
  }
}
