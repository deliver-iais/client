import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/database.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';

import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/screen/intro/pages/intro_page.dart';

import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/Widget/profileAvatar.dart';
import 'package:deliver_flutter/shared/language.dart';
import 'package:deliver_flutter/theme/dark.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  SettingState createState() => SettingState();
}

class SettingState extends State<SettingsPage> {
  bool darkMode = true;
  bool notification = true;
  var uxService = GetIt.I.get<UxService>();
  var contactDao = GetIt.I.get<ContactDao>();
  var fileRepo = GetIt.I.get<FileRepo>();

  var accountRepo = GetIt.I.get<AccountRepo>();
  var theme = false;

  final imagePicker = ImagePicker();

  bool _getTheme() {
    if (uxService.theme == DarkTheme) {
      return true;
    } else {
      return false;
    }
  }

  void _changeLanguage(Language language) {
    GetIt.I.get<UxService>().changeLanguage(language);
  }

  Widget CircleButton(Function onTap, IconData icon, double size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipOval(
          child: Material(
            color: Colors.grey, // button color
            child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: SizedBox(
                    width: size,
                    height: size,
                    child: Icon(
                      icon,
                      color: Colors.black87,
                    )),
                onTap: onTap),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
        body: DefaultTabController(
            length: 4,
            child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    ProfileAvatar(
                      innerBoxIsScrolled: innerBoxIsScrolled,
                      userUid: accountRepo.currentUserUid,
                      settingProfile: true,
                    ),
                    SliverList(
                        delegate: SliverChildListDelegate([
                      SizedBox(height: 50),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  ExtraTheme.of(context).borderOfProfilePage),
                          color: ExtraTheme.of(context).backgroundOfProfilePage,
                        ),
                        height: 60,
                        padding:
                            const EdgeInsetsDirectional.only(start: 5, end: 15),
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
                                  appLocalization.getTraslateValue("username"),
                                  style: TextStyle(
                                      color: ExtraTheme.of(context).text,
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
                                        color: ExtraTheme.of(context).text,
                                        fontSize: 13),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.navigate_next),
                                      onPressed: () {}),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  ExtraTheme.of(context).borderOfProfilePage),
                          color: ExtraTheme.of(context).backgroundOfProfilePage,
                        ),
                        height: 60,
                        padding:
                            const EdgeInsetsDirectional.only(start: 5, end: 15),
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
                                  appLocalization.getTraslateValue("phone"),
                                  style: TextStyle(
                                      color: ExtraTheme.of(context).text,
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
                                        color: ExtraTheme.of(context).text,
                                        fontSize: 13),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.navigate_next),
                                      onPressed: () {}),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  ExtraTheme.of(context).borderOfProfilePage),
                          color: ExtraTheme.of(context).backgroundOfProfilePage,
                        ),
                        height: 60,
                        padding:
                            const EdgeInsetsDirectional.only(start: 5, end: 15),
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
                                  appLocalization.getTraslateValue("darkMode"),
                                  style: TextStyle(
                                      color: ExtraTheme.of(context).text,
                                      fontSize: 13),
                                ),
                              ],
                            )),
                            Switch(
                              value: _getTheme(),
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
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    ExtraTheme.of(context).borderOfProfilePage),
                            color:
                                ExtraTheme.of(context).backgroundOfProfilePage,
                          ),
                          height: 60,
                          padding: const EdgeInsetsDirectional.only(
                              start: 5, end: 15),
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
                                  appLocalization
                                      .getTraslateValue("notification"),
                                  style: TextStyle(
                                      color: ExtraTheme.of(context).text,
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
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  ExtraTheme.of(context).borderOfProfilePage),
                          color: ExtraTheme.of(context).backgroundOfProfilePage,
                        ),
                        height: 60,
                        padding: const EdgeInsetsDirectional.only(
                            start: 5, end: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.language,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    appLocalization
                                        .getTraslateValue("changeLanguage"),
                                    style: TextStyle(
                                        color: ExtraTheme.of(context).text,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            DropdownButton(
                                hint: Text(
                                  (uxService.locale as Locale).language().name,
                                  style: TextStyle(
                                      color: ExtraTheme.of(context).text),
                                ),
                                onChanged: (Language language) {
                                  _changeLanguage(language);
                                },
                                items: Language.languageList()
                                    .map<DropdownMenuItem<Language>>((lang) =>
                                        DropdownMenuItem(
                                          value: lang,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Text(lang.flag),
                                              Text(lang.name),
                                            ],
                                          ),
                                        ))
                                    .toList())
                          ],
                        ),
                      ),
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    ExtraTheme.of(context).borderOfProfilePage),
                            color:
                                ExtraTheme.of(context).backgroundOfProfilePage,
                          ),
                          height: 60,
                          padding: const EdgeInsetsDirectional.only(
                              start: 5, end: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  child: Row(children: [
                                    GestureDetector(
                                      child:Icon(Icons.exit_to_app,size: 15,) ,
                                      onTap: (){
                                        deleteDb();
                                        Navigator.of(context).pushAndRemoveUntil(
                                            new MaterialPageRoute(
                                                builder: (context) => IntroPage()),
                                                (Route<dynamic> route) => false);
                                      },
                                    ),
                                SizedBox(width: 5,),
                              
                                Text(
                                  appLocalization.getTraslateValue("Log_out"),
                                  style: TextStyle(
                                      color: ExtraTheme.of(context).text,
                                      fontSize: 13),
                                ),
                              ])),
                            ],
                          )),
                    ])),
                  ];
                },
                body: SizedBox(
                  height: 10,
                ))));
  }

  Future<void> deleteDb() async {
    Database db = Database();
    await db.deleteAllData();
  }
}
