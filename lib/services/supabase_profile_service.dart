import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'supabase_service.dart';

class SupabaseProfileService {
  final SupabaseService _service = SupabaseService.instance;

  SupabaseClient? get _client => _service.client;

  bool get isReady => _service.isReady && _client != null;

  /// Fetch all profiles belonging to the current authenticated user.
  Future<List<UserProfile>> fetchProfiles() async {
    if (!isReady) return [];

    try {
      final userId = _client!.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client!
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      final List<dynamic> data = response as List<dynamic>;

      if (data.isEmpty) {
        // If this is a newly registered user with no profiles, seed the primary profile
        final primaryProfile = await createProfile(
          name: 'Alex R.',
          avatarIcon: 'person',
          themeColor: const Color(0xFF00F2FE),
          isPrimary: true,
          contentRating: '4K Ultra HD • All Access',
        );
        return primaryProfile != null ? [primaryProfile] : [];
      }

      return data.map((json) => _mapJsonToProfile(json)).toList();
    } catch (e) {
      debugPrint('[SupabaseProfileService] fetchProfiles error: $e');
      return [];
    }
  }

  /// Create a new viewer profile in Supabase.
  Future<UserProfile?> createProfile({
    required String name,
    required String avatarIcon,
    required Color themeColor,
    bool isKids = false,
    bool isPrimary = false,
    String contentRating = '4K Ultra HD • All Access',
    String? kidsPin,
  }) async {
    if (!isReady) return null;

    try {
      final userId = _client!.auth.currentUser?.id;
      if (userId == null) return null;

      final hexColor = '#${themeColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

      final response = await _client!
          .from('profiles')
          .insert({
            'user_id': userId,
            'name': name.trim(),
            'avatar_icon': avatarIcon,
            'theme_color_hex': hexColor,
            'is_kids': isKids,
            'is_primary': isPrimary,
            'content_rating': contentRating,
            'kids_pin': kidsPin,
          })
          .select()
          .single();

      return _mapJsonToProfile(response);
    } catch (e) {
      debugPrint('[SupabaseProfileService] createProfile error: $e');
      return null;
    }
  }

  /// Update the Kids PIN on a profile.
  Future<bool> updateKidsPin({
    required String profileId,
    required String? newPin,
  }) async {
    if (!isReady) return false;

    try {
      await _client!
          .from('profiles')
          .update({'kids_pin': newPin})
          .eq('id', profileId);
      return true;
    } catch (e) {
      debugPrint('[SupabaseProfileService] updateKidsPin error: $e');
      return false;
    }
  }

  /// Delete a profile.
  Future<bool> deleteProfile(String profileId) async {
    if (!isReady) return false;

    try {
      await _client!.from('profiles').delete().eq('id', profileId);
      return true;
    } catch (e) {
      debugPrint('[SupabaseProfileService] deleteProfile error: $e');
      return false;
    }
  }

  UserProfile _mapJsonToProfile(Map<String, dynamic> json) {
    Color parsedColor = const Color(0xFF00F2FE);
    final hexString = json['theme_color_hex'] as String?;
    if (hexString != null && hexString.startsWith('#')) {
      final buffer = StringBuffer();
      if (hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      parsedColor = Color(int.parse(buffer.toString(), radix: 16));
    }

    return UserProfile(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Viewer',
      avatarIcon: json['avatar_icon'] as String? ?? 'person',
      themeColor: parsedColor,
      isKids: json['is_kids'] as bool? ?? false,
      isPrimary: json['is_primary'] as bool? ?? false,
      contentRating: json['content_rating'] as String? ?? '4K Ultra HD',
      kidsPin: json['kids_pin'] as String?,
    );
  }
}
