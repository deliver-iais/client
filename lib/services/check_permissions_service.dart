import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';

class CheckPermissionsService {
  var requestLock = Lock();
}

extension PermissionsExtension on CheckPermissionsService {
  Future<bool> checkContactPermission() async {
    try {
      if (!await Permission.contacts.isGranted) {
        return await requestLock.synchronized(() async {
          return await Permission.contacts.request().isGranted;
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

  Future<bool> checkStoragePermission() async {
    try {
      if (!await Permission.accessMediaLocation.isGranted) {
        return await requestLock.synchronized(() async {
          return await Permission.accessMediaLocation.request().isGranted;
        });
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
