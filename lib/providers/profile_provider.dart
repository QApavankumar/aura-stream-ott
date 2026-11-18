import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../core/constants/app_constants.dart';
import '../services/supabase_profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final SupabaseProfileService _profileService = SupabaseProfileService();

  List<UserProfile> _profiles = List.from(UserProfile.defaultProfiles);
  UserProfile? _activeProfile;
  bool _isEditMode = false;
  String _kidsPin = AppConstants.defaultKidsPin;
  bool _isKidsPinEnabled = true;
  bool _isLoading = false;

  List<UserProfile> get profiles => List.unmodifiable(_profiles);
  UserProfile? get activeProfile => _activeProfile;
  bool get isEditMode => _isEditMode;
  String get kidsPin => _kidsPin;
  bool get isKidsPinEnabled => _isKidsPinEnabled;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    // If Supabase is ready, load live profiles from cloud
    if (_profileService.isReady) {
      loadCloudProfiles();
    }
  }

  /// Load user profiles from Supabase Cloud.
  Future<void> loadCloudProfiles() async {
    if (!_profileService.isReady) return;

    _isLoading = true;
    notifyListeners();

    final cloudProfiles = await _profileService.fetchProfiles();
    if (cloudProfiles.isNotEmpty) {
      _profiles = cloudProfiles;
      _activeProfile = cloudProfiles.firstWhere(
        (p) => p.isPrimary,
        orElse: () => cloudProfiles.first,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    notifyListeners();
  }

  // Profile Selection Logic
  bool selectProfile(UserProfile profile) {
    _activeProfile = profile;
    notifyListeners();
    return true;
  }

  void setActiveProfileDirectly(UserProfile profile) {
    _activeProfile = profile;
    notifyListeners();
  }

  // Verify PIN entered by user
  bool verifyKidsPin(String enteredPin) {
    if (_activeProfile?.kidsPin != null) {
      return enteredPin == _activeProfile!.kidsPin;
    }
    return enteredPin == _kidsPin;
  }

  // Update Kids PIN and Toggle
  void updateKidsPinSettings({required bool isEnabled, String? newPin}) async {
    _isKidsPinEnabled = isEnabled;
    if (newPin != null && newPin.length == AppConstants.kidsPinLength) {
      _kidsPin = newPin;
      if (_profileService.isReady && _activeProfile != null) {
        await _profileService.updateKidsPin(
          profileId: _activeProfile!.id,
          newPin: isEnabled ? newPin : null,
        );
      }
    }
    notifyListeners();
  }

  // Add new Profile
  Future<void> addProfile({
    required String name,
    required Color color,
    required String icon,
    bool isKids = false,
  }) async {
    if (_profileService.isReady) {
      final cloudProfile = await _profileService.createProfile(
        name: name,
        avatarIcon: icon,
        themeColor: color,
        isKids: isKids,
        contentRating: isKids ? 'PG • Kids Hub Animated' : '4K Ultra HD • General',
        kidsPin: isKids ? _kidsPin : null,
      );
      if (cloudProfile != null) {
        _profiles.add(cloudProfile);
        notifyListeners();
        return;
      }
    }

    // Fallback: Local Mock Profile
    final newProfile = UserProfile(
      id: 'profile_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      avatarIcon: icon,
      themeColor: color,
      isKids: isKids,
      contentRating: isKids ? 'PG • Kids Hub Animated' : '4K Ultra HD • General',
      kidsPin: isKids ? _kidsPin : null,
    );
    _profiles.add(newProfile);
    notifyListeners();
  }

  // Delete Profile
  Future<void> deleteProfile(String id) async {
    if (_profileService.isReady) {
      await _profileService.deleteProfile(id);
    }
    _profiles.removeWhere((p) => p.id == id && !p.isPrimary);
    if (_activeProfile?.id == id) {
      _activeProfile = _profiles.isNotEmpty ? _profiles.first : null;
    }
    notifyListeners();
  }

  void clearActiveProfile() {
    _activeProfile = null;
    notifyListeners();
  }
}
