# 🌟 Aura Stream - OTT Application Shell & Architecture

> **Member 3 Responsibilities**: App Shell, Routing, Floating Frosted Glass Dock, Auth (Login & OTP), and Multi-Profile System ("Who's Watching?" with Kids PIN Lock).

---

## 🎯 Architecture & Deliverables

### 1. 🧭 StatefulShellRoute & Floating Frosted Glass Dock
- **`go_router` 14.x with `StatefulShellRoute.indexedStack`**:
  - Independent navigation history and preserved state across branches.
  - **Branch 0**: `/home` (Slot for Member 1 - Category Hub, Hero Banners, 4K UHD Rails)
  - **Branch 1**: `/explore` (Slot for Member 2 - Live Search, Story Bubbles, Genres)
  - **Branch 2**: `/downloads` (Offline storage monitor, downloaded titles)
  - **Branch 3**: `/profile` (User account, Audio/Video quality, Kids PIN controls)
- **Floating Frosted Glass Bottom Dock (`floating_frosted_dock.dart`)**:
  - `BackdropFilter` with `ImageFilter.blur(sigmaX: 24, sigmaY: 24)`
  - Floats dynamically above the bottom safe area
  - Glowing Neon Cyan active indicator with animated pill glow and scale micro-interactions

### 2. ⚡ Animated Glowing Cyan "Aura Stream" Splash Screen
- **`splash_screen.dart`**:
  - Deep obsidian background with radial ambient glows (`#00F2FE` & `#9D4EDD`)
  - Glowing cyan "AURA STREAM" logo with continuous breathing pulse animation
  - Cyan laser loading progress indicator
  - Auto-routing intelligence based on authentication and active profile

### 3. 🔐 Obsidian Glass Login & OTP Verification
- **`login_screen.dart` & `otp_verification_screen.dart`**:
  - Mobile phone & email segmented login modes
  - 6-digit individual glowing OTP input boxes with auto-advance and paste support
  - 60-second resend countdown timer
  - **Instant Demo OTP**: `888888` (or quick one-tap bypass for instant team testing)
  - Social authentication (Google & Apple) and "Continue as Guest" access

### 4. 👥 "Who's Watching?" Profile Selector & Kids PIN Lock
- **`who_is_watching_screen.dart`**:
  - Multi-profile grid featuring distinct stylized avatars (Alex R., Elena, CyberKid, Watch Party)
  - Interactive hover/tap scale with cyan and purple aura glow rings
  - **Kids PIN Protection**:
    - CyberKid profile has Kids Mode protection
    - Dedicated Frosted Glass modal dialog with numeric keypad (`1234` default PIN)
    - Shakes with glowing red feedback on invalid PIN
    - Kids PIN Toggle switch to enable/disable parental lock
  - "Add Profile" modal with custom avatar aura color and symbol picker

---

## 📁 Project Directory Structure

```
c:\Users\DELL\Desktop\OTT\
├── design_references/                 # Original UI references & mockups
├── lib/
│   ├── main.dart                      # App entry point with System UI styling
│   ├── app.dart                       # MultiProvider & MaterialApp.router
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── router/
│   │   │   ├── app_router.dart        # StatefulShellRoute configuration
│   │   │   └── route_names.dart
│   │   └── theme/
│   │       ├── app_colors.dart        # Cyan glow, obsidian glass palette
│   │       ├── app_theme.dart         # Material 3 dark theme
│   │       └── app_typography.dart    # Futuristic Orbitron & Outfit typography
│   ├── models/
│   │   ├── auth_state.dart
│   │   └── user_profile.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── profile_provider.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── aura_glow_button.dart
│   │   │   ├── aura_logo.dart         # Custom painted cyan neon logo
│   │   │   ├── aura_text_field.dart
│   │   │   └── frosted_glass.dart     # Reusable BackdropFilter glass
│   │   ├── dialogs/
│   │   │   ├── add_profile_dialog.dart
│   │   │   └── kids_pin_dialog.dart   # Frosted numeric keypad dialog
│   │   └── glass_dock/
│   │       ├── dock_item.dart
│   │       └── floating_frosted_dock.dart # Floating pill dock
│   └── screens/
│       ├── splash/splash_screen.dart
│       ├── auth/
│       │   ├── login_screen.dart
│       │   ├── otp_verification_screen.dart
│       │   └── widgets/
│       ├── profile/
│       │   ├── who_is_watching_screen.dart
│       │   ├── profile_screen.dart
│       │   └── widgets/
│       ├── shell/main_app_shell.dart
│       └── placeholders/
│           ├── home_screen_placeholder.dart     # 🧑💻 Member 1 Hook
│           ├── explore_screen_placeholder.dart  # 🧑💻 Member 2 Hook
│           ├── downloads_screen.dart
│           └── member_integration_guide.dart
└── test/
    └── app_shell_test.dart
```

---

## 🤝 Integration Instructions for Member 1 & Member 2

### For Member 1 (Home Screen & Content Rails)
- Open `lib/screens/placeholders/home_screen_placeholder.dart`.
- Inject your Category/Channel Hub, Hero Carousel, Live Channel equalizers, and 4K UHD rails.
- You can access the selected profile at any time with:
  ```dart
  final profile = context.watch<ProfileProvider>().activeProfile;
  ```

### For Member 2 (Explore & Search Screen)
- Open `lib/screens/placeholders/explore_screen_placeholder.dart`.
- Inject your Search suggestions, Story bubbles, and Studio badge carousels.
- For full-screen routes (like Video Player or Movie Details), set `parentNavigatorKey: rootNavigatorKey` in `app_router.dart` so it displays over the floating dock!

---

## 🔑 Quick Demo Credentials
- **Demo Phone Number**: `+1 (555) 019-2834`
- **Demo Verification Code (OTP)**: `888888`
- **Demo Kids PIN**: `1234`
