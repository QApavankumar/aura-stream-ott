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
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRwaXZwc25zdW1remRkaHN0dmZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ5ODYyMzAsImV4cCI6MjExMDU2MjIzMH0.cZhZff-N0nTujYga8AWaq4hj7RfZRvyKQdsunkWD4Ac';

  /// Returns true only when real, non-placeholder credentials have been provided.
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        !supabaseUrl.contains('YOUR_SUPABASE') &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseAnonKey.contains('YOUR_SUPABASE');
  }
}
