import 'package:flutter/material.dart';
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

  Future<bool> request(List<Permission> permission) {
    PermissionsPlugin.requestPermissions(permission);
  }
}

extension PermissionsExtension on CheckPermissionsService {
  checkContactPermission(BuildContext context) async {
    if (!await check([Permission.READ_CONTACTS])) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
              actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
              backgroundColor: Colors.white,
              title: Container(
                height: 80,
                color: Colors.blue,
                child: Icon(
                  Icons.contacts,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              content: Text(
                  "Dliver needs access to your contacts so that you can connect with "
                  "your friend across all your device. your contacts will be continuously "
                  "synced with Dliver's  heavily encrypted cloud servers.",
                  style: TextStyle(color: Colors.black, fontSize: 18)),
              actions: <Widget>[
                GestureDetector(
                  child: Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pop(request([Permission.READ_CONTACTS]));
                  },
                )
              ],
            );
          });
    }
  }

  Future<bool> checkAudioRecorderPermission() async {
    if (!await check([Permission.RECORD_AUDIO])) {
      request([Permission.RECORD_AUDIO]);
      return false;
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
