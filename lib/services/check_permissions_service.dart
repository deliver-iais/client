
import 'package:permissions_plugin/permissions_plugin.dart';

class CheckPermissionsService {
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
    try {
      return (await PermissionsPlugin.requestPermissions(permission))
          .values
          .every(
              (permissionState) => permissionState == PermissionState.GRANTED);
    } catch (e) {
      return false;
    }
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

  checkStoragePermission() async {
    if (!await check([
      Permission.READ_EXTERNAL_STORAGE,
      Permission.WRITE_EXTERNAL_STORAGE
    ])) {
      request([
        Permission.READ_EXTERNAL_STORAGE,
        Permission.WRITE_EXTERNAL_STORAGE
      ]);
    }
  }

  checkLocationPermission() async {
    if (!await check([Permission.ACCESS_FINE_LOCATION])) {
      request([Permission.ACCESS_FINE_LOCATION]);
    }
  }
}
