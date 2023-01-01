import 'dart:async';

import 'package:deliver/shared/methods/dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';

class CheckPermissionsService {
  final requestLock = Lock();

  Future<bool> checkAndGetPermission(
    Permission permission, {
    String? rationalDialogI18nKey,
    String? permanentlyDeniedDialogI18nKey,
    BuildContext? context,
  }) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied && permanentlyDeniedDialogI18nKey != null) {
      final isOk = await showCancelableAbleDialog(
        permanentlyDeniedDialogI18nKey,
        okTextKey: "open_settings",
        context: context,
      );

      if (isOk) {
        unawaited(openAppSettings());
      }

      return false;
    }

    if (rationalDialogI18nKey != null ||
        (await permission.shouldShowRequestRationale &&
            rationalDialogI18nKey != null)) {
      await showContinueAbleDialog(rationalDialogI18nKey);
    }

    return requestLock.synchronized(() async {
      return permission.request().isGranted;
    });
  }

  Future<bool> checkContactPermission() async {
    try {
      if (!await Permission.contacts.isGranted) {
        return await requestLock.synchronized(() async {
          return Permission.contacts.request().isGranted;
        });
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
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
          await requestLock.synchronized(() async {
            return Permission.mediaLibrary.request().isGranted;
          });
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkAccessMediaLocationPermission() async {
    try {
      return await Permission.accessMediaLocation.isGranted ||
          await requestLock.synchronized(() async {
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
