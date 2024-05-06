import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/models/network.dart';

class NetworkSelect extends StatelessWidget {
  const NetworkSelect({
    super.key,
    required this.networks,
  });

  final List<Network> networks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: kScreenPadding / 6,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            networks[0].icon,
            height: kScreenPadding,
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onBackground, BlendMode.srcATop),
          ),
          const SizedBox(
            width: kScreenPadding / 2,
          ),
          Text(networks[0].name, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(
            width: kScreenPadding / 2,
          ),
          Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
