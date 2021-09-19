import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/profile/widgets/mucMemberMentionWidget.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:we/box/uid_id_name.dart';
import 'package:we/repository/mucRepo.dart';
import 'package:we/screen/profile/widgets/mucMemberMentionWidget.dart';
import 'package:we/theme/extra_theme.dart';

const HEIGHT = 52.0;

class ShowMentionList extends StatelessWidget {
  final Function onSelected;
  final String roomUid;
  final String query;
  final int mentionSelectedIndex;

  ShowMentionList(
      {this.query = "-",
      this.onSelected,
      this.roomUid,
      this.mentionSelectedIndex});

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
                        ? HEIGHT * 4
                        : (members.data.length * HEIGHT),
                    child: Container(
                        color: ExtraTheme.of(context).boxBackground,
                        child: ListView.separated(
                          itemCount: members.data.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (c, i) {
                            Color _mucMemberMentionColor = Colors.transparent;
                            if (mentionSelectedIndex == i &&
                                mentionSelectedIndex != -1)
                              _mucMemberMentionColor =
                                  Theme.of(context).focusColor;
                            return Container(
                              color: _mucMemberMentionColor,
                              child: MucMemberMentionWidget(
                                  members.data[i], onSelected),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(
                                  color: ExtraTheme.of(context)
                                      .boxOuterBackground),
                        )))),
          ]);
        return SizedBox.shrink();
      },
    );
  }
}
