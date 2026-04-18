import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/core/config/app_config.dart';

class DevToolScreen extends StatefulWidget {
  const DevToolScreen({super.key});

  @override
  State<DevToolScreen> createState() => _DevToolScreenState();
}

class _DevToolScreenState extends State<DevToolScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isTesting = false;
  String? _testResult;
  bool? _testSuccess;

  static const List<_PresetUrl> _presets = [
    _PresetUrl(label: 'Local (localhost:9000)', url: 'http://localhost:9000/'),
    _PresetUrl(label: 'Local (10.0.2.2:9000) - Emulator', url: 'http://10.0.2.2:9000/'),
    _PresetUrl(label: 'Production', url: 'https://api.waslaa.com/'),
  ];

  @override
  void initState() {
    super.initState();
    _urlController.text = AppConfig.apiBaseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
      _testSuccess = null;
    });

    try {
      final normalizedUrl = url.replaceAll(RegExp(r'/+$'), '');
      final testUrl = normalizedUrl.endsWith('/api/mobile/v1')
          ? normalizedUrl
          : '$normalizedUrl/api/mobile/v1';

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      final response = await dio.get(testUrl);
      setState(() {
        _testSuccess = true;
        _testResult = 'اتصال ناجح (${response.statusCode})';
      });
    } on DioException catch (e) {
      setState(() {
        _testSuccess = false;
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          _testResult = 'فشل الاتصال: لا يمكن الوصول للخادم';
        } else if (e.response != null) {
          _testResult = 'الخادم استجاب (${e.response!.statusCode}) - متصل';
          _testSuccess = true;
        } else {
          _testResult = 'فشل الاتصال: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _testSuccess = false;
        _testResult = 'خطأ: $e';
      });
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _saveUrl() async {
    final newUrl = _urlController.text.trim();
    await AppConfig.setCustomApiBaseUrl(newUrl);

    if (mounted) {
      // Update ApiClient's base URL immediately
      context.read<ApiClient>().updateBaseUrl(AppConfig.apiBaseUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الرابط وتطبيقه مباشرة.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resetUrl() async {
    await AppConfig.setCustomApiBaseUrl('');
    if (mounted) {
      setState(() {
        _urlController.text = AppConfig.apiBaseUrl;
        _testResult = null;
        _testSuccess = null;
      });
      context.read<ApiClient>().updateBaseUrl(AppConfig.apiBaseUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إعادة تعيين الرابط للافتراضي.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أدوات المطور'),
        backgroundColor: const Color(0xFF6A5AE0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current URL info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الرابط الحالي:\n${AppConfig.apiBaseUrl}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Preset URLs
            const Text(
              'روابط معدة مسبقاً',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._presets.map((preset) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _urlController.text = preset.url);
                },
                icon: const Icon(Icons.dns, size: 18),
                label: Text(preset.label, style: const TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerRight,
                  foregroundColor: const Color(0xFF6A5AE0),
                  minimumSize: const Size(double.infinity, 42),
                ),
              ),
            )),

            const SizedBox(height: 16),

            // Custom URL
            const Text(
              'رابط الخادم (API Base URL)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'http://192.168.1.100:8000',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            // Test connection button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering),
                label: Text(_isTesting ? 'جارٍ الاختبار...' : 'اختبار الاتصال'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6A5AE0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Test result
            if (_testResult != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _testSuccess == true
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testSuccess == true ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess == true ? Icons.check_circle : Icons.error,
                      color: _testSuccess == true ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          color: _testSuccess == true
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Save & Reset buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveUrl,
                    icon: const Icon(Icons.save),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A5AE0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    label: const Text('حفظ وتطبيق'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetUrl,
                    icon: const Icon(Icons.restore),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    label: const Text('إعادة تعيين'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'ملاحظة: التغييرات تُطبَّق مباشرة على جميع الطلبات الجديدة بدون إعادة تشغيل التطبيق.',
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetUrl {
  final String label;
  final String url;
  const _PresetUrl({required this.label, required this.url});
}
