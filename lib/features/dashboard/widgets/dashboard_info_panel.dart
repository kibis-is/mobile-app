import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/qr_dialog.dart';
import 'package:kibisis/models/menu_item.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class DashboardInfoPanel extends StatelessWidget {
  const DashboardInfoPanel({
    super.key,
    required this.networks,
    required this.accountState,
    required this.publicKey,
  });

  final List<SelectItem> networks;
  final AccountState accountState;
  final String publicKey;

  List<MenuItem> get items => [
        MenuItem(
          name: "Copy Address",
          image: '0xe190',
        ),
        MenuItem(
          name: "Share Address",
          image: '0xe190',
        ),
        MenuItem(
          name: "Edit",
          image: '0xe3c9',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EllipsizedText(
          accountState.accountName ?? 'No Account Name',
          type: EllipsisType.end,
          textAlign: TextAlign.start,
          style: context.textTheme.titleLarge?.copyWith(letterSpacing: 1.3),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: EllipsizedText(
                publicKey,
                type: EllipsisType.middle,
                textAlign: TextAlign.start,
                style:
                    context.textTheme.bodySmall?.copyWith(letterSpacing: 1.5),
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
                    onPressed: (SelectItem item) {},
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
                    } else if (value == "Share Address") {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => QrDialog(
                          qrData: publicKey,
                        ),
                      );
                    }
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(
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
