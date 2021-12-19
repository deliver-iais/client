// ignore_for_file: unused_local_variable, unused_field

import 'dart:async';

import 'dart:io';

extension on List<String> {

}

/// Declares an event type related to a [Toast].
class ToastEvent {}

/// Event occuring upon clicking the toast.
class ToastActivated extends ToastEvent {}

/// Event occuring upon clicking any of actions in the toast.
class ToastInteracted extends ToastEvent {
  /// Index of the action in the Toast.
  late int? action;
  ToastInteracted({required this.action});
}

/// Event occuring upon dismissing the toast.
class ToastDismissed extends ToastEvent {}

/// Declares the type of [Toast].
enum ToastType {
  /// A large image and a single string wrapped across three lines of text.
  imageAndText01,

  /// A large image, one string of bold text on the first line, one string of regular text wrapped across the second and third lines.
  imageAndText02,

  /// A large image, one string of bold text wrapped across the first two lines, one string of regular text on the third line.
  imageAndText03,

  /// A large image, one string of bold text on the first line, one string of regular text on the second line, one string of regular text on the third line.
  imageAndText04,

  /// Single string wrapped across three lines of text.
  text01,

  /// One string of bold text on the first line, one string of regular text wrapped across the second and third lines.
  text02,

  /// One string of bold text wrapped across the first two lines, one string of regular text on the third line.
  text03,

  /// One string of bold text on the first line, one string of regular text on the second line, one string of regular text on the third line.
  text04,
}

/// A [Toast]. Use [ToastService.show] to display a toast.
class Toast {
  /// Type of [Toast].
  final ToastType type;

  /// Title of [Toast].
  final String title;

  /// Subtitle of the [Toast].
  final String? subtitle;

  /// Image [File] to show inside the [Toast].
  final File? image;

  /// [List] of actions to be shown on the [Toast].
  final List<String>? actions;

  /// Unique ID of this [Toast].
  late int id;

  Toast({
    required this.type,
    required this.title,
    this.subtitle,
    this.image,
    this.actions,
  }) {
    List<String> data = [
      type.index.toString(),
      title,
      subtitle ?? '',
      image?.path ?? '', ...?actions
    ];
    id = 1;
  }

  /// Releases resources allocated to the instance of [Toast].
  void dispose() {
  }
}

/// Setups a service for sending [Toast].
class ToastService {
  /// Name of the application.
  final String appName;

  /// Name of the company.
  final String companyName;

  /// Name of the product.
  final String productName;

  /// (Optional) Name of the sub product.
  final String? subProductName;

  /// (Optional) Version information.
  final String? versionInformation;

  /// Stream yeilding events on the [Toast].
  late Stream<ToastEvent> stream;

  ToastService({
    required this.appName,
    required this.companyName,
    required this.productName,
    this.subProductName,
    this.versionInformation,
  });

  /// Shows a [Toast] on the desktop.
  void show(Toast toast) {

  }

  /// Releases resources allocated to the instance of [ToastService].
  void dispose() {
  }

  /// Internally used [StreamController] for event handling.
  late StreamController<ToastEvent> _streamController;
}
