import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/methods/dialog.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/persistent_variable.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';

class CheckPermissionsService {
  final _requestLock = Lock();
  final grantedPermissions = <int>{};
  final permanentlyDeniedPermissions = <int>{};

  Future<bool> _checkAndGetPermission(
    Permission permission, {
    String? dialogKey,
    OncePersistent? oncePersistent,
    bool shouldShowRationalDialog = false,
    BuildContext? context,
  }) =>
      _advancedCheckAndGetPermission(
        permission,
        rationalDialogI18nKey: dialogKey,
        permanentlyDeniedDialogI18nKey: dialogKey,
        shouldShowRationalDialog: shouldShowRationalDialog,
        context: context,
        oncePersistent: oncePersistent,
      );

  Future<bool> _advancedCheckAndGetPermission(
    Permission permission, {
    String? rationalDialogI18nKey,
    String? permanentlyDeniedDialogI18nKey,
    bool shouldShowRationalDialog = false,
    OncePersistent? oncePersistent,
    BuildContext? context,
  }) async {
    assert(
      !shouldShowRationalDialog || rationalDialogI18nKey != null,
      "if you set shouldShowRationalDialog to true, you should set rationalDialogI18nKey too!",
    );

    if (grantedPermissions.contains(permission.value)) {
      return true;
    }

    final status = await permission.status;

    if (status.isGranted) {
      grantedPermissions.add(permission.value);
      return true;
    }

    if (status.isPermanentlyDenied) {
      permanentlyDeniedPermissions.add(permission.value);
    }
    if (permanentlyDeniedPermissions.contains(permission.value)) {
      if (context != null && context.mounted) {
        await showPermanentlyDeniedDialog(
          permanentlyDeniedDialogI18nKey: permanentlyDeniedDialogI18nKey,
          oncePersistent: oncePersistent,
          context: context,
        );
      } else {
        await showPermanentlyDeniedDialog(
          permanentlyDeniedDialogI18nKey: permanentlyDeniedDialogI18nKey,
          oncePersistent: oncePersistent,
        );
      }

      return false;
    }

    if (!permanentlyDeniedPermissions.contains(permission.value)) {
      if ((shouldShowRationalDialog ||
              await permission.shouldShowRequestRationale) &&
          rationalDialogI18nKey != null) {
        await showContinueAbleDialog(rationalDialogI18nKey);
      }
    }

    return _requestLock.synchronized(() async {
      final s = await permission.request();

      if (s.isPermanentlyDenied) {
        permanentlyDeniedPermissions.add(permission.value);

        // Not possible to check
        // ignore: use_build_context_synchronously
        await showPermanentlyDeniedDialog(
          permanentlyDeniedDialogI18nKey: permanentlyDeniedDialogI18nKey,
          oncePersistent: oncePersistent,
          context: context,
        );

        return false;
      } else if (s.isGranted) {
        grantedPermissions.add(permission.value);

        return true;
      } else {
        return false;
      }
    });
  }

  Future<void> showPermanentlyDeniedDialog({
    String? permanentlyDeniedDialogI18nKey,
    OncePersistent? oncePersistent,
    BuildContext? context,
  }) async {
    if (permanentlyDeniedDialogI18nKey != null) {
      if (oncePersistent != null) {}

      return oncePersistent.once(() async {
        final isOk = await showCancelableAbleDialog(
          permanentlyDeniedDialogI18nKey,
          okTextKey: "open_settings",
          context: context,
        );

        if (isOk) {
          await openAppSettings();
        }
      });
    }
  }

  Future<bool> checkContactPermission({BuildContext? context}) =>
      _checkAndGetPermission(
        Permission.contacts,
        dialogKey: "send_contacts_message",
        context: context,
        shouldShowRationalDialog: true,
        oncePersistent: settings.onceShowContactDialog,
      );

  Future<bool> checkMicrophonePermissionIsGranted() =>
      Permission.microphone.isGranted;

  Future<bool> checkAudioRecorderPermission({BuildContext? context}) =>
      _checkAndGetPermission(
        Permission.microphone,
        context: context,
        oncePersistent: settings.onceShowMicrophoneDialog,
      );

  Future<bool> checkCameraRecorderPermission({BuildContext? context}) =>
      _checkAndGetPermission(
        Permission.camera,
        context: context,
        oncePersistent: settings.onceShowCameraDialog,
      );

  Future<bool> checkMediaLibraryPermission({BuildContext? context}) =>
      _checkAndGetPermission(
        Permission.mediaLibrary,
        context: context,
        oncePersistent: settings.onceShowMediaLibraryDialog,
      );

  Future<bool> checkAccessMediaLocationPermission({
    BuildContext? context,
  }) async {
    if (isAndroidNative) {
      if (await _checkAndGetPermission(
        Permission.accessMediaLocation,
        context: context,
      )) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        return androidInfo.version.sdkInt < 32 ||
            (await _checkAndGetPermission(
              Permission.photos,
              context: context,
            ));
      }
    } else if (isIOSNative) {
      return _checkAndGetPermission(
        Permission.photos,
        context: context,
      );
    }
    return true;
  }

  Future<bool> checkLocationPermission({BuildContext? context}) =>
      _checkAndGetPermission(
        Permission.location,
        context: context,
      );

  Future<bool> haveLocationPermission() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<bool> checkStoragePermission({BuildContext? context}) async {
    if (isAndroidNative && await getAndroidVersion() < 33) {
      // Forced
      // ignore: use_build_context_synchronously
      return _checkAndGetPermission(
        Permission.storage,
        context: context,
      );
    }
    return true;
  }

  Future<Position> getCurrentPosition() async {
    if (isAndroidNative) {
      if (!await Geolocator.isLocationServiceEnabled()) {
        const intent = AndroidIntent(
          action: 'android.settings.LOCATION_SOURCE_SETTINGS',
        );
        await intent.launch();
      }
    }
    return Geolocator.getCurrentPosition();
  }
}
