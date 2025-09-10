// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/services.dart';

// class ReceiptScannerPlugin {
//   static const MethodChannel _channel = MethodChannel('receipt_scanner_plugin');

//   /// Check if VisionKit is available (iOS 13+)
//   static Future<bool> get isAvailable async {
//     if (!Platform.isIOS) return false;
//     final bool result = await _channel.invokeMethod('isAvailable');
//     return result;
//   }

//   /// Scan text from image using VisionKit (iOS) or ML Kit (Android)
//   static Future<String> scanImage(String imagePath) async {
//     final String result = await _channel.invokeMethod('scanImage', {
//       'imagePath': imagePath,
//     });
//     return result;
//   }

//   /// Launch VisionKit document scanner (iOS only)
//   static Future<List<String>> scanDocument() async {
//     if (!Platform.isIOS) {
//       throw UnsupportedError('Document scanner is only available on iOS');
//     }
//     final List<dynamic> result = await _channel.invokeMethod('scanDocument');
//     return result.cast<String>();
//   }
// }