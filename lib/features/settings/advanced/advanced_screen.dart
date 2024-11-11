import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/providers/allow_test_networks_provider.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/network_provider.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';

class AdvancedScreen extends ConsumerStatefulWidget {
  static String title = S.current.advanced;
  const AdvancedScreen({super.key});

  @override
  ConsumerState<AdvancedScreen> createState() => _AdvancedScreenState();
}

class _AdvancedScreenState extends ConsumerState<AdvancedScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen<SelectItem?>(networkProvider, (_, SelectItem? newNetwork) {
      if (newNetwork != null) {
        showCustomSnackBar(
          context: context,
          snackType: SnackType.success,
          message: S.of(context).networkSwitched(newNetwork.name),
        );
      }
    });

    final showTestNetworks = ref.watch(allowTestNetworksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).advanced),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            SwitchListTile(
              title: Text(S.of(context).allowTestNetworks),
              subtitle: Text(S.of(context).toggleTestNetworksDescription),
              value: showTestNetworks,
              onChanged: (newValue) {
                ref
                    .read(allowTestNetworksProvider.notifier)
                    .toggleTestNetworks(newValue);
              },
            ),
          ],
        ),
      ),
    );
  }
}
