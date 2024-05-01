class SettingsMenu {
  final String name;
  final String icon;
  final String path;

  SettingsMenu({required this.name, required this.icon, required this.path});

  static List<SettingsMenu> menuList = [
    SettingsMenu(
      name: 'General',
      icon: '0xe57f',
      path: '/general',
    ),
    SettingsMenu(
      name: 'Security',
      icon: '0xe569',
      path: '/security',
    ),
    SettingsMenu(
      name: 'Appearance',
      icon: '0xe46b',
      path: '/appearance',
    ),
    SettingsMenu(
      name: 'Sessions',
      icon: '0xe345',
      path: '/sessions',
    ),
    SettingsMenu(
      name: 'Advanced',
      icon: '0xef06',
      path: '/advanced',
    ),
    SettingsMenu(
      name: 'About',
      icon: '0xe33d',
      path: '/about',
    ),
  ];
}
