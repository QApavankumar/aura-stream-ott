import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

/// Central singleton wrapper for Supabase operations in Aura Stream.
class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Returns true only if credentials are configured and client is ready.
  bool get isReady => SupabaseConfig.isConfigured && _isInitialized;

  /// Safe accessor for the Supabase Client. Returns null if not initialized.
  SupabaseClient? get client {
    if (!isReady) return null;
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('[SupabaseService] Client not ready: $e');
      return null;
    }
  }

  /// Initialize Supabase asynchronously.
  Future<bool> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('[SupabaseService] Running in Mock/Demo mode (Keys not configured).');
      _isInitialized = false;
      return false;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
      debugPrint('[SupabaseService] Connected to Supabase successfully.');
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Initialization failed, falling back to Mock: $e');
      _isInitialized = false;
      return false;
    }
  }
}
