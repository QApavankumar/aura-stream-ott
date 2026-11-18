import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final String avatarIcon;
  final Color themeColor;
  final bool isKids;
  final bool isPrimary;
  final String contentRating;
  final String? kidsPin;

  const UserProfile({
    required this.id,
    required this.name,
    required this.avatarIcon,
    required this.themeColor,
    this.isKids = false,
    this.isPrimary = false,
    this.contentRating = 'TV-MA',
    this.kidsPin,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarIcon,
    Color? themeColor,
    bool? isKids,
    bool? isPrimary,
    String? contentRating,
    String? kidsPin,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarIcon: avatarIcon ?? this.avatarIcon,
      themeColor: themeColor ?? this.themeColor,
      isKids: isKids ?? this.isKids,
      isPrimary: isPrimary ?? this.isPrimary,
      contentRating: contentRating ?? this.contentRating,
      kidsPin: kidsPin ?? this.kidsPin,
    );
  }

  // Pre-configured default profiles for Aura Stream
  static List<UserProfile> get defaultProfiles => [
        const UserProfile(
          id: 'p_alex',
          name: 'Alex R.',
          avatarIcon: 'person',
          themeColor: Color(0xFF00F2FE),
          isPrimary: true,
          contentRating: '4K Ultra HD • All Access',
        ),
        const UserProfile(
          id: 'p_elena',
          name: 'Elena',
          avatarIcon: 'movie',
          themeColor: Color(0xFFE040FB),
          contentRating: 'Sci-Fi & Cinema Club',
        ),
        const UserProfile(
          id: 'p_cyberkid',
          name: 'CyberKid',
          avatarIcon: 'child_care',
          themeColor: Color(0xFFFF9E00),
          isKids: true,
          contentRating: 'PG • Kids Hub Animated',
          kidsPin: '1234',
        ),
        const UserProfile(
          id: 'p_guest',
          name: 'Watch Party',
          avatarIcon: 'group',
          themeColor: Color(0xFF2979FF),
          contentRating: 'Guest Mode',
        ),
      ];
}
