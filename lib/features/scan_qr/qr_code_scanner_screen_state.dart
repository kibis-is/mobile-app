import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:kibisis/features/scan_qr/legacy_qr_code_scanner_widget.dart';
import 'package:kibisis/features/scan_qr/qr_code_scanner_screen_widget.dart';
import 'package:kibisis/features/scan_qr/qr_code_scanner_widget.dart';

class QRCodeScannerScreenState extends State<QRCodeScannerScreenWidget> {
  bool? isGooglePlayServicesAvailable;

  Future<void> _checkGooglePlayServices() async {
    GooglePlayServicesAvailability availability =
    await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();

    setState(() {
      isGooglePlayServicesAvailable = (availability == GooglePlayServicesAvailability.success);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      // if we are still checking for google play services
      if (isGooglePlayServicesAvailable == null) {
        return Center(child: CircularProgressIndicator());
      }

      if (isGooglePlayServicesAvailable!) {
        return const LegacyQRCodeScannerWidget();
      }
    }

    return const QRCodeScannerWidget();
  }

  @override
  void initState() {
    super.initState();
    _checkGooglePlayServices();
  }
}
