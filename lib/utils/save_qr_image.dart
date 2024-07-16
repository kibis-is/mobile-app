import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class QRCodeUtils {
  // Function to save QR code as an image in the gallery
  static Future<void> saveQrImage(GlobalKey key) async {
    if (await Permission.storage.request().isGranted) {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        await ImageGallerySaver.saveImage(pngBytes);
      }
    }
  }

  // Function to share QR code image
  static Future<void> shareQrImage(GlobalKey key) async {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final pngBytes = byteData.buffer.asUint8List();

      final directory =
          await getTemporaryDirectory(); // Using temporary directory which is suitable for sharing
      File imgFile = File('${directory.path}/qr.png');
      await imgFile.writeAsBytes(pngBytes);

      final xFile = XFile(imgFile.path);
      final result =
          await Share.shareXFiles([xFile], text: 'Here is my QR Code!');

      if (result.status == ShareResultStatus.success) {
        debugPrint('Thank you for sharing my QR code!');
      } else if (result.status == ShareResultStatus.dismissed) {
        debugPrint('Sharing was dismissed.');
      }
    }
  }
}
