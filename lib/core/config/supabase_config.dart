/// Supabase Cloud Configuration for Aura Stream OTT.
///
/// To connect your live Supabase project:
/// 1. Go to https://supabase.com/dashboard/project/_/settings/api
/// 2. Copy the "Project URL" and "anon / public" API Key.
/// 3. Paste them into [supabaseUrl] and [supabaseAnonKey] below.
///
/// If left as placeholder values, the app will automatically run in
/// high-fidelity local Mock mode with zero errors.
class SupabaseConfig {
  /// Your Supabase Project URL (e.g. "https://xyzcompany.supabase.co")
  static const String supabaseUrl = 'https://dpivpsnsumkzddhstvfm.supabase.co';

  /// Your Supabase anon/public API Key (e.g. "eyJhbGciOi...")
  static const String supabaseAnonKey = 'sb_publishable_bCV-FzL72gviUmIHvKBahA_EWjDeZ3A';

  /// Returns true only when real, non-placeholder credentials have been provided.
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        !supabaseUrl.contains('YOUR_SUPABASE') &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseAnonKey.contains('YOUR_SUPABASE');
  }
}
