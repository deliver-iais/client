import 'dart:async';
import 'dart:math';

import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/profile/widgets/muc_member_mention_widget.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ShowMentionList extends StatefulWidget {
  final void Function(String) onIdClick;
  final void Function({required String name, required String node}) onNameClick;
  final Uid roomUid;
  final String query;
  final BehaviorSubject<int> mentionSelectedIndex;

  const ShowMentionList({
    super.key,
    this.query = "-",
    required this.onIdClick,
    required this.onNameClick,
    required this.roomUid,
    required this.mentionSelectedIndex,
  });

  @override
  State<ShowMentionList> createState() => _ShowMentionListState();
}

class _ShowMentionListState extends State<ShowMentionList> {
  final _mucRepo = GetIt.I.get<MucRepo>();
  final ItemScrollController controller = ItemScrollController();
  int _itemCount = 0;
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    _streamSubscription =
        widget.mentionSelectedIndex.distinct().listen((index) {
      if (controller.isAttached) {
        controller.scrollTo(
          index: index % _itemCount,
          duration: const Duration(milliseconds: 100),
          alignment: getAlignment(index, _itemCount),
        );
      }
    });
    super.initState();
  }

  double getAlignment(int index, int count) {
    final i = index % count;
    if (i == 0) {
      return 0;
    } else if (i == count - 2) {
      return 0.5;
    } else if (i == count - 1) {
      return 0.75;
    } else {
      return 0.25;
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<Member>>(
      future: _mucRepo.getFilteredMember(widget.roomUid, query: widget.query),
      builder: (c, members) {
        if (members.hasData && members.data!.isNotEmpty) {
          _itemCount = members.data?.length ?? 0;
          return Row(
            children: [
              Flexible(
                child: SizedBox(
                  height: min(members.data!.length, 4) * 48.0,
                  child: Container(
                    color: theme.colorScheme.background,
                    child: ScrollablePositionedList.builder(
                      padding: EdgeInsets.zero,
                      itemScrollController: controller,
                      itemCount: members.data!.length,
                      shrinkWrap: true,
                      itemBuilder: (c, i) {
                        return StreamBuilder<int>(
                          stream: widget.mentionSelectedIndex.stream,
                          builder: (context, snapshot) {
                            final index = (snapshot.data ?? 0) % _itemCount;
                            var mucMemberMentionColor = Colors.transparent;
                            if (index == i && index != -1 && isDesktopNative) {
                              mucMemberMentionColor = theme.focusColor;
                            }

                            return Container(
                              color: mucMemberMentionColor,
                              child: MucMemberMentionWidget(
                                member: members.data![i],
                                onIdClick: widget.onIdClick,
                                onNameClick: widget.onNameClick,
                              ),
                            );
                          },
                        );
                      },
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
