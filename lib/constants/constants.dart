import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/utils/app_icons.dart';

const double kScreenPadding = 16.0;
const double kButtonPadding = 16.0;
const double kWidgetRadius = 8.0;
const double kSizedBoxSpacing = 16.0;
const double kInputHeight = 64.0;
const int kPinLength = 6;
const String kVersionNumber = 'v0.3.0';
const int kMaxAccountNameLength = 32;
const double kDialogWidth = 0.75;

enum PinPadMode { setup, unlock, verifyTransaction, changePin }

enum AssetScreenMode { view, add }

enum AccountFlow {
  setup,
  addNew,
  edit,
  general,
}

enum SendTransactionScreenMode {
  asset,
  payment,
}

List<SelectItem> timeoutList = [
  SelectItem(name: '1 minute', value: "60", icon: AppIcons.time),
  SelectItem(
    name: '2 minutes',
    value: "120",
    icon: AppIcons.time,
  ),
  SelectItem(
    name: '5 minutes',
    value: "300",
    icon: AppIcons.time,
  ),
  SelectItem(
    name: '10 minutes',
    value: "600",
    icon: AppIcons.time,
  ),
  SelectItem(
    name: '15 minutes',
    value: "900",
    icon: AppIcons.time,
  ),
];

enum ScanMode {
  privateKey,
  publicKey,
  general,
  session,
}
