import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/nft_provider.dart';

final currentIndexProvider = StateProvider<int>((ref) {
  return 0; // Default to 0, but will immediately be set in the widget's lifecycle
});

class ViewNftScreen extends ConsumerWidget {
  final int initialIndex;

  const ViewNftScreen({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use post frame callback to avoid setting the provider's state during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ref.read(currentIndexProvider.notifier).state = initialIndex;
      }
    });

    double screenWidth =
        MediaQuery.of(context).size.width - (kScreenPadding * 2);
    final nftState = ref.watch(nftNotifierProvider);
    final nfts = nftState.nfts;

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Swiper(
            index: initialIndex,
            onIndexChanged: (index) {
              ref.read(currentIndexProvider.notifier).state = index;
            },
            itemBuilder: (BuildContext context, int index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(kWidgetRadius),
                child: SizedBox(
                  width: screenWidth,
                  height: screenWidth,
                  child: Image.asset(
                    nfts[index].imageUrl,
                    fit: BoxFit.fill,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer(
              builder: (context, ref, child) {
                final currentIndex = ref.watch(currentIndexProvider);
                final currentNft = nfts[currentIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${currentNft.name}',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text('Owner: ${currentNft.owner}',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('Description: ${currentNft.description}',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
