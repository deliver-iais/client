import 'package:deliver_flutter/box/uid_id_name.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/screen/profile/widgets/mucMemberMentionWidget.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShowMentionList extends StatelessWidget {
  final Function onSelected;
  final String roomUid;
  final String query;

  ShowMentionList({this.query = "-", this.onSelected, this.roomUid});

  final _mucRepo = GetIt.I.get<MucRepo>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UidIdName>>(
      future: _mucRepo.getFilteredMember(roomUid, query: query),
      builder: (c, members) {
        if (members.hasData && members.data.length > 0)
          return Row(children: [
            Flexible(
                child: SizedBox(
                    height: members.data.length >= 4
                        ? 180
                        : (members.data.length * 50.0),
                    child: Container(
                        color: ExtraTheme.of(context).boxBackground,
                        child: ListView.builder(
                          itemCount: members.data.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (c, i) {
                            return MucMemberMentionWidget(
                                members.data[i], onSelected);
                          },
                        )))),
          ]);
        return SizedBox.shrink();
      },
    );
  }
}
