import 'package:kibisis/constants/constants.dart';

class SelectItem {
  final String name;
  final String value;
  final dynamic icon;
  final AssetType? assetType;

  SelectItem({
    required this.name,
    required this.value,
    required this.icon,
    this.assetType,
  });
}
