import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/wallet.dart';
import 'package:kibisis/providers/wallet_provider.dart';
import 'package:kibisis/theme/color_palette.dart';

class WalletsScreen extends ConsumerWidget {
  static String title = 'Wallets';
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Wallet> wallets = ref.watch(walletProvider).getWallets();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select an Account'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: kScreenPadding,
            ),
            Expanded(
              child: ListView.separated(
                itemCount: wallets.length,
                itemBuilder: (context, index) {
                  final item = wallets[index];

                  return InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          opacity: 0.2,
                          image: AssetImage('assets/images/voi-logo.png'),
                          fit: BoxFit.cover, // Cover the container
                        ),
                        border: GradientBoxBorder(
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.5)
                            ],
                          ),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(kScreenPadding),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            ColorPalette.cardGradientPurpleB,
                            ColorPalette.cardGradientPurpleA,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(kScreenPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(
                            height: kScreenPadding,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Color(0xFFBFBFBF),
                                  Color(0xFF767676),
                                  Color(0xFFCFCFCF),
                                ],
                              ),
                              border: const GradientBoxBorder(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    Color(0xFFB5B5B5),
                                    Color(0xFFD7D7D7),
                                    Color(0xFFFFFFFF),
                                  ],
                                ),
                                width: 1,
                              ),
                              borderRadius:
                                  BorderRadius.circular(kScreenPadding / 4),
                            ),
                            width: 32,
                            height: 24,
                            child: SvgPicture.asset(
                              'assets/images/kibisis-logo-light.svg',
                              semanticsLabel: 'Kibisis Logo',
                              fit: BoxFit.fitHeight,
                              colorFilter: const ColorFilter.mode(
                                  Colors.white, BlendMode.srcATop),
                            ),
                          ),
                          const SizedBox(
                            height: kScreenPadding / 2,
                          ),
                          Text(
                            item.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: kScreenPadding / 2,
                          ),
                          EllipsizedText(
                            item.address,
                            type: EllipsisType.middle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: kScreenPadding / 2,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              item.balance.toString(),
                              textAlign: TextAlign.end,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      debugPrint('selected wallet: ${item.name}');
                      GoRouter.of(context).pop();
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: kScreenPadding,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
