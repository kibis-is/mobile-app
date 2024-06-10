import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class NetworkSelect extends ConsumerWidget {
  const NetworkSelect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SelectItem? currentNetwork = ref.watch(networkProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kScreenPadding / 6),
      child: _NetworkDisplayRow(currentNetwork: currentNetwork),
    );
  }
}

class _NetworkDisplayRow extends StatelessWidget {
  final SelectItem? currentNetwork;

  const _NetworkDisplayRow({this.currentNetwork});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          currentNetwork?.icon ?? 'assets/images/default-icon.svg',
          height: 12,
          semanticsLabel: currentNetwork?.name ?? 'No Network',
          colorFilter: ColorFilter.mode(
              context.colorScheme.onSurface, BlendMode.srcATop),
        ),
        const SizedBox(width: kScreenPadding / 2),
        Text(
          currentNetwork?.name ?? 'No Network',
          style: context.textTheme.bodySmall
              ?.copyWith(color: context.colorScheme.onSurface),
        ),
        Icon(Icons.arrow_drop_down, color: context.colorScheme.onSurface),
      ],
    );
  }
}
