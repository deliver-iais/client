import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/screen/app-room/widgets/joint_to_muc_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:rxdart/subjects.dart';
class searchInMessageButtom extends StatefulWidget{

  @override
  _searchInMessageButtomState createState() => _searchInMessageButtomState();

  final String roomId;
  final Function scrollDown;
  final Function scrollUp;
  final Function  keybrodWidget;
  final bool joinToMuc;
  final BehaviorSubject<bool> searchMode;
  final List<Message> searchResult;
  final Message currentSearchResultMessage;


  searchInMessageButtom({this.roomId,this.scrollDown,this.scrollUp,this.joinToMuc,this.searchMode,this.searchResult,this.currentSearchResultMessage,this.keybrodWidget});
}


class _searchInMessageButtomState extends State<searchInMessageButtom> {



  AppLocalization _appLocalization;
  var _mucRepo = GetIt.I.get<MucRepo>();
  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
   return StreamBuilder(
      stream: widget.searchMode.stream,
      builder: (c, s) {
        if (s.hasData && s.data && widget.searchResult.length > 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text((widget.searchResult.length -
                  widget.searchResult
                      .indexOf(widget.currentSearchResultMessage))
                  .toString()),
              SizedBox(
                width: 5,
              ),
              Text(_appLocalization.getTraslateValue("of")),
              SizedBox(
                width: 5,
              ),
              Text(widget.searchResult.length.toString()),
              SizedBox(
                width: 20,
              ),
              IconButton(
                icon: Icon(Icons.arrow_upward_rounded),
                onPressed: () {
                widget.scrollUp();
                },
              ),
              IconButton(
                  icon: Icon(Icons.arrow_downward_rounded),
                  onPressed: () {
                   widget.scrollDown();
                  })
            ],
          );
        } else {
          return (widget.joinToMuc != null && widget.joinToMuc)
              ? StreamBuilder<Member>(
              stream: _mucRepo.checkJointToMuc(
                  roomUid: widget.roomId),
              builder: (c, isJoint) {
                if (isJoint.hasData && isJoint.data != null) {
                  return widget.keybrodWidget();
                } else {
                  return JointToMucWidget(widget.roomId.getUid());
                }
              })
              : widget.keybrodWidget();
        }
      },
    );
  }
}