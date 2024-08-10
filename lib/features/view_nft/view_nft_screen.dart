import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/view_nft/providers/show_nft_info_provider.dart';
import 'package:kibisis/providers/nft_provider.dart';
import 'package:kibisis/utils/theme_extensions.dart';

final currentIndexProvider = StateProvider<int>((ref) {
  return 0;
});

class ViewNftScreen extends ConsumerWidget {
  final int initialIndex;

  const ViewNftScreen({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ref.read(currentIndexProvider.notifier).state = initialIndex;
      }
    });

    double screenWidth =
        MediaQuery.of(context).size.width - (kScreenPadding * 2);
    final nftState = ref.watch(nftNotifierProvider);
    final nfts = nftState.nfts;
    final currentIndex = ref.watch(currentIndexProvider);
    final currentNft = nfts[currentIndex];
    final showNftInfo = ref.watch(showNftInfoProvider);

    if (nfts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('NFT Viewer')),
        body: const Center(child: Text('No NFTs found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('NFT Viewer'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Swiper(
            index: initialIndex,
            onIndexChanged: (index) {
              ref.read(currentIndexProvider.notifier).state = index;
            },
            itemBuilder: (BuildContext context, int index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(kWidgetRadius),
                child: GestureDetector(
                  onTap: () => ref.read(showNftInfoProvider.notifier).toggle(),
                  child: SizedBox(
                    width: screenWidth,
                    height: screenWidth,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          nfts[index].imageUrl,
                          fit: BoxFit.fill,
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          top: screenWidth / 2,
                          child: AnimatedOpacity(
                            opacity: showNftInfo ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(1.0),
                                    Colors.transparent
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(kScreenPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  EllipsizedText(
                                    currentNft.name,
                                    style: context.textTheme.displayLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  EllipsizedText(currentNft.owner,
                                      style: context.textTheme.displayMedium),
                                  EllipsizedText(currentNft.description,
                                      style: context.textTheme.displaySmall),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: nfts.length,
            loop: true,
            itemWidth: screenWidth,
            itemHeight: screenWidth,
            layout: SwiperLayout.STACK,
            scrollDirection: Axis.horizontal,
          ),
        ],
      ),
    );
  }
}
