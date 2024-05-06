import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/transparent_list_tile.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/menu.dart';

class SettingsScreen extends StatelessWidget {
  static String title = 'Settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<SettingsMenu> settingsMenu = SettingsMenu.menuList;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding / 2),
        child: Column(
          children: [
            const SizedBox(
              height: kScreenPadding,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(kScreenPadding / 2),
                itemCount: settingsMenu.length,
                itemBuilder: (BuildContext context, int index) {
                  return TransparentListTile(
                    icon: settingsMenu[index].icon,
                    title: settingsMenu[index].name,
                    onTap: () => GoRouter.of(context)
                        .go('/settings${settingsMenu[index].path}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
