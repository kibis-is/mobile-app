import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/common_widgets/confirmation_dialog.dart';
import 'package:kibisis/common_widgets/custom_bottom_sheet.dart';
import 'package:kibisis/common_widgets/custom_button.dart';
import 'package:kibisis/common_widgets/custom_dropdown.dart';
import 'package:kibisis/common_widgets/language_picker.dart';
import 'package:kibisis/common_widgets/pin_pad_dialog.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/providers/fab_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/app_reset_util.dart';
import 'package:kibisis/utils/theme_extensions.dart';

class GeneralScreen extends ConsumerWidget {
  static String title = S.current.general;
  const GeneralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).general)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kScreenPadding),
            const LanguagePicker(),
            const SizedBox(height: kScreenPadding),
            _buildFabPositionSelector(context, ref),
            const Spacer(),
            _buildDangerZoneTitle(context),
            const SizedBox(height: kScreenPadding / 2),
            _buildDangerZoneDescription(context),
            const SizedBox(height: kScreenPadding),
            _buildResetButton(context, ref),
            const SizedBox(height: kScreenPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneTitle(BuildContext context) {
    return Text(
      S.of(context).dangerZone,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colorScheme.error,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDangerZoneDescription(BuildContext context) {
    return Text(
      S.of(context).dangerZoneDescription,
      style: context.textTheme.bodySmall,
    );
  }

  Widget _buildResetButton(BuildContext context, WidgetRef ref) {
    return CustomButton(
      text: S.of(context).reset,
      isFullWidth: true,
      buttonType: ButtonType.warning,
      onPressed: () => _handleResetPressed(context, ref),
    );
  }

  Future<void> _handleResetPressed(BuildContext context, WidgetRef ref) async {
    bool confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => ConfirmationDialog(
            yesText: S.of(context).reset,
            noText: S.of(context).cancel,
            content: S.of(context).resetConfirmationMessage,
          ),
        ) ??
        false;

    if (confirm) {
      if (!context.mounted) return;
      _showPinPadDialog(context, ref);
    }
  }

  void _handleResetApp(WidgetRef ref, BuildContext context) async {
    try {
      ref.read(loadingProvider.notifier).startLoading(
            message: S.of(context).resettingApp,
          );

      await AppResetUtil.resetApp(ref);

      if (!context.mounted) return;
      GoRouter.of(context).go('/setup');
    } catch (e) {
      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: e.toString(),
      );
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  void _showPinPadDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => PinPadDialog(
        title: S.of(context).confirmReset,
        onPinVerified: () async {
          _handleResetApp(ref, context);
        },
      ),
    );
  }

  Widget _buildFabPositionSelector(BuildContext context, WidgetRef ref) {
    final fabPosition = ref.watch(fabPositionProvider);
    final List<SelectItem> positionList = [
      SelectItem(
        name: S.of(context).fabLeft,
        value: FabPosition.left.name,
        icon: SizedBox(
          width: kScreenPadding * 1.5,
          height: kScreenPadding * 1.5,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
            child: const Icon(AppIcons.menuArrow),
          ),
        ),
      ),
      SelectItem(
        name: S.of(context).fabRight,
        value: FabPosition.right.name,
        icon: const Icon(AppIcons.menuArrow),
      ),
    ];

    final selectedItem = positionList.firstWhere(
      (item) => item.value == fabPosition.name,
      orElse: () => positionList.first,
    );

    return GestureDetector(
      onTap: () {
        customBottomSheet(
          context: context,
          items: positionList,
          header: S.of(context).fabPosition,
          onPressed: (SelectItem selectedItem) {
            final position = FabPosition.values.firstWhere(
              (e) => e.name == selectedItem.value,
            );
            ref.read(fabPositionProvider.notifier).setPosition(position);
          },
        );
      },
      child: AbsorbPointer(
        absorbing: true,
        child: CustomDropDown(
          label: S.of(context).fabPosition,
          items: positionList,
          selectedValue: selectedItem,
          onChanged: null,
        ),
      ),
    );
  }
}
