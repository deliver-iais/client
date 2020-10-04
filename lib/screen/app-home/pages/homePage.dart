import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/models/app_mode.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/chatsPage.dart';
import 'package:deliver_flutter/screen/app-contacts/widgets/contactsPage.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/services/mode_checker.dart';
import 'package:deliver_flutter/shared/appbar.dart';
import 'package:deliver_flutter/screen/app-home/widgets/navigationBar.dart';
import 'package:deliver_flutter/screen/app-home/widgets/searchBox.dart';
import 'package:deliver_flutter/shared/mainWidget.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatelessWidget {
  var modeChecker = GetIt.I.get<ModeChecker>();

  @override
  Widget build(BuildContext context) {
    Fimber.d(RouteData.of(context).path);
    AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
    return StreamBuilder<AppMode>(
        stream: modeChecker.appMode,
        builder: (context, mode) {
          return StreamBuilder<bool>(
              stream: audioPlayerService.isOn,
              builder: (context, snapshot) {
                return Scaffold(
                  backgroundColor: Theme.of(context).backgroundColor,
                  appBar: PreferredSize(
                    preferredSize:
                        Size.fromHeight(snapshot.data == true ? 100 : 60),
                    child: Appbar(),
                  ),
                  body: MainWidget(
                      Column(
                        children: <Widget>[
                          SearchBox(),
                          if (isHomePage(context))
                            ChatsPage()
                          else
                            ContactsPage(),
                        ],
                      ),
                      16,
                      16),
                  bottomNavigationBar: NavigationBar(),
                );
              });
        });
  }

  isHomePage(context) => RouteData.of(context).path == Routes.homePage;
}
