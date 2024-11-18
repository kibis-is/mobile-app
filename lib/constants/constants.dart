const double kScreenPadding = 16.0;
const double kButtonPadding = 16.0;
const double kWidgetRadius = 16.0;
const double kSizedBoxSpacing = 16.0;
const double kInputHeight = 64.0;
const int kPinLength = 6;
const int kMaxAccountNameLength = 32;
const double kDialogWidth = 0.75;
const int kHapticButtonPressDuration = 5;
const int kHapticErrorDuration = 100;

enum PinPadMode { setup, unlock, verifyTransaction, changePin }

enum AssetScreenMode { view, add }

enum AccountFlow {
  setup,
  addNew,
  edit,
  general,
  view,
}

enum SendTransactionScreenMode {
  asset,
  payment,
}

enum ScanMode {
  privateKey,
  publicKey,
  catchAll,
  session,
}

enum AssetType { standard, arc200 }

enum TransactionDirection {
  incoming,
  outgoing,
  unknown,
}
