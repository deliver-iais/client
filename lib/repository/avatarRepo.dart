import 'package:deliver_flutter/generated-protocol/pub/v1/avatar.pbgrpc.dart';
import 'package:deliver_flutter/generated-protocol/pub/v1/models/avatar.pb.dart';
import 'package:deliver_flutter/generated-protocol/pub/v1/models/uid.pb.dart';
import 'package:grpc/grpc.dart';

class AvatarRepo {
  static ClientChannel clientChannel = ClientChannel('172.16.111.171',
      port: 30000,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));
  var AvatarServices = AvatarServiceClient(clientChannel);

  getAvatar(List<Uid> list) {
    var getAvatarReq = GetAvatarReq();
    list.forEach((element) {getAvatarReq.uidList.add(element);});
    var getAvatars = AvatarServices.getAvatar(getAvatarReq);
    getAvatars.then((res) => {

      // todo
    }).
    catchError((e)=>{

    });



  }
}
