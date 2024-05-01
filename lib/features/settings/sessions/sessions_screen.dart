import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';

class SessionsScreen extends StatelessWidget {
  static String title = 'Sessions';
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          children: [
            SizedBox(
              height: kScreenPadding,
            ),
          ],
        ),
      ),
    );
  }
}
