import 'package:flutter/material.dart';

class DockItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String routePath;

  const DockItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.routePath,
  });
}
