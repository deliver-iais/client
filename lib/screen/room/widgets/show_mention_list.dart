import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/profile/widgets/muc_member_mention_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// ignore: constant_identifier_names
const HEIGHT = 52.0;

class ShowMentionList extends StatelessWidget {
  final void Function(String) onSelected;
  final String roomUid;
  final String query;
  final int mentionSelectedIndex;

  ShowMentionList({
    Key? key,
    this.query = "-",
    required this.onSelected,
    required this.roomUid,
    required this.mentionSelectedIndex,
  }) : super(key: key);

  final _mucRepo = GetIt.I.get<MucRepo>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<UidIdName?>?>(
      future: _mucRepo.getFilteredMember(roomUid, query: query),
      builder: (c, members) {
        if (members.hasData && members.data!.isNotEmpty) {
          return Row(
            children: [
              Flexible(
                child: SizedBox(
                  height: members.data!.length >= 4
                      ? HEIGHT * 4
                      : (members.data!.length * HEIGHT),
                  child: Container(
                    color: theme.backgroundColor,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: members.data!.length,
                      shrinkWrap: true,
                      itemBuilder: (c, i) {
                        var _mucMemberMentionColor = Colors.transparent;
                        if (mentionSelectedIndex == i &&
                            mentionSelectedIndex != -1) {
                          _mucMemberMentionColor = theme.focusColor;
                        }
                        return Container(
                          color: _mucMemberMentionColor,
                          child: MucMemberMentionWidget(
                            members.data![i]!,
                            onSelected,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
