import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app_group/widgets/selective_contact_list.dart';
import 'package:deliver_flutter/services/create_muc_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/widgets/fluid_container.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MemberSelectionPage extends StatelessWidget {

  final _routingService = GetIt.I.get<RoutingService>();
  final _createMucService = GetIt.I.get<CreateMucService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();

  final Uid mucUid;
  final bool isChannel;

  MemberSelectionPage({Key key, this.isChannel,this.mucUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: _routingService.backButtonLeading(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mucUid != null? FutureBuilder<String>(
              future:_roomRepo.getName(mucUid),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if(snapshot.data!=null){
                  return    Text(
                   snapshot.data,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  );
                }else{
                  return Text(i18n.get("add_member"));
                }
              },):
            Text(
              isChannel
                  ? i18n.get("newChannel")
                  : i18n.get("newGroup"),
              style: TextStyle(fontSize: 18,color: ExtraTheme.of(context).textField, fontWeight: FontWeight.bold),
            ),

            StreamBuilder<int>(
                stream: _createMucService.selectedLengthStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox.shrink();
                  }
                  int members = snapshot.data;
                  return AnimatedDefaultTextStyle(
                    style: TextStyle(
                        fontSize: 16,
                        color: ExtraTheme
                            .of(context)
                            .textDetails,
                        fontWeight: FontWeight.bold),

                    duration: ANIMATION_DURATION,
                    curve: Curves.easeIn,
                    child: Text(
                      members >= 1
                          ? '$members ${i18n.get(
                          "of_max_member")}'
                          : i18n.get("max_member"),style: TextStyle(color: ExtraTheme.of(context).titleStatus),
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
