import 'package:flutter/material.dart';
import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/dashboard/widgets/qr_dialog.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/copy_to_clipboard.dart';
import 'package:kibisis/utils/refresh_account_data.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class DashboardInfoPanel extends ConsumerWidget {
  const DashboardInfoPanel({
    super.key,
    required this.networks,
    required this.accountState,
    required this.publicKey,
  });

  final List<SelectItem> networks;
  final AccountState accountState;
  final String publicKey;

  List<SelectItem> get items => [
        SelectItem(
          name: "Copy Address",
          value: 'copy',
          icon: AppIcons.copy,
        ),
        SelectItem(
          name: "Share Address",
          value: 'share',
          icon: AppIcons.share,
        ),
        SelectItem(
          name: "Edit",
          value: 'edit',
          icon: AppIcons.edit,
        ),
        SelectItem(
          name: "Refresh",
          value: 'refresh',
          icon: AppIcons.refresh,
        ),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountId =
        ref.watch(activeAccountProvider.notifier).getActiveAccountId();
    return Padding(
      padding: const EdgeInsets.only(
          left: kScreenPadding, right: kScreenPadding / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'account-name-$accountId',
            child: EllipsizedText(
              accountState.accountName ?? 'No Account Name',
              type: EllipsisType.end,
              textAlign: TextAlign.start,
              style: context.textTheme.titleLarge?.copyWith(
                letterSpacing: 1.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Hero(
                  tag: publicKey,
                  child: EllipsizedText(
                    publicKey,
                    type: EllipsisType.middle,
                    textAlign: TextAlign.start,
                    style: context.textTheme.bodySmall?.copyWith(
                        letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              IconButton(
                icon: AppIcons.icon(
                    icon: AppIcons.verticalDots,
                    size: AppIcons.medium,
                    color: context.colorScheme.onBackground),
                onPressed: () {
                  customBottomSheet(
                    context: context,
                    items: items,
                    header: "Options",
                    onPressed: (SelectItem item) {},
                  ).then((value) {
                    if (value == "Copy Address") {
                      if (!context.mounted) return;
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
                    } else if (value == "Refresh") {
                      invalidateProviders(ref);
                    }
                  });
                },
                padding: const EdgeInsets.all(kScreenPadding / 2),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
