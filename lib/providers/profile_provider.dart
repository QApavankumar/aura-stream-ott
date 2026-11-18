import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../core/constants/app_constants.dart';

class ProfileProvider extends ChangeNotifier {
  List<UserProfile> _profiles = List.from(UserProfile.defaultProfiles);
  UserProfile? _activeProfile;
  bool _isEditMode = false;
  String _kidsPin = AppConstants.defaultKidsPin;
  bool _isKidsPinEnabled = true;

  List<UserProfile> get profiles => List.unmodifiable(_profiles);
  UserProfile? get activeProfile => _activeProfile;
  bool get isEditMode => _isEditMode;
  String get kidsPin => _kidsPin;
  bool get isKidsPinEnabled => _isKidsPinEnabled;

  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    notifyListeners();
  }

  // Profile Selection Logic
  // Returns true if selection is immediate, false if Kids PIN verification is required.
  bool selectProfile(UserProfile profile) {
    if (profile.isKids && _isKidsPinEnabled) {
      // In Kids mode, entering might be open or exiting might be locked.
      // Often entering Kids mode is free, but exiting or accessing protected profile requires PIN.
      // Or entering a locked profile requires PIN.
      // We will provide a clean check:
    }
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
    return enteredPin == _kidsPin;
  }

  // Update Kids PIN and Toggle
  void updateKidsPinSettings({required bool isEnabled, String? newPin}) {
    _isKidsPinEnabled = isEnabled;
    if (newPin != null && newPin.length == AppConstants.kidsPinLength) {
      _kidsPin = newPin;
    }
    notifyListeners();
  }

  // Add new Profile
  void addProfile({
    required String name,
    required Color color,
    required String icon,
    bool isKids = false,
  }) {
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
  void deleteProfile(String id) {
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
