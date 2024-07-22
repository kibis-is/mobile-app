import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class NetworkSelect extends ConsumerWidget {
  final int networkCount;

  const NetworkSelect({super.key, required this.networkCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SelectItem? currentNetwork = ref.watch(networkProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kScreenPadding / 6),
      child: _NetworkDisplayRow(
        currentNetwork: currentNetwork,
        networkCount: networkCount,
      ),
    );
  }
}

class _NetworkDisplayRow extends StatelessWidget {
  final SelectItem? currentNetwork;
  final int networkCount;

  const _NetworkDisplayRow({this.currentNetwork, required this.networkCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcons.icon(icon: currentNetwork?.icon, size: AppIcons.small),
        const SizedBox(width: kScreenPadding / 2),
        Text(
          currentNetwork?.name ?? 'No Network',
          style: context.textTheme.bodySmall
              ?.copyWith(color: context.colorScheme.onSurface),
        ),
        if (networkCount > 1)
          AppIcons.icon(icon: AppIcons.arrowDropdown, size: AppIcons.small),
      ],
    );
  }
}
