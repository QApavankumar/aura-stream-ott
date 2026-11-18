import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'app.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // Initialize Supabase Cloud Backend (falls back gracefully to Mock mode if keys are pending)
  await SupabaseService.instance.initialize();

  // Dark obsidian status bar & navigation bar for immersive cinematic shell
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF08090C),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AuraStreamApp());
}
