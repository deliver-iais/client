import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:rxdart/subjects.dart';

class MucMemberMentionWidget extends StatelessWidget {
  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _contactRepo = GetIt.I.get<ContactRepo>();
  final Member member;
  Function onSelected;

  MucMemberMentionWidget(this.member, this.onSelected);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: 10),child: Column(
      children: [
        SizedBox(
          height: 10,
        ),
        FutureBuilder<Contact>(
          future: _contactRepo.getContact(member.memberUid.uid),
          builder: (BuildContext context, AsyncSnapshot<Contact> contact) {
            if (contact.data != null &&
                member.memberUid != _accountRepo.currentUserUid.asString()) {
              return Row(
                children: [
                  CircleAvatarWidget(member.memberUid.uid, 18),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      onSelected(contact.data.username);
                    },
                    child: Text(
                      contact.data.firstName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            } else if (member.memberUid ==
                _accountRepo.currentUserUid.asString()) {
              return FutureBuilder<Account>(
                future: _accountRepo.getAccount(),
                builder:
                    (BuildContext context, AsyncSnapshot<Account> snapshot) {
                  if (snapshot.data != null) {
                    return Row(
                      children: [
                        CircleAvatarWidget(member.memberUid.uid, 18),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            onSelected(snapshot.data.userName);
                          },
                          child: Text(
                            "${snapshot.data.firstName} ${snapshot.data.lastName ?? ""}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
      ],
    ));
  }
}
