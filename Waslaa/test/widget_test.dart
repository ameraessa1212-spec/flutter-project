import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/core/session/app_session_controller.dart';
import 'package:Waslaa/core/session/session_storage.dart';
import 'package:Waslaa/features/auth/models/auth_session.dart';
import 'package:Waslaa/features/auth/models/auth_user.dart';
import 'package:Waslaa/features/auth/repositories/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSessionController.bootstrap', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('routes to onboarding when there is no token and onboarding is unseen', () async {
      final storage = FakeSessionStorage(onboardingSeen: false);
      final controller = AppSessionController(
        sessionStorage: storage,
        authRepository: FakeAuthRepository(),
      );

      final destination = await controller.bootstrap();

      expect(destination, AppLaunchDestination.onboarding);
      expect(storage.clearAccessTokenCalls, 0);
    });

    test('clears token and routes to welcome on unauthorized bootstrap', () async {
      final storage = FakeSessionStorage(token: 'expired-token', onboardingSeen: true);
      final controller = AppSessionController(
        sessionStorage: storage,
        authRepository: FakeAuthRepository(
          bootstrapError: _dioError(statusCode: 401, message: 'Unauthorized'),
        ),
      );

      final destination = await controller.bootstrap();

      expect(destination, AppLaunchDestination.welcome);
      expect(storage.clearAccessTokenCalls, 1);
      expect(await storage.readAccessToken(), isNull);
    });

    test('keeps token and returns error on transient network failure', () async {
      final storage = FakeSessionStorage(token: 'valid-token', onboardingSeen: true);
      final controller = AppSessionController(
        sessionStorage: storage,
        authRepository: FakeAuthRepository(
          bootstrapError: DioException(
            requestOptions: RequestOptions(path: '/auth/me'),
            type: DioExceptionType.connectionError,
            message: 'offline',
          ),
        ),
      );

      final destination = await controller.bootstrap();

      expect(destination, AppLaunchDestination.error);
      expect(storage.clearAccessTokenCalls, 0);
      expect(await storage.readAccessToken(), 'valid-token');
      expect(controller.errorMessage, 'offline');
    });
  });

  group('AppSessionController.signIn', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('stores session token and authenticates user on success', () async {
      final storage = FakeSessionStorage();
      final controller = AppSessionController(
        sessionStorage: storage,
        authRepository: FakeAuthRepository(
          signInSession: AuthSession(token: 'fresh-token', user: _user()),
        ),
      );

      final success = await controller.signIn(login: 'student', password: 'secret');

      expect(success, isTrue);
      expect(await storage.readAccessToken(), 'fresh-token');
      expect(controller.currentUser?.id, 1);
      expect(controller.errorMessage, isNull);
    });
  });
}

AuthUser _user() {
  return const AuthUser(
    id: 1,
    firstName: 'Test',
    lastName: 'Student',
    name: 'Test Student',
    username: 'student',
    email: 'student@example.com',
    phone: '0912345678',
    role: 'student',
    status: 'active',
  );
}

DioException _dioError({required int statusCode, required String message}) {
  final requestOptions = RequestOptions(path: '/auth/me');

  return DioException(
    requestOptions: requestOptions,
    response: Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: {'message': message},
    ),
    type: DioExceptionType.badResponse,
    message: message,
  );
}

class FakeSessionStorage extends SessionStorage {
  FakeSessionStorage({String? token, bool onboardingSeen = false})
    : _token = token,
      _onboardingSeen = onboardingSeen;

  String? _token;
  bool _onboardingSeen;
  int clearAccessTokenCalls = 0;

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<void> writeAccessToken(String token) async {
    _token = token;
  }

  @override
  Future<void> clearAccessToken() async {
    clearAccessTokenCalls += 1;
    _token = null;
  }

  @override
  Future<bool> hasSeenOnboarding() async => _onboardingSeen;

  @override
  Future<void> setOnboardingSeen() async {
    _onboardingSeen = true;
  }
}

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({this.bootstrapError, this.signInSession})
    : super(
        apiClient: ApiClient(
          sessionStorage: FakeSessionStorage(),
        ),
      );

  final DioException? bootstrapError;
  final AuthSession? signInSession;

  @override
  Future<AuthUser> getCurrentUser() async {
    if (bootstrapError != null) {
      throw bootstrapError!;
    }

    return _user();
  }

  @override
  Future<AuthSession> login({
    required String login,
    required String password,
    String deviceName = 'flutter-app',
  }) async {
    if (signInSession != null) {
      return signInSession!;
    }

    return AuthSession(token: 'token', user: _user());
  }
}
