import 'package:permissions_plugin/permissions_plugin.dart';
import 'package:synchronized/synchronized.dart';

class CheckPermissionsService {
  var requestLock = new Lock();

  Future<bool> check(List<Permission> permissions) async {
    try {
      return (await PermissionsPlugin.checkPermissions(permissions))
          .values
          .every(
              (permissionState) => permissionState == PermissionState.GRANTED);
    } catch (e) {
      return false;
    }
  }

  Future<bool> request(List<Permission> permission) async {
    return await requestLock.synchronized(() async {
      try {
        return (await PermissionsPlugin.requestPermissions(permission))
            .values
            .every((permissionState) =>
                permissionState == PermissionState.GRANTED);
      } catch (e) {
        return false;
      }
    });
  }
}

extension PermissionsExtension on CheckPermissionsService {
  Future<bool> checkContactPermission() async {
    if (!await check([Permission.READ_CONTACTS])) {
      return await request([Permission.READ_CONTACTS]);
    } else {
      return true;
    }
  }

  Future<bool> checkAudioRecorderPermission() async {
    if (!await check([Permission.RECORD_AUDIO])) {
      return request([Permission.RECORD_AUDIO]);
    } else {
      return true;
    }
  }

  Future<bool> checkStoragePermission() async {
    if (!await check([
      Permission.READ_EXTERNAL_STORAGE,
      Permission.WRITE_EXTERNAL_STORAGE
    ])) {
      return request([
        Permission.READ_EXTERNAL_STORAGE,
        Permission.WRITE_EXTERNAL_STORAGE
      ]);
    } else {
      return true;
    }
  }

  checkLocationPermission() async {
    if (!await check([Permission.ACCESS_FINE_LOCATION])) {
      request([Permission.ACCESS_FINE_LOCATION]);
    }
  }
}
