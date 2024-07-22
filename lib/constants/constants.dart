import 'package:kibisis/models/select_item.dart';
import 'package:kibisis/utils/app_icons.dart';

const kScreenPadding = 16.0;
const kButtonPadding = 16.0;
const kWidgetRadius = 8.0;
const kSizedBoxSpacing = 16.0;
const kInputHeight = 64.0;
const kPinLength = 6;
const kVersionNumber = 'v0.1.0';

enum PinPadMode { setup, unlock, verifyTransaction }

enum AssetScreenMode { view, add }

enum AccountFlow {
  setup,
  addNew,
  edit,
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

enum ScanMode { privateKey, publicKey }
