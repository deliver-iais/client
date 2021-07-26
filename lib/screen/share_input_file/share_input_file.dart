import 'package:deliver_flutter/Localization/i18n.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';

import 'package:deliver_flutter/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver_flutter/screen/share_input_file/shareFileWidget.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShareInputFile extends StatelessWidget{
  final List<String> inputSharedFilePath;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingServices = GetIt.I.get<RoutingService>();

  ShareInputFile({this.inputSharedFilePath,Key key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return Scaffold(

      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(title:Text(i18n.get("send_To"),style: TextStyle(color: ExtraTheme.of(context).textField),) ,leading: _routingServices.backButtonLeading(),),
      body: Column(
        children: <Widget>[
          SearchBox(),
          Expanded(
            child: FutureBuilder<List<Uid>>(
              future: _roomRepo.getAllRooms(),
              builder: (context, snapshot) {
                if(snapshot.hasData  && snapshot.data !=null && snapshot.data.length>0){

                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext ctx, int index) {
                        return ChatItemToShareFile(uid: snapshot.data[index],sharedFilePath: inputSharedFilePath,);


                      },
                    );

                } else{
                  return SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );

  }

}