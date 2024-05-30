import 'package:flutter/material.dart';
import 'package:kibisis/common_widgets/settings_toggle.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/providers/settings_providers.dart';

class AdvancedScreen extends StatelessWidget {
  static String title = 'Advanced';
  const AdvancedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            const SizedBox(
              height: kScreenPadding,
            ),
            const SizedBox(
              height: kScreenPadding,
            ),
            SettingsToggle(
              title: 'Allow Mainnet Networks',
              provider: allowMainNetNetworksProvider,
              description: 'Let MainNet networks appear in the networks list.',
            ),
            const SizedBox(
              height: kScreenPadding,
            ),
            SettingsToggle(
              title: 'Allow BetaNet Networks',
              provider: allowBetaNetNetworksProvider,
              description:
                  'Let the BetaNet networks appear in the networks list.',
            ),
            const SizedBox(
              height: kScreenPadding,
            ),
            SettingsToggle(
              title: 'Allow DID Token Format in Address Sharing',
              provider: allowDIDTokenFormatInAddressSharingProvider,
              description:
                  'The DID token format “did algo:<public_address>” will be an option when sharing an address.',
            ),
          ],
        ),
      ),
    );
  }
}
