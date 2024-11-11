import 'package:flutter/material.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/utils/app_icons.dart';

class SettingsMenu {
  final String name;
  final IconData icon;
  final String path;

  SettingsMenu({required this.name, required this.icon, required this.path});

  static List<SettingsMenu> menuList = [
    SettingsMenu(
      name: S.current.general,
      icon: AppIcons.settings,
      path: '/general',
    ),
    SettingsMenu(
      name: S.current.security,
      icon: AppIcons.security,
      path: '/security',
    ),
    SettingsMenu(
      name: S.current.appearance,
      icon: AppIcons.appearance,
      path: '/appearance',
    ),
    SettingsMenu(
      name: S.current.sessions,
      icon: AppIcons.sessions,
      path: '/sessions',
    ),
    SettingsMenu(
      name: S.current.advanced,
      icon: AppIcons.advanced,
      path: '/advanced',
    ),
    SettingsMenu(
      name: S.current.about,
      icon: AppIcons.about,
      path: '/about',
    ),
  ];
}
