import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app_group/widgets/selective_contact_list.dart';
import 'package:deliver_flutter/services/create_muc_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/fluid_container.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MemberSelectionPage extends StatelessWidget {

  Uid mucUid;
  var _routingService = GetIt.I.get<RoutingService>();
  var _createMucService = GetIt.I.get<CreateMucService>();
  final bool isChannel;
  var _roomRepo = GetIt.I.get<RoomRepo>();

  MemberSelectionPage({Key key, this.isChannel,this.mucUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: _routingService.backButtonLeading(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mucUid != null? FutureBuilder<String>(
              future:_roomRepo.getRoomDisplayName(mucUid),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if(snapshot.data!=null){
                  return    Text(
                   snapshot.data,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  );
                }else{
                  return Text(appLocalization.getTraslateValue("AddMember"));
                }
              },):
            Text(
              isChannel
                  ? appLocalization.getTraslateValue("newChannel")
                  : appLocalization.getTraslateValue("newGroup"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            StreamBuilder<int>(
                stream: _createMucService.selectedLengthStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox.shrink();
                  }
                  int members = snapshot.data;
                  return AnimatedDefaultTextStyle(
                    style: members > 0
                        ? TextStyle(
                        fontSize: 16,
                        color: Theme
                            .of(context)
                            .primaryColor,
                        fontWeight: FontWeight.bold)
                        : TextStyle(
                        fontSize: 14,
                        color: Theme
                            .of(context)
                            .accentColor,
                        fontWeight: FontWeight.w100),
                    duration: ANIMATION_DURATION,
                    curve: Curves.easeIn,
                    child: Text(
                      members >= 1
                          ? '$members ${appLocalization.getTraslateValue(
                          "ofMaxMember")}'
                          : appLocalization.getTraslateValue("maxMember"),
                    ),
                  );
                })
          ],
        ),
      ),
      body: FluidContainerWidget(
        child: SelectiveContactsList(isChannel: isChannel,mucUid: mucUid,),
      ),
    );
  }
}
