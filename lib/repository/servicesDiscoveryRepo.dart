import 'package:grpc/grpc.dart';

// ignore: non_constant_identifier_names
final QueryClientChannel = ClientChannel("172.16.121.37",
    port: 8081,
    options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final MucServicesClientChannel = ClientChannel("172.16.121.37",
    port: 8081,
    options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2)));

// ignore: non_constant_identifier_names
final CoreServicesClientChannel = ClientChannel("172.16.121.37",
    port: 8080,
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