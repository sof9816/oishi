import 'package:flutter/material.dart';

class ScreenConfig {
  final String endpoint;
  final String icon;
  final String hoveredIcon;
  final String tabTitle;
  final String? pageTitle;

  ScreenConfig({
    required this.endpoint,
    required this.icon,
    required this.hoveredIcon,
    required this.tabTitle,
    this.pageTitle,
  });
}

class ButtonConfig {
  final String endpoint;
  final IconData icon;
  final String pageTitle;
  final bool Function(String?) condition;
  final VoidCallback? onPressed;

  ButtonConfig({
    required this.endpoint,
    required this.icon,
    required this.pageTitle,
    required this.condition,
    this.onPressed,
  });
}

class ActionConfig {
  final IconData icon;
  final VoidCallback onPressed;

  const ActionConfig({
    required this.icon,
    required this.onPressed,
  });
}
