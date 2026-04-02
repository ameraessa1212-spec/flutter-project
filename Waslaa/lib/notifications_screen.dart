import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/notifications/models/notification_model.dart';
import 'package:Waslaa/features/notifications/repositories/notification_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<NotificationRepository>();
      final list = await repo.getNotifications(perPage: 30);
      if (!mounted) return;
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'حدث خطأ أثناء تحميل الإشعارات';
        _isLoading = false;
      });
    }
  }

  Future<void> _markRead(AppNotification notification) async {
    if (notification.isRead) return;
    try {
      final repo = context.read<NotificationRepository>();
      await repo.markRead(notification.id);
      if (!mounted) return;
      setState(() {
        final idx = _notifications.indexWhere((n) => n.id == notification.id);
        if (idx >= 0) {
          _notifications[idx] = notification.copyWith(isRead: true);
        }
      });
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      final repo = context.read<NotificationRepository>();
      await repo.markAllRead();
      if (!mounted) return;
      setState(() {
        _notifications =
            _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'حدث خطأ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'الإشعارات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: primarycolor,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: primarycolor,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 8),
              child: TextButton(
                onPressed: _markAllRead,
                child: Text(
                  'قراءة الكل',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: primarycolor,
                  ),
                ),
              ),
            ),
        ],
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
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    if (_notifications.isEmpty) return _buildEmptyState();
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: _buildNotificationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/notifications.png',
              width: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            const Text(
              'لا توجد إشعارات حاليًا',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ستظهر إشعاراتك هنا عند توفرها',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _notifications.length,
      separatorBuilder:
          (_, __) => Divider(
            color: primarycolor.withValues(alpha: 0.1),
            thickness: 1,
            height: 30,
          ),
      itemBuilder: (context, index) {
        final n = _notifications[index];
        return GestureDetector(
          onTap: () => _markRead(n),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(n.createdAt),
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            n.title,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  n.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                              color: const Color(0xFF4A4A4A),
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n.body,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: Color(0xFF4A4A4A),
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primarycolor.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mail_outline,
                            color: primarycolor,
                            size: 16,
                          ),
                        ),
                        if (!n.isRead)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0019B7),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate.split('T').first;
    }
  }
}
