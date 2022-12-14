import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

String buildMucInviteLink(Uid roomUid, String token) =>
    "https://$APPLICATION_DOMAIN/join/${roomUid.category}/${roomUid.node}/$token";
