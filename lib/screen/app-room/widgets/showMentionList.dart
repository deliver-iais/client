import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/memberWidget.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/mucMemberMentionWidget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShowMentionList extends StatelessWidget {
  final Function onSelected;
  final String roomUid;
  MemberDao _memberDao = GetIt.I.get<MemberDao>();

  ShowMentionList(this.onSelected, this.roomUid);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Member>>(
        future: _memberDao.getByMucUidFuture(this.roomUid),
        builder: (c, AsyncSnapshot<List<Member>> members) {
          if (members.hasData && members.data != null) {
            return Row(
              children: [
                Flexible(
                    child: SizedBox(
                        height: 180,
                        child: Container(
                            color: Theme.of(context).accentColor,
                            child: ListView.builder(
                              itemCount: members.data.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (c, i) {
                                return MucMemberMentionWidget(
                                    members.data[i], onSelected);
                              },
                            ))))
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        });
  }
}
