// File: lib/models/nav_item_model.dart

import 'package:flutter/material.dart';

/// Data class representing a Bottom Navigation item.
class NavItemModel {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const NavItemModel({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
