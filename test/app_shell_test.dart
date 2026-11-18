import 'package:flutter_test/flutter_test.dart';
import 'package:aura_stream/models/auth_state.dart';
import 'package:aura_stream/providers/auth_provider.dart';
import 'package:aura_stream/providers/profile_provider.dart';
import 'package:aura_stream/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

void main() {
  group('Member 3 - AuthProvider Tests', () {
    test('Initial auth state is unauthenticated', () {
      final auth = AuthProvider();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.status, equals(AuthStatus.unauthenticated));
      expect(auth.currentUser, isNull);
    });

    test('sendOtp transitions state to otpSent for valid phone', () async {
      final auth = AuthProvider();
      final result = await auth.sendOtp('+1 (555) 019-2834', isPhone: true);
      expect(result, isTrue);
      expect(auth.status, equals(AuthStatus.otpSent));
      expect(auth.pendingIdentifier, equals('+1 (555) 019-2834'));
    });

    test('verifyOtp succeeds with demo OTP code', () async {
      final auth = AuthProvider();
      await auth.sendOtp('+1 (555) 019-2834');
      final verified = await auth.verifyOtp(AppConstants.demoOtp);
      expect(verified, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser, isNotNull);
    });

    test('verifyOtp fails with invalid short code', () async {
      final auth = AuthProvider();
      await auth.sendOtp('+1 (555) 019-2834');
      final verified = await auth.verifyOtp('123');
      expect(verified, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.errorMessage, isNotNull);
    });
  });

  group('Member 3 - ProfileProvider & Kids PIN Tests', () {
    test('Loads 4 default profiles with CyberKid as Kids profile', () {
      final profileProvider = ProfileProvider();
      expect(profileProvider.profiles.length, equals(4));

      final kidsProfile = profileProvider.profiles.firstWhere((p) => p.isKids);
      expect(kidsProfile.name, equals('CyberKid'));
      expect(kidsProfile.isKids, isTrue);
    });

    test('Kids PIN validation passes with default PIN 1234', () {
      final profileProvider = ProfileProvider();
      expect(profileProvider.verifyKidsPin(AppConstants.defaultKidsPin), isTrue);
      expect(profileProvider.verifyKidsPin('9999'), isFalse);
    });

    test('Kids PIN settings update', () {
      final profileProvider = ProfileProvider();
      profileProvider.updateKidsPinSettings(isEnabled: true, newPin: '5678');
      expect(profileProvider.verifyKidsPin('5678'), isTrue);
      expect(profileProvider.verifyKidsPin('1234'), isFalse);
    });

    test('Can add a new profile and select it', () {
      final profileProvider = ProfileProvider();
      final initialCount = profileProvider.profiles.length;

      profileProvider.addProfile(
        name: 'Sci-Fi Explorer',
        color: const Color(0xFF00F2FE),
        icon: 'rocket_launch',
        isKids: false,
      );

      expect(profileProvider.profiles.length, equals(initialCount + 1));
      final newProfile = profileProvider.profiles.last;
      expect(newProfile.name, equals('Sci-Fi Explorer'));

      profileProvider.selectProfile(newProfile);
      expect(profileProvider.activeProfile?.id, equals(newProfile.id));
    });
  });
}
