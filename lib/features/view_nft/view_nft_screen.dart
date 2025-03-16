import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/view_nft/providers/show_nft_info_provider.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/nft_provider.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';

final currentIndexProvider = StateProvider<int>((ref) {
  return 0;
});

class ViewNftScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const ViewNftScreen({super.key, required this.initialIndex});

  @override
  ConsumerState<ViewNftScreen> createState() => _ViewNftScreenState();
}

class _ViewNftScreenState extends ConsumerState<ViewNftScreen> {
  late int _swiperIndex;

  @override
  void initState() {
    super.initState();
    _swiperIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentIndexProvider.notifier).state = widget.initialIndex;
      debugPrint("Initial Index set to: ${widget.initialIndex}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final nftState = ref.watch(nftNotifierProvider);
    final currentIndex = ref.watch(currentIndexProvider);
    final showNftInfo = ref.watch(showNftInfoProvider);

    return nftState.when(
      data: (nfts) {
        if (nfts.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('NFT Viewer')),
            body: Center(child: Text(S.current.noNftsFound)),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(S.current.nftViewerTitle),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeInOut,
                  child: Stack(
                    fit: StackFit.expand,
                    key: ValueKey(currentIndex),
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Image.network(
                          nfts[currentIndex].imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Swiper(
                  index: _swiperIndex,
                  onIndexChanged: (index) {
                    if (_swiperIndex != index) {
                      setState(() {
                        _swiperIndex = index;
                      });
                      ref.read(currentIndexProvider.notifier).state = index;
                    }
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(kWidgetRadius),
                      child: GestureDetector(
                        onTap: () =>
                            ref.read(showNftInfoProvider.notifier).toggle(),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                nfts[index].imageUrl,
                                fit: BoxFit.contain,
                              ),
                              if (showNftInfo)
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black87,
                                        Colors.transparent
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(kScreenPadding),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      EllipsizedText(
                                        nfts[index].name,
                                        style: context.textTheme.displayLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      EllipsizedText(
                                        nfts[index].description,
                                        style: context.textTheme.displaySmall,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: nfts.length,
                  loop: nfts.length > 1 ? true : false,
                  itemWidth:
                      MediaQuery.of(context).size.width - (kScreenPadding * 2),
                  itemHeight:
                      MediaQuery.of(context).size.width - (kScreenPadding * 2),
                  layout: SwiperLayout.STACK,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(S.current.nftViewerTitle),
        ),
        body: Center(
          child: Shimmer.fromColors(
            baseColor: context.colorScheme.background,
            highlightColor: context.colorScheme.onSurfaceVariant,
            child: Container(
              width: MediaQuery.of(context).size.width - (kScreenPadding * 2),
              height: MediaQuery.of(context).size.width - (kScreenPadding * 2),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(kWidgetRadius),
              ),
            ),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(S.current.nftViewerTitle)),
        body: Center(child: Text('${S.of(context).error}: $error')),
      ),
    );
  }
}
