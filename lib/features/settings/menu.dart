import 'package:flutter/material.dart';
import 'package:kibisis/utils/app_icons.dart';

class SettingsMenu {
  final String name;
  final IconData icon;
  final String path;

  SettingsMenu({required this.name, required this.icon, required this.path});

  static List<SettingsMenu> menuList = [
    SettingsMenu(
      name: 'General',
      icon: AppIcons.settings,
      path: '/general',
    ),
    SettingsMenu(
      name: 'Security',
      icon: AppIcons.security,
      path: '/security',
    ),
    SettingsMenu(
      name: 'Appearance',
      icon: AppIcons.appearance,
      path: '/appearance',
    ),
    SettingsMenu(
      name: 'Sessions',
      icon: AppIcons.sessions,
      path: '/sessions',
    ),
    //TODO: implement advanced options
    // SettingsMenu(
    //   name: 'Advanced',
    //   icon: AppIcons.advanced,
    //   path: '/advanced',
    // ),
    SettingsMenu(
      name: 'About',
      icon: AppIcons.about,
      path: '/about',
    ),
  ];
}
