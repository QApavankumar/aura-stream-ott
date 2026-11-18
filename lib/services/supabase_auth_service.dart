import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class SupabaseAuthService {
  final SupabaseService _service = SupabaseService.instance;

  SupabaseClient? get _client => _service.client;

  bool get isReady => _service.isReady && _client != null;

  User? get currentUser => _client?.auth.currentUser;

  Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;

  /// Send an OTP code to a phone number or email.
  Future<bool> sendOtp({required String identifier}) async {
    if (!isReady) return false;

    try {
      final isEmail = identifier.contains('@');
      if (isEmail) {
        await _client!.auth.signInWithOtp(email: identifier.trim());
      } else {
        await _client!.auth.signInWithOtp(phone: identifier.trim());
      }
      return true;
    } catch (e) {
      debugPrint('[SupabaseAuthService] sendOtp error: $e');
      rethrow;
    }
  }

  /// Verify the 6-digit OTP code.
  Future<AuthResponse?> verifyOtp({
    required String identifier,
    required String token,
  }) async {
    if (!isReady) return null;

    try {
      final isEmail = identifier.contains('@');
      return await _client!.auth.verifyOTP(
        type: isEmail ? OtpType.email : OtpType.sms,
        token: token.trim(),
        email: isEmail ? identifier.trim() : null,
        phone: !isEmail ? identifier.trim() : null,
      );
    } catch (e) {
      debugPrint('[SupabaseAuthService] verifyOtp error: $e');
      rethrow;
    }
  }

  /// Sign in with Email and Password.
  Future<AuthResponse?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (!isReady) return null;

    try {
      return await _client!.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      debugPrint('[SupabaseAuthService] signInWithPassword error: $e');
      rethrow;
    }
  }

  /// Sign up with Email and Password.
  Future<AuthResponse?> signUp({
    required String email,
    required String password,
  }) async {
    if (!isReady) return null;

    try {
      return await _client!.auth.signUp(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      debugPrint('[SupabaseAuthService] signUp error: $e');
      rethrow;
    }
  }

  /// Sign out the current session.
  Future<void> signOut() async {
    if (!isReady) return;
    try {
      await _client!.auth.signOut();
    } catch (e) {
      debugPrint('[SupabaseAuthService] signOut error: $e');
    }
  }
}
