import 'dart:async';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';

import '../shared/methods/platform.dart';

class CheckPermissionsService {
  final _requestLock = Lock();
  final _sharedDao = GetIt.I.get<SharedDao>();

  Future<bool> checkAndGetPermission(
      Permission permission,
      String dialogKey, {
        OnceOptions? onceOption,
        BuildContext? context,
      }) =>
      advancedCheckAndGetPermission(
        permission,
        rationalDialogI18nKey: dialogKey,
        context: context,
        onceOption: onceOption,
      );

  Future<bool> advancedCheckAndGetPermission(
      Permission permission, {
        String? rationalDialogI18nKey,
        String? permanentlyDeniedDialogI18nKey,
        OnceOptions? onceOption,
        BuildContext? context,
      }) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (permanentlyDeniedDialogI18nKey != null) {
        if (onceOption != null) {
          await _sharedDao.once(onceOption, () async {
            await showPermanentlyDeniedDialog(
              permanentlyDeniedDialogI18nKey,
              context: context,
            );
          });
        } else {
          await showPermanentlyDeniedDialog(
            permanentlyDeniedDialogI18nKey,
            context: context,
          );
        }
      }

      return false;
    }

    if (rationalDialogI18nKey != null ||
        (await permission.shouldShowRequestRationale &&
            rationalDialogI18nKey != null)) {
      await showContinueAbleDialog(rationalDialogI18nKey);
    }

    return _requestLock.synchronized(() async {
      return permission.request().isGranted;
    });
  }

  Future<void> showPermanentlyDeniedDialog(
      String permanentlyDeniedDialogI18nKey, {
        BuildContext? context,
      }) async {
    final isOk = await showCancelableAbleDialog(
      permanentlyDeniedDialogI18nKey,
      okTextKey: "open_settings",
      context: context,
    );

    if (isOk) {
      await openAppSettings();
    }
  }

  Future<bool> checkContactPermission({BuildContext? context}) async {
    return checkAndGetPermission(
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
    if (isIOS) {
      try {
        return await Permission.photos.isGranted &&
            await _requestLock.synchronized(() async {
              return Permission.photos.request().isGranted;
            });
      } catch (e) {
        return false;
      }
    } else {
      try {
        return await Permission.accessMediaLocation.isGranted ||
            await _requestLock.synchronized(() async {
              return Permission.accessMediaLocation.request().isGranted;
            });
      } catch (e) {
        return false;
      }
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
