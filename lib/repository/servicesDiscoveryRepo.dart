import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart';
import 'package:grpc/grpc.dart';

String IP = "89.37.13.110";

// ignore: non_constant_identifier_names
final QueryClientChannel = ClientChannel("89.37.13.110",
    port: 30101,
    options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2)));

final BotClientChannel = ClientChannel("89.37.13.110",
    port: 30040,
    options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2)));

final StickerClientChannel = ClientChannel("89.37.13.110",
    port: 8081,
    options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final MucServicesClientChannel = ClientChannel("89.37.13.110",
    port: 30101,
    options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final CoreServicesClientChannel = ClientChannel("89.37.13.110",
    port: 30100,
    options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final FileServiceBaseUrl = "http://89.37.13.110:30010/";

// ignore: non_constant_identifier_names
final ProfileServicesClientChannel = ClientChannel("89.37.13.110",
    port: 30000,
    options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final AvatarServicesClientChannel = ClientChannel("89.37.13.110",
    port: 30070,
    options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2)));
// ignore: non_constant_identifier_names
final FirebaseServicesClientChannel = ClientChannel("89.37.13.110",
    port: 30030,
    options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2)));
// import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart';
// import 'package:grpc/grpc.dart';
//
// // String IP = "89.37.13.110";
//
// // ignore: non_constant_identifier_names
// final QueryClientChannel = ClientChannel("query.deliver-co.ir",
//     port: 443,
//     options: ChannelOptions(
//         credentials: ChannelCredentials.secure(),
//         connectionTimeout: Duration(seconds: 2)));
//
// final BotClientChannel = ClientChannel("89.37.13.110",
//     port: 30040,
//     options: ChannelOptions(
//         credentials: ChannelCredentials.secure(),
//         connectionTimeout: Duration(seconds: 2)));
//
// final StickerClientChannel = ClientChannel("89.37.13.110",
//     port: 8081,
//     options: ChannelOptions(
//         credentials: ChannelCredentials.insecure(),
//         connectionTimeout: Duration(seconds: 2)));
//
// // ignore: non_constant_identifier_names
// final MucServicesClientChannel = ClientChannel("query.deliver-co.ir",
//     port: 443,
//     options: ChannelOptions(
//         credentials: ChannelCredentials.secure(),
//         connectionTimeout: Duration(seconds: 2)));
//
// // ignore: non_constant_identifier_names
// final CoreServicesClientChannel = ClientChannel("core.deliver-co.ir",
//     port: 443,
//     options: ChannelOptions(
//         credentials: ChannelCredentials.secure(),
//         connectionTimeout: Duration(seconds: 2)));
//
// // ignore: non_constant_identifier_names
// final FileServiceBaseUrl = "ms-file.deliver-co.ir:443/";
//
// // ignore: non_constant_identifier_names
// final ProfileServicesClientChannel = ClientChannel("ms-profile.deliver-co.ir",
//     port: 443,
//     options: ChannelOptions(
//         credentials: ChannelCredentials.secure(),
//         connectionTimeout: Duration(seconds: 2)));
//
// // ignore: non_constant_identifier_names
// final AvatarServicesClientChannel = ClientChannel("ms-avatar.deliver-co.ir",
//     port: 443,
//     options: ChannelOptions(
//         credentials: ChannelCredentials.secure(),
//         connectionTimeout: Duration(seconds: 2)));
//
// // ignore: non_constant_identifier_names
// final FirebaseServicesClientChannel = ClientChannel("ms-firabase.deliver-co.ir",
//     port: 443,
//     options: ChannelOptions(
//         credentials: ChannelCredentials.secure(),
//         connectionTimeout: Duration(seconds: 2)));
