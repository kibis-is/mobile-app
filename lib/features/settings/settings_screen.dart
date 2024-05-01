import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                  return ListTile(
                    horizontalTitleGap: 32,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: kScreenPadding),
                    tileColor: Colors.transparent,
                    leading: Icon(
                      color: Theme.of(context).colorScheme.primary,
                      IconData(int.tryParse(settingsMenu[index].icon) ?? 0xe237,
                          fontFamily: 'MaterialIcons'),
                    ),
                    title: Text(
                      settingsMenu[index].name,
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {
                      GoRouter.of(context)
                          .go('/settings${settingsMenu[index].path}');
                    },
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
