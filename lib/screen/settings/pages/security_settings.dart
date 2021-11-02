import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/routing_service.dart';

import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:settings_ui/settings_ui.dart';

class SecuritySettingsPage extends StatefulWidget {
  SecuritySettingsPage({Key key}) : super(key: key);

  @override
  _SecuritySettingsPageState createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();
  var _currentPass = "";
  var _pass = "";
  var _repeatedPass = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: FluidContainerWidget(
            child: AppBar(
              backgroundColor: ExtraTheme.of(context).boxBackground,
              titleSpacing: 8,
              title: Text(_i18n.get("security")),
              leading: _routingService.backButtonLeading(),
            ),
          ),
        ),
        body: FluidContainerWidget(
          child: SettingsList(
            sections: [
              SettingsSection(
                title: _i18n.get("security"),
                tiles: [
                  SettingsTile.switchTile(
                    title: _i18n.get("enable_local_lock"),
                    leading: Icon(Icons.lock),
                    switchValue: _authRepo.isLocalLockEnabled(),
                    onToggle: (bool enabled) {
                      if (enabled)
                        showDialog(
                            context: context,
                            builder: (context) {
                              return setLocalPassword();
                            });
                      else
                        showDialog(
                            context: context,
                            builder: (context) {
                              return disablePassword();
                            });
                    },
                  ),
                  if (_authRepo.isLocalLockEnabled())
                    SettingsTile(
                      title: _i18n.get("edit_password"),
                      leading: Icon(Icons.exit_to_app),
                      onPressed: (BuildContext c) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return setLocalPassword();
                            });
                      },
                      trailing: SizedBox.shrink(),
                    ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget disablePassword() {
    return StatefulBuilder(
      builder: (context, setState2) => AlertDialog(
        titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
        actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
        backgroundColor: Colors.white,
        content: TextField(
          onChanged: (p) => setState2(() => _currentPass = p),
          obscureText: true,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: _i18n.get("current_password")),
        ),
        actions: [
          Container(
            height: 40,
            child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_i18n.get("cancel"))),
          ),
          Container(
            height: 40,
            child: TextButton(
                onPressed: _currentPass.isNotEmpty
                    ? () {
                        if (_authRepo.localPasswordIsCorrect(_pass)) {
                          _authRepo.setLocalPassword("");
                          setState(() {});
                          Navigator.of(context).pop();
                        } else {
                          // TODO, show error
                        }
                      }
                    : null,
                child: Text(_i18n.get("disable"))),
          ),
        ],
      ),
    );
  }

  Widget setLocalPassword() {
    final checkCurrentPassword = _authRepo.isLocalLockEnabled();
    print(_authRepo.getLocalPassword());
    print(_pass);
    return StatefulBuilder(
      builder: (context, setState2) => AlertDialog(
        titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
        actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (checkCurrentPassword)
              TextField(
                onChanged: (p) => setState2(() => _currentPass = p),
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: _i18n.get("current_password")),
              ),
            if (checkCurrentPassword) SizedBox(height: 40),
            TextField(
              onChanged: (p) => setState2(() => _pass = p),
              obscureText: true,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: _i18n.get("password")),
            ),
            SizedBox(height: 10),
            TextField(
              onChanged: (p) => setState2(() => _repeatedPass = p),
              obscureText: true,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: _i18n.get("repeat_password")),
            ),
          ],
        ),
        actions: [
          Container(
            height: 40,
            child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_i18n.get("cancel"))),
          ),
          if (!checkCurrentPassword)
            Container(
              height: 40,
              child: TextButton(
                  onPressed: _pass == _repeatedPass && _pass.isNotEmpty
                      ? () {
                          _authRepo.setLocalPassword(_pass);
                          setState(() {});
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text(_i18n.get("save"))),
            ),
          if (checkCurrentPassword)
            Container(
              height: 40,
              child: TextButton(
                  onPressed: _pass == _repeatedPass &&
                          _pass.isNotEmpty &&
                          _currentPass.isNotEmpty
                      ? () {
                          if (_authRepo.localPasswordIsCorrect(_currentPass)) {
                            _authRepo.setLocalPassword(_pass);
                            setState(() {});
                            Navigator.of(context).pop();
                          } else {
                            // TODO, show error
                          }
                        }
                      : null,
                  child: Text(_i18n.get("change"))),
            ),
        ],
      ),
    );
  }
}
