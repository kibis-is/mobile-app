import 'package:kibisis/common_widgets/custom_dropdown.dart';

const kScreenPadding = 16.0;
const kButtonPadding = 16.0;
const kWidgetRadius = 8.0;
const kSizedBoxSpacing = 16.0;
const kInputHeight = 64.0;
const kPinLength = 6;
const kVersionNumber = 'v0.0.1';

enum PinPadMode { setup, unlock, verifyTransaction }

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
  SelectItem(name: '1 minute', value: "60", icon: '0xe3af'),
  SelectItem(name: '2 minutes', value: "120", icon: '0xe3af'),
  SelectItem(name: '5 minutes', value: "300", icon: '0xe3af'),
  SelectItem(name: '10 minutes', value: "600", icon: '0xe3af'),
  SelectItem(name: '15 minutes', value: "900", icon: '0xe3af'),
];
