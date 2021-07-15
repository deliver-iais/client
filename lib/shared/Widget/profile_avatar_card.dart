import 'dart:io';

import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../floating_modal_bottom_sheet.dart';

class ProfileAvatarCard extends StatelessWidget {
  final Uid uid;
  final List<Widget> buttons;
  final bool uploadNewAvatar;
  final String newAvatarPath;
  final _routingServices = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();

  ProfileAvatarCard(
      {this.uid, this.buttons, this.uploadNewAvatar, this.newAvatarPath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(MAIN_BORDER_RADIUS),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  width: 160,
                  height: 160,
                  child: Stack(
                    children: [
                      Hero(
                        tag: "avatar",
                        child: newAvatarPath != null
                            ? CircleAvatar(
                                radius: 80,
                                backgroundImage:
                                    Image.file(File(newAvatarPath)).image,
                                child: Center(
                                  child: SizedBox(
                                      height: 50.0,
                                      width: 50.0,
                                      child: uploadNewAvatar
                                          ? CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.blue),
                                              strokeWidth: 6.0,
                                            )
                                          : SizedBox.shrink()),
                                ),
                              )
                            : CircleAvatarWidget(
                                uid,
                                80,
                                showAsStreamOfAvatar: true,
                              ),
                      ),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            color: ExtraTheme.of(context).profileAvatarCard,
                            child: IconButton(
                              // color: ,
                              onPressed: () async {
                                var account = await _accountRepo.getAccount();
                                showQrCode(
                                    context,
                                    buildShareUserUrl(
                                        account.countryCode,
                                        account.nationalNumber,
                                        account.firstName,
                                        account.lastName));
                              },
                              padding: EdgeInsets.zero,
                              iconSize: 34,
                              icon: Container(
                                color: Theme.of(context).cardColor,
                                child: Icon(Icons.qr_code_rounded,
                                    color: Colors.white),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
                onTap: () async {
                  var lastAvatar = await _avatarRepo.getLastAvatar(
                      _accountRepo.currentUserUid, false);
                  if (lastAvatar.createdOn != null) {
                    _routingServices.openShowAllAvatars(
                        uid: uid,
                        hasPermissionToDeleteAvatar: true,
                        heroTag: "avatar");
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              FutureBuilder<Account>(
                future: _accountRepo.getAccount(),
                builder:
                    (BuildContext context, AsyncSnapshot<Account> snapshot) {
                  if (snapshot.data != null) {
                    return Text(
                      "${snapshot.data.firstName}${snapshot.data.lastName ?? ""}",
                      style: TextStyle(
                          fontSize: 25,
                          color: ExtraTheme.of(context).textField),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttons,
              )
            ],
          ),
          color: ExtraTheme.of(context).profileAvatarCard,
        ));
  }
}
