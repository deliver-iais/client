import 'dart:io';

import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/downloadFileServices.dart';
import 'package:deliver_flutter/services/uploadFileServices.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/dark.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';

class SettingsPage extends StatefulWidget {
  SettingState createState() => SettingState();
}

class SettingState extends State<SettingsPage> {
  bool darkMode = true;
  bool notification = true;
  var uxService = GetIt.I.get<UxService>();
  var avatarDao = GetIt.I.get<AvatarDao>();
  var contactDao = GetIt.I.get<ContactDao>();
  var downloadFile = GetIt.I.get<DownloadFileServices>();
  var fileRepo = GetIt.I.get<FileRepo>();
  
  var accountRepo = GetIt.I.get<AccountRepo>();
  var theme = false;


  bool _getTheme(){
    if(uxService.theme == DarkTheme){
      return true;
    }else{
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
        CircleAvatarWidget("JD",65),
        SizedBox(height: 19),
        Text("John Due", style: TextStyle(color: Colors.white, fontSize: 25)),
        Container(
          margin: const EdgeInsets.only(top: 70),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsetsDirectional.only(start: 20, end: 5),
                color: Theme
                    .of(context)
                    .bottomAppBarColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'User Name',
                              style: TextStyle(
                                  color: ExtraTheme
                                      .of(context)
                                      .text,
                                  fontSize: 13),
                            ),
                          ],
                        )),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Text(
                            'john_due',
                            style: TextStyle(
                                color: ExtraTheme
                                    .of(context)
                                    .text,
                                fontSize: 13),
                          ),
                          IconButton(
                              icon: Icon(Icons.navigate_next),
                              onPressed: () async {
                                File file = await FilePicker.getFile();
                                if(file.existsSync()){
                                  UploadFile().httpUploadFile(file);
                                }

                              }),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: .8,
              ),
              Container(
                padding: const EdgeInsetsDirectional.only(start: 20, end: 5),
                color: Theme
                    .of(context)
                    .bottomAppBarColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Phone',
                              style: TextStyle(
                                  color: ExtraTheme
                                      .of(context)
                                      .text,
                                  fontSize: 13),
                            ),
                          ],
                        )),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Text(
                            '091222222222',
                            style: TextStyle(
                                color: ExtraTheme
                                    .of(context)
                                    .text,
                                fontSize: 13),
                          ),
                          IconButton(
                              icon: Icon(Icons.navigate_next),
                              onPressed: (){
                                downloadFile.downloadFile("url", "");
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Container(
                padding: const EdgeInsetsDirectional.only(start: 20, end: 15),
                color: Theme
                    .of(context)
                    .bottomAppBarColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        child: Row(
                          children: [
                            Icon(
                              Icons.brightness_2,
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Dark Mode',
                              style: TextStyle(
                                  color: ExtraTheme
                                      .of(context)
                                      .text,
                                  fontSize: 13),
                            ),
                          ],
                        )),
                    Switch(

                      value:_getTheme() ,
                      onChanged: (newThemMode) {
                        setState(() {
                          uxService.toggleTheme();
                          darkMode = newThemMode;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: .8,
              ),
              Container(
                  padding:
                  const EdgeInsetsDirectional.only(start: 20, end: 15),
                  color: Theme
                      .of(context)
                      .bottomAppBarColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Row(children: [
                            Icon(
                              Icons.notifications_active,
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Notification',
                              style: TextStyle(
                                  color: ExtraTheme
                                      .of(context)
                                      .text,
                                  fontSize: 13),
                            ),
                          ])),
                      Switch(
                        value: notification,
                        onChanged: (newNotifState) {
                          setState(() {
                            notification = newNotifState;
                          });
                        },
                      ),
                    ],
                  )),
            ],
          ),
        )
        ],
      ),
    );
  }
}
