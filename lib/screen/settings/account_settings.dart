import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/fluid_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AccountSettings extends StatefulWidget {
  final bool back;
  AccountSettings({Key key,this.back}) : super(key: key);

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  AppLocalization _appLocalization;
  BehaviorSubject<String> subject = new BehaviorSubject<String>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  CheckPermissionsService _checkPermission =
  GetIt.I.get<CheckPermissionsService>();
  String _username ="";
  String _newUsername = "";
  String _email="";
  String _lastName="";
  String _firstName = "";
  String _lastUserName;
  Account _account;
  final _formKey = GlobalKey<FormState>();
  final _usernameFormKey = GlobalKey<FormState>();
  bool _userNameAlreadyExit = false;
  bool _userNameCorrect = false;
  final _routingService = GetIt.I.get<RoutingService>();

  @override
  void initState() {
    super.initState();
    subject.stream
        .debounceTime(Duration(milliseconds: 250))
        .listen((username) async {
      _usernameFormKey?.currentState?.validate();
      if (_userNameCorrect) {
        if (_lastUserName != username) {
          bool validUsername = await _accountRepo.checkUserName(username);
          if (!validUsername) {
            setState(() {
              _userNameAlreadyExit = true;
            });
          }
        } else {
          setState(() {
            _userNameAlreadyExit = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        leading:  widget.back? _routingService.backButtonLeading():SizedBox.shrink(),
        title: Text(_appLocalization.getTraslateValue("account_info")),
      ),
      body: FluidContainerWidget(
        child: Stack(
          children: [
            FutureBuilder<Account>(
              future: _accountRepo.getAccount(),
              builder: (BuildContext c, AsyncSnapshot<Account> snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return SizedBox.shrink();
                }
                _account = snapshot.data;
                _lastUserName = snapshot.data.userName;
                return ListView(
                  children: [
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Form(
                              key: _usernameFormKey,
                              child: TextFormField(
                                minLines: 1,
                                initialValue: snapshot.data.userName,
                                textInputAction: TextInputAction.send,
                                onChanged: (str) {
                                  setState(() {
                                    _newUsername = str;
                                    _username = str;
                                    subject.add(str);
                                  });
                                },
                                validator: validateUsername,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: _appLocalization
                                        .getTraslateValue("username")),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            _newUsername.isEmpty
                                ? Row(
                                    children: [
                                      Text(
                                        _appLocalization
                                            .getTraslateValue("usernameHelper"),
                                        style: TextStyle(fontSize: 10,color: Colors.blueAccent
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                            _userNameAlreadyExit
                                ? Row(
                                    children: [
                                      Text(
                                        _appLocalization
                                            .getTraslateValue("usernameExit"),
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.red),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              initialValue: snapshot.data.firstName ?? "",
                              minLines: 1,
                              textInputAction: TextInputAction.send,
                              onChanged: (str) {
                                setState(() {
                                  _firstName = str;
                                });
                              },
                              validator: validateFirstName,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: _appLocalization
                                      .getTraslateValue("firstName")),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                                initialValue: snapshot.data.lastName ?? "",
                                minLines: 1,
                                textInputAction: TextInputAction.send,
                                onChanged: (str) {
                                  setState(() {
                                    _lastName = str;
                                  });
                                },
                                decoration: InputDecoration(
                                    labelText: _appLocalization
                                        .getTraslateValue("lastName"),
                                    border: OutlineInputBorder(),
                                   )),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                                initialValue: snapshot.data.email ?? "",
                                minLines: 1,
                                textInputAction: TextInputAction.send,
                                onChanged: (str) {
                                  setState(() {
                                    _email = str;
                                  });
                                },
                                validator: validateEmail,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: _appLocalization
                                        .getTraslateValue("email"))),
                            SizedBox(
                              height: 40,
                            ),
                          ],
                        )),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                child: IconButton(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.done),
                  onPressed: () async {
                    checkAndSend();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String validateFirstName(String value) {
    if (value.isEmpty) {
      return _appLocalization.getTraslateValue("firstname_not_empty");
    } else {
      return null;
    }
  }

  String validateUsername(String value) {
    Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
      setState(() {
        _userNameCorrect = false;
        _userNameAlreadyExit = false;
      });
      return _appLocalization.getTraslateValue("username_not_empty");
    } else if (!regex.hasMatch(value)) {
      setState(() {
        _userNameCorrect = false;
        _userNameAlreadyExit = false;
      });
      return _appLocalization.getTraslateValue("username_length");
    } else {
      setState(() {
        _userNameCorrect = true;
      });
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
      return null;
    } else if (!regex.hasMatch(value)) {
      return _appLocalization.getTraslateValue("email_not_valid");
    }
  }

  checkAndSend()async  {
    bool checkUserName = _usernameFormKey?.currentState?.validate() ?? false;
    if(checkUserName){
      bool isValidated = _formKey?.currentState?.validate() ?? false;
      if (isValidated) {
        if(!_userNameAlreadyExit){
          bool setPrivateInfo = await  _accountRepo.setAccountDetails(
              _username.isNotEmpty?_username: _account.userName,
              _firstName.isNotEmpty?_firstName: _account.firstName,
              _lastName.isNotEmpty?_lastName:_account.lastName,
              _email.isNotEmpty?_email: _account.email);
          if(setPrivateInfo){
            if(!widget.back){
              _requestPermissions();
              ExtendedNavigator.of(context).pushAndRemoveUntil(
                Routes.homePage,
                    (_) => false,
              );
            }
            else{
              _routingService.pop();
            }

          }
        }

      }
    }

  }
  _requestPermissions() {
    _checkPermission.checkContactPermission(context);
    _checkPermission.checkStoragePermission();
  }


}
