import 'dart:ui';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AccountInfo extends StatefulWidget {
  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  AppLocalization _appLocalization;
  BehaviorSubject<String> subject = new BehaviorSubject<String>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  String _username;
  String _newUsername = "";
  String _email;
  String _lastName;
  String _firstName;
  String _lastUserName;
  final _formKey = GlobalKey<FormState>();
  final _usernameFormKey = GlobalKey<FormState>();
  bool _userNameNotValid = false;
  bool _userNameCorrect = false;

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
              _userNameNotValid = true;
            });
          }
        } else {
          setState(() {
            _userNameNotValid = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: IconButton(
          icon: Icon(
            Icons.check,
            color: Colors.white,
          ),
          iconSize: 30,
          onPressed: () {
            checkAndSend();
          },
        ),
      ),
      appBar: AppBar(
        title: Text(_appLocalization.getTraslateValue("account_info")),
      ),
      body: Container(
          padding: const EdgeInsets.only(top: 80),
          color: Theme.of(context).backgroundColor,
          child: FutureBuilder<Account>(
            future: _accountRepo.getAccount(),
            builder: (BuildContext c, AsyncSnapshot<Account> snapshot) {
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
                                  hintText: _appLocalization
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
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                )
                              : SizedBox.shrink(),
                          _userNameNotValid
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
                                hintText: _appLocalization
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
                                  border: OutlineInputBorder(),
                                  hintText: _appLocalization
                                      .getTraslateValue("lastName"))),
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
                                  hintText: _appLocalization
                                      .getTraslateValue("email"))),
                          SizedBox(
                            height: 40,
                          ),
                        ],
                      )),
                ],
              );
            },
          )),
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
        _userNameNotValid = false;
      });
      return _appLocalization.getTraslateValue("username_not_empty");
    } else if (!regex.hasMatch(value)) {
      setState(() {
        _userNameCorrect = false;
        _userNameNotValid = false;
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

  checkAndSend() {
    bool isValidated = _formKey?.currentState?.validate() ?? false;
    if (isValidated) {
      _accountRepo.setAccountDetails(_username, _firstName, _lastName, _email);
    }
  }
}
