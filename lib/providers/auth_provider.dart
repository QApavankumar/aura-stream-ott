import 'package:flutter/foundation.dart';
import '../models/auth_state.dart';
import '../core/constants/app_constants.dart';
import '../services/supabase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();

  AuthStatus _status = AuthStatus.unauthenticated;
  AuthUser? _currentUser;
  String? _pendingIdentifier;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  AuthUser? get currentUser => _currentUser;
  String? get pendingIdentifier => _pendingIdentifier;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLiveBackend => _authService.isReady;

  AuthProvider() {
    // Check if user is already logged in with Supabase
    if (_authService.isReady && _authService.currentUser != null) {
      final user = _authService.currentUser!;
      _currentUser = AuthUser(
        id: user.id,
        identifier: user.phone ?? user.email ?? 'Aura VIP User',
        isPhone: user.phone != null,
      );
      _status = AuthStatus.authenticated;
    }
  }

  // Step 1: Send OTP to Phone or Email
  Future<bool> sendOtp(String identifier, {bool isPhone = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (identifier.trim().isEmpty) {
      _isLoading = false;
      _errorMessage = 'Please enter a valid phone number or email address';
      notifyListeners();
      return false;
    }

    _pendingIdentifier = identifier.trim();

    // If live Supabase backend is configured, send real OTP
    if (_authService.isReady) {
      try {
        final success = await _authService.sendOtp(identifier: _pendingIdentifier!);
        if (success) {
          _status = AuthStatus.otpSent;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (e) {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        notifyListeners();
        return false;
      }
    }

    // Fallback: Simulated Mock Latency & Demo Mode
    await Future.delayed(const Duration(milliseconds: 600));
    _status = AuthStatus.otpSent;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Step 2: Verify OTP
  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // If live Supabase backend is active and not using override demo OTP
    if (_authService.isReady && otp != AppConstants.demoOtp) {
      try {
        final response = await _authService.verifyOtp(
          identifier: _pendingIdentifier ?? '',
          token: otp,
        );
        if (response?.user != null) {
          final user = response!.user!;
          _currentUser = AuthUser(
            id: user.id,
            identifier: user.phone ?? user.email ?? _pendingIdentifier ?? '+1 (555) 019-2834',
            isPhone: user.phone != null,
          );
          _status = AuthStatus.authenticated;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (e) {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        notifyListeners();
        return false;
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Support Demo OTP "888888" or 6-digit code for testing
    if (otp == AppConstants.demoOtp || otp.length == AppConstants.otpLength) {
      _currentUser = AuthUser(
        id: 'user_aura_vip_001',
        identifier: _pendingIdentifier ?? '+1 (555) 019-2834',
        isPhone: true,
      );
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      _errorMessage = 'Invalid verification code. Use demo code ${AppConstants.demoOtp}';
      notifyListeners();
      return false;
    }
  }

  // Quick Guest Login for frictionless exploration
  Future<void> loginAsGuest() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = const AuthUser(
      id: 'guest_user',
      identifier: 'Guest Streamer',
      isPhone: false,
    );
    _status = AuthStatus.authenticated;
    _isLoading = false;
    notifyListeners();
  }

  // Logout
  void logout() {
    if (_authService.isReady) {
      _authService.signOut();
    }
    _status = AuthStatus.unauthenticated;
    _currentUser = null;
    _pendingIdentifier = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
