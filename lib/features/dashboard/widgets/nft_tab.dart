import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/models/nft.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/nft_provider.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class NftTab extends ConsumerWidget {
  const NftTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nftState = ref.watch(nftNotifierProvider);

    ref.listen<String>(
      accountProvider.select((state) => state.account?.publicAddress ?? ''),
      (previous, next) {
        if (next.isNotEmpty && next != previous) {
          ref.read(nftNotifierProvider.notifier).fetchNFTs(next);
        }
      },
    );

    return Column(
      children: [
        const SizedBox(height: kScreenPadding),
        Expanded(
          child: nftState.error != null
              ? _buildErrorWidget(nftState.error!)
              : nftState.nfts.isEmpty
                  ? _buildEmptyNfts(context)
                  : _buildNftGrid(nftState.nfts, ref),
        ),
      ],
    );
  }

  Widget _buildNftGrid(List<NFT> nfts, WidgetRef ref) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.0,
        crossAxisSpacing: 1.0,
      ),
      itemCount: nfts.length,
      itemBuilder: (context, index) {
        final nft = nfts[index];
        return GestureDetector(
          onTap: () {
            context.goNamed(
              viewNftRouteName,
              pathParameters: {'index': index.toString()},
            );
          },
          child: Stack(
            children: [
              Image.asset(
                nft.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              // Uncomment below when switching to real data
              // Image.network(
              //   nft.imageUrl,
              //   fit: BoxFit.cover,
              //   width: double.infinity,
              //   height: double.infinity,
              // ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black87,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(kScreenPadding / 2),
                  child: SizedBox(
                    width: double.infinity,
                    child: EllipsizedText(
                      nft.name,
                      style: context.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 2.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyNfts(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 4,
              maxHeight: MediaQuery.of(context).size.height / 4,
            ),
            child: SvgPicture.asset(
              'assets/images/empty.svg',
              semanticsLabel: 'No NFTs Found',
            ),
          ),
          const SizedBox(height: kScreenPadding / 2),
          Text('No NFTs Found', style: context.textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Text(
        'Error: $error',
        style: const TextStyle(color: Colors.red, fontSize: 18),
      ),
    );
  }
}
