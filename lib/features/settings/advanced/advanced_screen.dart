import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/providers/allow_test_networks_provider.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/network_provider.dart'; // Ensure you import networkProvider
import 'package:kibisis/common_widgets/top_snack_bar.dart'; // Assuming this is where you handle snack bars

class AdvancedScreen extends ConsumerStatefulWidget {
  static const String title = 'Advanced';
  const AdvancedScreen({super.key});

  @override
  ConsumerState<AdvancedScreen> createState() => _AdvancedScreenState();
}

class _AdvancedScreenState extends ConsumerState<AdvancedScreen> {
  @override
  Widget build(BuildContext context) {
    // Listening to network changes right in the build method
    ref.listen<SelectItem?>(networkProvider, (_, SelectItem? newNetwork) {
      if (newNetwork != null) {
        showCustomSnackBar(
          context: context,
          snackType: SnackType.success,
          message: 'Network switched to ${newNetwork.name}',
        );
      }
    });

    final showTestNetworks = ref.watch(allowTestNetworksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AdvancedScreen.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(height: kScreenPadding),
            SwitchListTile(
              title: const Text('Allow Test Networks'),
              subtitle: const Text(
                  'Toggle to include test networks in the network list.'),
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
