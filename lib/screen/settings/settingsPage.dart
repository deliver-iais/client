import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatefulWidget {
  SettingState createState() => SettingState();
}

class SettingState extends State<SettingsPage> {

  bool darkMode = true;
  bool notification = true;
  var uxService = GetIt.I.get<UxService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 56,
            backgroundColor: ExtraTheme.of(context).circleAvatarBackground,
            child: FittedBox(
              child: Icon(
                Icons.person,
                color: ExtraTheme.of(context).circleAvatarIcon,
                size: 45,
              ),
            ),
          ),
          SizedBox(height: 19),
          Text("John Due",
              style: TextStyle(
                  color: Colors.white, fontSize: 25)),
          Container(
            margin: const EdgeInsets.only(top: 70),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsetsDirectional.only(start: 20, end: 5),
                  color: Theme.of(context).bottomAppBarColor,
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
                                    color: ExtraTheme.of(context).text, fontSize: 13),
                              ),
                            ],
                          )),
                      Container(
                        child: Row(
                          children: <Widget>[
                            Text(
                              'john_due',
                              style: TextStyle(
                                  color: ExtraTheme.of(context).text, fontSize: 13),
                            ),
                            IconButton(
                                icon: Icon(Icons.navigate_next),
                                onPressed: null),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: .8,
                ),
                Container(
                  padding: const EdgeInsetsDirectional.only(start: 20, end: 5),
                  color: Theme.of(context).bottomAppBarColor,
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
                                    color: ExtraTheme.of(context).text, fontSize: 13),
                              ),
                            ],
                          )),
                      Container(
                        child: Row(
                          children: <Widget>[
                            Text(
                              '091222222222',
                              style: TextStyle(
                                  color: ExtraTheme.of(context).text, fontSize: 13),
                            ),
                            IconButton(
                                icon: Icon(Icons.navigate_next),
                                onPressed: null),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  padding: const EdgeInsetsDirectional.only(start: 20, end: 15),
                  color: Theme.of(context).bottomAppBarColor,
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
                                    color: ExtraTheme.of(context).text, fontSize: 13),
                              ),
                            ],
                          )),
                      Switch(
                        value: darkMode,
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
                SizedBox(height: .8,),
                Container(
                    padding: const EdgeInsetsDirectional.only(start: 20, end: 15),
                    color: Theme.of(context).bottomAppBarColor,
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
                                    color: ExtraTheme.of(context).text, fontSize: 13),
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
