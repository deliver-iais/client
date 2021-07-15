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
  final bool uploadNewAvatar;
  final String newAvatarPath;
  final _routingServices = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();

  ProfileAvatarCard({this.uid, this.uploadNewAvatar, this.newAvatarPath});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
