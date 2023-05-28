import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/screen/profile/widgets/call_tab/widgets/call_status_details_widget.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// TODO(any): add ui design for every url in url list
class CallTabUi extends StatefulWidget {
  final int callsCount;
  final Uid roomUid;

  const CallTabUi(this.callsCount, this.roomUid, {super.key});

  @override
  CallTabUiState createState() => CallTabUiState();
}

class CallTabUiState extends State<CallTabUi> {
  final _metaRepo = GetIt.I.get<MetaRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _metaCache = <int, Meta>{};

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: widget.callsCount,
      separatorBuilder: (c, i) {
        return const Divider();
      },
      itemBuilder: (c, index) {
        return FutureBuilder<Meta?>(
          future: _metaRepo.getAndCacheMetaPage(
            widget.callsCount - index,
            MetaType.CALL,
            widget.roomUid.asString(),
            _metaCache,
          ),
          builder: (c, mediaSnapShot) {
            if (mediaSnapShot.hasData) {
              final callInfo = mediaSnapShot.data!.json.toCallInfo();
              final time = DateTime.fromMillisecondsSinceEpoch(
                callInfo.time.toInt(),
              );
              final isIncomingCall =
                  callInfo.callEventOld.callStatus == CallEvent_CallStatus.DECLINED
                      ? _authRepo.isCurrentUser(callInfo.to)
                      : _authRepo.isCurrentUser(callInfo.from);
              final caller = _authRepo.isCurrentUser(callInfo.to)
                  ? callInfo.from
                  : callInfo.to;
              return CallStatusDetailsWidget(
                callInfo: callInfo,
                time: time,
                caller: caller,
                isIncomingCall: isIncomingCall,
              );
            } else {
              return const SizedBox(
                height: 100,
              );
            }
          },
        );
      },
    );
  }
}
