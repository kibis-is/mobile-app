// view_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/view_transaction/view_transaction_body.dart';
import 'package:kibisis/generated/l10n.dart';
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
          title: Text(S.current.viewTransactionTitle),
        ),
        body: Center(
          child: Text(S.current.noTransactionAvailable),
        ),
      );
    }

    if (!widget.isPanelMode) {
      return Scaffold(
        appBar: AppBar(
          title: Text(S.current.viewTransactionTitle),
        ),
        body: ViewTransactionBody(transaction: activeTransaction),
      );
    }
    return ViewTransactionBody(transaction: activeTransaction);
  }
}
