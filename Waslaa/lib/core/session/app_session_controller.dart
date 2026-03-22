import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:Waslaa/core/session/session_storage.dart';
import 'package:Waslaa/features/auth/models/auth_user.dart';
import 'package:Waslaa/features/auth/repositories/auth_repository.dart';

enum AppLaunchDestination { onboarding, welcome, home }

class AppSessionController extends ChangeNotifier {
  AppSessionController({
    required SessionStorage sessionStorage,
    required AuthRepository authRepository,
  }) : _sessionStorage = sessionStorage,
       _authRepository = authRepository;

  final SessionStorage _sessionStorage;
  final AuthRepository _authRepository;

  bool _isBootstrapping = false;
  bool _isSigningIn = false;
  String? _errorMessage;
  AuthUser? _currentUser;

  bool get isBootstrapping => _isBootstrapping;
  bool get isSigningIn => _isSigningIn;
  String? get errorMessage => _errorMessage;
  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<AppLaunchDestination> bootstrap() async {
    _isBootstrapping = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _sessionStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        final seenOnboarding = await _sessionStorage.hasSeenOnboarding();
        return seenOnboarding
            ? AppLaunchDestination.welcome
            : AppLaunchDestination.onboarding;
      }

      _currentUser = await _authRepository.getCurrentUser();
      return AppLaunchDestination.home;
    } on DioException catch (error) {
      _errorMessage = error.message;
      await _sessionStorage.clearAccessToken();
      final seenOnboarding = await _sessionStorage.hasSeenOnboarding();
      return seenOnboarding
          ? AppLaunchDestination.welcome
          : AppLaunchDestination.onboarding;
    } finally {
      _isBootstrapping = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({required String login, required String password}) async {
    _isSigningIn = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _authRepository.login(login: login, password: password);
      await _sessionStorage.writeAccessToken(session.token);
      _currentUser = session.user;
      return true;
    } on DioException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isSigningIn = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.logout();
    } catch (_) {
      // Clear local session even if the remote logout fails.
    }
    _currentUser = null;
    _errorMessage = null;
    await _sessionStorage.clearAccessToken();
    notifyListeners();
  }

  Future<void> markOnboardingSeen() async {
    await _sessionStorage.setOnboardingSeen();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }
}