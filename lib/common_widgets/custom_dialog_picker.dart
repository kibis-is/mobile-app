import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Map<String, String>> items;
  final VoidCallback? onCancel;

  const CustomAlertDialog({
    required this.title,
    this.subtitle,
    required this.items,
    this.icon,
    this.onCancel,
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
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: kScreenPadding, horizontal: 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(kWidgetRadius),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon,
                        size: AppIcons.xlarge,
                        color: context.colorScheme.onBackground),
                    const SizedBox(height: kScreenPadding / 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kScreenPadding, vertical: 0),
                      child: Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                            color: context.colorScheme.onSurface,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kScreenPadding, vertical: 0),
                        child: EllipsizedText(
                          type: EllipsisType.end,
                          subtitle!,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                  color: context.colorScheme.secondary,
                                  fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: kScreenPadding / 2),
                    SingleChildScrollView(
                      child: Column(
                        children: items.map<Widget>((item) {
                          return Column(
                            children: [
                              Container(
                                color: context.colorScheme.surface,
                                child: ListTile(
                                  title: EllipsizedText(
                                    item['accountName']!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(
                                            color: context
                                                .colorScheme.onBackground,
                                            fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: EllipsizedText(
                                    item['publicKey']!,
                                    type: EllipsisType.middle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: context
                                                .colorScheme.onBackground,
                                            fontWeight: FontWeight.bold),
                                  ),
                                  leading: Container(
                                      padding: const EdgeInsets.all(
                                          kScreenPadding / 2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      child: Icon(
                                        AppIcons.wallet,
                                        color: context.colorScheme.onPrimary,
                                      )),
                                  trailing: const Icon(AppIcons.arrowRight),
                                  onTap: () => Navigator.pop(context, item),
                                  contentPadding:
                                      const EdgeInsets.all(kScreenPadding),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(kWidgetRadius),
                                  ),
                                  tileColor:
                                      Theme.of(context).colorScheme.surface,
                                ),
                              ),
                              const SizedBox(height: 1),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: kScreenPadding),
                    TextButton(
                        onPressed: onCancel ?? () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: context.textTheme.bodyMedium,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
