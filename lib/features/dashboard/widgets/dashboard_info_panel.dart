import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_snackbar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/main.dart';
import 'package:kibisis/models/menu_item.dart';
import 'package:kibisis/models/network.dart';
import 'package:kibisis/providers/account_provider.dart';

class DashboardInfoPanel extends StatelessWidget {
  const DashboardInfoPanel({
    super.key,
    required this.networks,
    required this.accountState,
    required this.publicKey,
  });

  final List<Network> networks;
  final AccountState accountState;
  final String publicKey;

  List<MenuItem> get items => [
        MenuItem(
          name: "Copy Address",
          image: '0xe190',
        ),
        MenuItem(
          name: "Edit",
          image: '0xe3c9',
        ),
      ];

  void copyToClipboard(BuildContext context, String text) async {
    ClipboardData data = ClipboardData(text: text);
    await Clipboard.setData(data);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        customSnackbar(context, "Copied to clipboard"),
      );
    });
    debugPrint('text: $text');
    debugPrint('data: $data');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EllipsizedText(
          accountState.accountName ?? 'No Account Name',
          type: EllipsisType.end,
          textAlign: TextAlign.start,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(letterSpacing: 1.3),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: EllipsizedText(
                publicKey,
                type: EllipsisType.middle,
                textAlign: TextAlign.start,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(letterSpacing: 1.5),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  customBottomSheet(
                    context: context,
                    items: items,
                    header: "Options",
                    isIcon: true,
                    onPressed: () {}, // Placeholder for optional action
                    buttonOnPressed: () {}, // Placeholder for optional button
                  ).then((value) {
                    if (value == "Copy Address") {
                      copyToClipboard(context, publicKey);
                    } else if (value == "Edit") {
                      GoRouter.of(context).push(
                        '/editAccount/${accountState.accountId}',
                        extra: {
                          'accountName': accountState.accountName ?? '',
                        },
                      );
                    }
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(
                    kScreenPadding / 3,
                    kScreenPadding / 3,
                    0,
                    kScreenPadding / 3,
                  ),
                  child: Icon(Icons.more_vert),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
