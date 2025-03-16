import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/transparent_list_tile.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/menu.dart';
import 'package:kibisis/generated/l10n.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<SettingsMenu> settingsMenu = SettingsMenu.generateMenuList();
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding / 2),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(kScreenPadding / 2),
                itemCount: settingsMenu.length,
                itemBuilder: (BuildContext context, int index) {
                  return TransparentListTile(
                    icon: settingsMenu[index].icon,
                    title: settingsMenu[index].name,
                    onTap: () => GoRouter.of(context)
                        .push('/settings${settingsMenu[index].path}'),
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
