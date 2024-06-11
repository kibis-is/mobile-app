import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class NftTab extends StatelessWidget {
  const NftTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: kScreenPadding),
        Expanded(
          child: _buildEmptyNfts(context),
        ),
      ],
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
}
