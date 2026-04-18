import 'package:dio/dio.dart';

import 'package:Waslaa/core/config/app_config.dart';
import 'package:Waslaa/core/errors/app_exception.dart';
import 'package:Waslaa/core/session/session_storage.dart';

class ApiClient {
  ApiClient({required SessionStorage sessionStorage, Dio? dio})
    : _sessionStorage = sessionStorage,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: AppConfig.connectTimeout,
              receiveTimeout: AppConfig.receiveTimeout,
              contentType: 'application/json',
              headers: const {
                'Accept': 'application/json',
              },
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.reject(_mapError(error));
        },
      ),
    );
  }

  final Dio _dio;
  final SessionStorage _sessionStorage;

  /// Update the base URL at runtime (used by DevToolScreen).
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete(path, queryParameters: queryParameters);
  }

  DioException _mapError(DioException error) {
    final responseData = error.response?.data;
    final statusCode = error.response?.statusCode;

    String message = 'حدث خطأ أثناء الاتصال بالخادم.';

    if (statusCode == 401) {
      message = 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
    } else if (statusCode == 403) {
      message = 'تم رفض الطلب. تأكد من صلاحية الوصول ثم حاول مرة أخرى.';
    } else if (statusCode != null && statusCode >= 500) {
      message = 'حدث خطأ من جهة الخادم. حاول مرة أخرى بعد قليل.';
    } else if (responseData is Map<String, dynamic>) {
      final apiMessage = responseData['message'];
      if (apiMessage is String && apiMessage.isNotEmpty) {
        message = apiMessage;
      } else {
        final errors = responseData['errors'];
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            message = firstError.first.toString();
          }
        }
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      message = 'انتهت مهلة الاتصال بالخادم.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'تعذر الاتصال بالخادم. تأكد من عنوان الـ API وتشغيل السيرفر.';
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: AppException(message, statusCode: statusCode),
      message: message,
    );
  }
}
