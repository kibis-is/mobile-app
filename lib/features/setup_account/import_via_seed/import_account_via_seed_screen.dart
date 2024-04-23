import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/constants/constants.dart';

class ImportAccountViaSeedScreen extends ConsumerStatefulWidget {
  static String title = "Import Account Via Seed";
  const ImportAccountViaSeedScreen({super.key});

  @override
  ConsumerState<ImportAccountViaSeedScreen> createState() =>
      _ImportAccountViaSeedScreenState();
}

class _ImportAccountViaSeedScreenState
    extends ConsumerState<ImportAccountViaSeedScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(kScreenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [],
        ),
      ),
    );
  }
}
