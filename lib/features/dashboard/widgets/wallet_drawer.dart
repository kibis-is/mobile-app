import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';

class WalletDrawer extends StatelessWidget {
  const WalletDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width / 8 * 7,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
            ),
            child: Row(
              children: [
                const Center(
                  child: CircleAvatar(
                    maxRadius: kScreenPadding * 2,
                    foregroundImage: AssetImage('assets/images/kieran-tn.png'),
                  ),
                ),
                const SizedBox(
                  width: kSizedBoxSpacing,
                ),
                Expanded(
                  child: Text(
                    'Kieran O\'Neill',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSizedBoxSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () => GoRouter.of(context).go('/addWallet'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: (kSizedBoxSpacing / 2) * 3),
                      child: Column(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.secondary,
                            size: kScreenPadding * 2,
                          ),
                          const SizedBox(
                            height: kSizedBoxSpacing / 2,
                          ),
                          Text(
                            'Add Wallet',
                            style: Theme.of(context).textTheme.titleLarge,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: kSizedBoxSpacing / 2,
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(kScreenPadding / 2),
                              child: Icon(Icons.account_balance_wallet,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: kScreenPadding * 1.5),
                            ),
                          ),
                          title: Text(
                            'Personal $index',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            'Personal $index',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: const Padding(
                            padding: EdgeInsets.all(kScreenPadding),
                            child: Icon(Icons.edit),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                        height: kSizedBoxSpacing / 2,
                      ), // Add your spacing widget here
                      itemCount: 7,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.background,
            padding: const EdgeInsets.all(kScreenPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {},
                ),
                const SizedBox(
                  width: kScreenPadding,
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {},
                ),
                const SizedBox(
                  width: kScreenPadding,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
