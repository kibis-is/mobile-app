import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/models/nft.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/routing/named_routes.dart';
import 'package:kibisis/theme/color_palette.dart';
import 'package:kibisis/utils/theme_extensions.dart';

enum NftViewType { grid, card }

class NftGridOrCard extends StatelessWidget {
  final List<NFT> nfts;
  final NftViewType viewType;

  const NftGridOrCard({
    super.key,
    required this.nfts,
    required this.viewType,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: viewType == NftViewType.grid ? 3 : 1,
        childAspectRatio: 1.0,
      ),
      itemCount: nfts.length,
      shrinkWrap: true, // Ensure it takes only the space needed
      physics: const ClampingScrollPhysics(), // Allow scrolling with refresh
      itemBuilder: (context, index) {
        final nft = nfts[index];
        return NftCard(
          nft: nft,
          viewType: viewType,
          index: index,
        );
      },
    );
  }
}

class NftCard extends StatelessWidget {
  final NFT nft;
  final NftViewType viewType;
  final int index;

  const NftCard({
    super.key,
    required this.nft,
    required this.viewType,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          viewNftRouteName,
          pathParameters: {'index': index.toString()},
        );
      },
      child: Card(
        margin: viewType == NftViewType.grid
            ? const EdgeInsets.all(0)
            : const EdgeInsets.only(bottom: kScreenPadding / 2),
        shape: RoundedRectangleBorder(
          borderRadius: viewType == NftViewType.grid
              ? BorderRadius.circular(0)
              : BorderRadius.circular(kWidgetRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            NftImage(imageUrl: nft.imageUrl),
            const NftImageOverlay(),
            NftDetails(
              name: nft.name,
            ),
          ],
        ),
      ),
    );
  }
}

class NftImage extends StatelessWidget {
  final String imageUrl;

  const NftImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class NftImageOverlay extends StatelessWidget {
  const NftImageOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
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
    );
  }
}

class NftDetails extends StatelessWidget {
  final String name;

  const NftDetails({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(kScreenPadding / 2),
        child: SizedBox(
          width: double.infinity,
          child: EllipsizedText(
            name,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: ColorPalette.darkThemeWhite,
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
    );
  }
}
