// import 'package:deliver/services/settings.dart';
// import 'package:flutter/material.dart';
//
// class Progressbar {
//   static BuildContext? _context;
//   static bool isDismiss = false;
//
//   static void showProgress() {
//     isDismiss = false;
//     if (_context != null) {
//       try {
//         Navigator.pop(_context!);
//       } catch (e) {}
//       _context = null;
//     }
//     showDialog(
//         barrierDismissible: false,
//         context: settings.appContext,
//         builder: (c) {
//           _context = c;
//           if (isDismiss) {
//             dismiss();
//           }
//           return const Center(
//             child: CircularProgressIndicator(
//               color: Colors.blue,
//             ),
//           );
//         });
//   }
//
//   static void dismiss() {
//     isDismiss = true;
//     if (_context != null) {
//       Navigator.pop(_context!);
//       _context = null;
//     }
//   }
// }
