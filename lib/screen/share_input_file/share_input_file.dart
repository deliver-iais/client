import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';

import 'package:deliver_flutter/screen/navigation_center/widgets/searchBox.dart';
import 'package:deliver_flutter/screen/share_input_file/shareFileWidget.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShareInputFile extends StatelessWidget{
  final List<String> inputSharedFilePath;
  final _roomRepo = GetIt.I.get<RoomRepo>();

  ShareInputFile({this.inputSharedFilePath});

  @override
  Widget build(BuildContext context) {
    AppLocalization i18n = AppLocalization.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(title:Text(i18n.getTraslateValue("send_To")) ,),
      body: Column(
        children: <Widget>[
          SearchBox(),
          Expanded(
            child: FutureBuilder<List<Uid>>(
              future: _roomRepo.getAllRooms(),
              builder: (context, snapshot) {
                if(snapshot.hasData  && snapshot.data !=null && snapshot.data.length>0){
                  return Container(
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext ctx, int index) {
                        return GestureDetector(
                          child: ChatItemToShareFile(uid: snapshot.data[index],sharedFilePath: inputSharedFilePath,),
                          onTap: () {
                          },
                        );
                      },
                    ),
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