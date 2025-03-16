import 'package:flutter/material.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CustomPullToRefresh extends StatelessWidget {
  final RefreshController refreshController;
  final VoidCallback onRefresh;
  final Widget child;

  const CustomPullToRefresh({
    super.key,
    required this.refreshController,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: refreshController,
      onRefresh: onRefresh,
      enablePullDown: true,
      header: CustomHeader(
        builder: (BuildContext context, RefreshStatus? mode) {
          Widget text;
          if (mode == RefreshStatus.idle) {
            text = Text(S.of(context).pullToRefresh);
          } else if (mode == RefreshStatus.canRefresh) {
            text = Text(S.of(context).releaseToRefresh);
          } else if (mode == RefreshStatus.refreshing) {
            text = Text(S.of(context).refreshing);
          } else {
            text = Text(S.of(context).pullToRefresh);
          }
          return SizedBox(
            height: 60.0,
            child: Center(child: text),
          );
        },
      ),
      child: child,
    );
  }
}
