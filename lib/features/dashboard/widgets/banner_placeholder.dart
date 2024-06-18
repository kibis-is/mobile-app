// import 'package:flutter/material.dart';
// import 'package:kibisis/constants/constants.dart';
// import 'package:kibisis/utils/theme_extensions.dart';

// class BannerPlaceholder extends StatelessWidget {
//   const BannerPlaceholder({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 200.0,
//       color: Colors.white,
//     );
//   }
// }

// class TitlePlaceholder extends StatelessWidget {
//   final double width;

//   const TitlePlaceholder({super.key, required this.width});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: kScreenPadding,
//       color: context.colorScheme.surface,
//     );
//   }
// }

// class ContentPlaceholder extends StatelessWidget {
//   final int lineCount;

//   const ContentPlaceholder({super.key, required this.lineCount});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: List.generate(lineCount, (index) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: kScreenPadding / 4),
//           child: Container(
//             width: double.infinity,
//             height: kScreenPadding,
//             color: context.colorScheme.surface,
//           ),
//         );
//       }),
//     );
//   }
// }
