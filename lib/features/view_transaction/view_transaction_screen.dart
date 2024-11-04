// view_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/view_transaction/view_transaction_body.dart';
import 'package:kibisis/providers/active_transaction_provider.dart';

class ViewTransactionScreen extends ConsumerStatefulWidget {
  final bool isPanelMode;

  const ViewTransactionScreen({
    super.key,
    this.isPanelMode = false,
  });

  @override
  ViewTransactionScreenState createState() => ViewTransactionScreenState();
}

class ViewTransactionScreenState extends ConsumerState<ViewTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    final activeTransaction = ref.watch(activeTransactionProvider);
    if (activeTransaction == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('View Transaction'),
        ),
        body: const Center(
          child: Text('No transaction available to display.'),
        ),
      );
    }

    if (!widget.isPanelMode) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('View Transaction'),
        ),
        body: ViewTransactionBody(transaction: activeTransaction),
      );
    }
    return ViewTransactionBody(transaction: activeTransaction);
  }
}
