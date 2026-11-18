import 'package:flutter/foundation.dart';
import '../models/auth_state.dart';
import '../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
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

  // Step 1: Send OTP to Phone or Email
  Future<bool> sendOtp(String identifier, {bool isPhone = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 700));

    if (identifier.trim().isEmpty) {
      _isLoading = false;
      _errorMessage = 'Please enter a valid phone number or email address';
      notifyListeners();
      return false;
    }

    _pendingIdentifier = identifier.trim();
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

    await Future.delayed(const Duration(milliseconds: 600));

    // Support Demo OTP "888888" or any valid 6-digit code for smooth testing
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
