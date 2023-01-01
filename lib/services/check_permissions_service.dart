import 'dart:async';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';

class CheckPermissionsService {
  final _requestLock = Lock();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final grantedPermissions = <int>{};
  final permanentlyDeniedPermissions = <int>{};

  Future<bool> _checkAndGetPermission(
    Permission permission,
    String dialogKey, {
    OnceOptions? onceOption,
    BuildContext? context,
  }) =>
      _advancedCheckAndGetPermission(
        permission,
        rationalDialogI18nKey: dialogKey,
        permanentlyDeniedDialogI18nKey: dialogKey,
        context: context,
        onceOptions: onceOption,
      );

  Future<bool> _advancedCheckAndGetPermission(
    Permission permission, {
    String? rationalDialogI18nKey,
    String? permanentlyDeniedDialogI18nKey,
    bool shouldShowRationalDialog = false,
    OnceOptions? onceOptions,
    BuildContext? context,
  }) async {
    if (grantedPermissions.contains(permission.value)) {
      return true;
    }

    final status = await permission.status;

    if (status.isGranted) {
      grantedPermissions.add(Permission.contacts.value);
      return true;
    }

    if (permanentlyDeniedPermissions.contains(permission.value)) {
      await showPermanentlyDeniedDialog(
        permanentlyDeniedDialogI18nKey: permanentlyDeniedDialogI18nKey,
        onceOptions: onceOptions,
        context: context,
      );

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
        permanentlyDeniedPermissions.add(Permission.contacts.value);

        await showPermanentlyDeniedDialog(
          permanentlyDeniedDialogI18nKey: permanentlyDeniedDialogI18nKey,
          onceOptions: onceOptions,
          context: context,
        );

        return false;
      } else if (s.isGranted) {
        grantedPermissions.add(Permission.contacts.value);

        return true;
      } else {
        return false;
      }
    });
  }

  Future<void> showPermanentlyDeniedDialog({
    String? permanentlyDeniedDialogI18nKey,
    OnceOptions? onceOptions,
    BuildContext? context,
  }) async {
    if (permanentlyDeniedDialogI18nKey != null) {
      return _sharedDao.once(onceOptions, () async {
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

  Future<bool> checkContactPermission({BuildContext? context}) {
    return _checkAndGetPermission(
      Permission.contacts,
      "send_contacts_message",
      context: context,
      onceOption: ONCE_SHOW_CONTACT_DIALOG,
    );
  }

  Future<bool> checkAudioRecorderPermission() async {
    try {
      if (!await Permission.microphone.isGranted) {
        return await Permission.microphone.request().isGranted;
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkCameraRecorderPermission() async {
    try {
      if (!await Permission.camera.isGranted) {
        return await Permission.camera.request().isGranted;
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkMediaLibraryPermission() async {
    try {
      return await Permission.mediaLibrary.isGranted &&
          await _requestLock.synchronized(() async {
            return Permission.mediaLibrary.request().isGranted;
          });
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkAccessMediaLocationPermission() async {
    try {
      return await Permission.accessMediaLocation.isGranted ||
          await _requestLock.synchronized(() async {
            return Permission.accessMediaLocation.request().isGranted;
          });
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkLocationPermission() async {
    try {
      if (!await Permission.location.isGranted) {
        return await Permission.location.request().isGranted;
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }

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
}
