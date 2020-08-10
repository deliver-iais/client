import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/avatar.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:grpc/grpc.dart';

class AvatarRepo {
  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().avatarConnection.host,
      port: ServicesDiscoveryRepo().avatarConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));
  var avatarServices = AvatarServiceClient(clientChannel);

  getAvatar(List<Uid> list) {
    var getAvatarReq = GetAvatarReq();
    list.forEach((element) {
      getAvatarReq.uidList.add(element);
    });
    var getAvatars = avatarServices.getAvatar(getAvatarReq);
    getAvatars
        .then((res) => {
              // todo pars result to Avatar.
            })
        .catchError((e) => {});
  }
}
