import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;

  const CustomAlertDialog({
    required this.title,
    required this.items,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeInOut,
        ),
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeInOut,
          ),
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            titlePadding: const EdgeInsets.all(kScreenPadding),
            scrollable: true,
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            actions: const [
              SizedBox(
                height: kScreenPadding,
              )
            ],
            content: SingleChildScrollView(
              child: ListBody(
                children: items.map<Widget>((item) {
                  return Column(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context, item),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(kScreenPadding),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(kWidgetRadius),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['accountName']!,
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                                Text(
                                  item['publicKey']!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
