import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create a StateProvider to manage a 6-digit PIN
final accountProvider = StateProvider<String>((ref) => "");
