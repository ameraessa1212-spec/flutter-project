import 'package:Waslaa/core/services/push_notification_service.dart';
import 'package:Waslaa/features/profile/repositories/profile_repository.dart';

enum AppLaunchDestination { onboarding, welcome, home, error }

class AppSessionController extends ChangeNotifier {
  AppSessionController({
    required SessionStorage sessionStorage,
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  }) : _sessionStorage = sessionStorage,
       _authRepository = authRepository,
       _profileRepository = profileRepository;

  final SessionStorage _sessionStorage;
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  bool _isBootstrapping = false;
  bool _isSigningIn = false;
  String? _errorMessage;
  AuthUser? _currentUser;

  bool get isBootstrapping => _isBootstrapping;
  bool get isSigningIn => _isSigningIn;
  String? get errorMessage => _errorMessage;
  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void _initializeNotifications() {
    PushNotificationService(profileRepository: _profileRepository).initialize();
  }

  bool _shouldClearSession(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 401 || statusCode == 403;
  }

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
      
      // Initialize notifications
      _initializeNotifications();
      
      return AppLaunchDestination.home;
    } on DioException catch (error) {
      _errorMessage = error.message;

      if (_shouldClearSession(error)) {
        _currentUser = null;
        await _sessionStorage.clearAccessToken();
        final seenOnboarding = await _sessionStorage.hasSeenOnboarding();
        return seenOnboarding
            ? AppLaunchDestination.welcome
            : AppLaunchDestination.onboarding;
      }

      return AppLaunchDestination.error;
    } catch (_) {
      _errorMessage = 'تعذر تهيئة التطبيق حالياً. حاول مرة أخرى.';
      return AppLaunchDestination.error;
    } finally {
      _isBootstrapping = false;
      notifyListeners();
    }
  }

  Future<AppLaunchDestination> retryBootstrap() {
    return bootstrap();
  }

  Future<bool> signIn({required String login, required String password}) async {
    _isSigningIn = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _authRepository.login(login: login, password: password);
      await _sessionStorage.writeAccessToken(session.token);
      _currentUser = session.user;
      
      // Initialize notifications
      _initializeNotifications();
      
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