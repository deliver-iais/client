import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_web.dart';

// ignore: non_constant_identifier_names
final QueryClientChannel = ClientChannel("query.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials: ChannelCredentials.secure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final BotClientChannel = ClientChannel("ms-bot.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials: ChannelCredentials.secure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final StickerClientChannel = ClientChannel("89.37.13.110",
    port: 8081,
    options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final MucServicesClientChannel = ClientChannel("query.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials: ChannelCredentials.secure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final CoreServicesClientChannel = ClientChannel("core.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials: ChannelCredentials.secure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final FileServiceBaseUrl = "https://ms-file.deliver-co.ir";

// ignore: non_constant_identifier_names
final ProfileServicesClientChannel = ClientChannel("ms-profile.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials: ChannelCredentials.secure(),
        connectionTimeout: Duration(seconds: 2)));

final webProfileServicesClientChannel = GrpcWebClientChannel.xhr(Uri.parse('gwp-ms-profile.deliver-co.ir'));

// ignore: non_constant_identifier_names
final AvatarServicesClientChannel = ClientChannel("ms-avatar.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials: ChannelCredentials.secure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final FirebaseServicesClientChannel = ClientChannel("ms-firebase.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials: ChannelCredentials.secure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final LiveLocationServiceClientChannel = ClientChannel("ms-livelocation.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials: ChannelCredentials.secure(),
        connectionTimeout: Duration(seconds: 2)));
