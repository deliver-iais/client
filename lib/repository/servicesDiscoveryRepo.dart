// ignore_for_file: file_names

import 'dart:core';

import 'package:deliver/shared/constants.dart';
import 'package:deliver/web_classes/grpc_web.dart'
    if (dart.library.html) 'package:grpc/grpc_web.dart';
import 'package:grpc/grpc.dart';

// ignore: non_constant_identifier_names
final QueryClientChannel = ClientChannel(
  "query.$APPLICATION_DOMAIN",
  options: ChannelOptions(
    credentials: ChannelCredentials.secure(onBadCertificate: (c, d) => true),
    connectionTimeout: const Duration(seconds: 2),
  ),
);

final webQueryClientChannel = GrpcWebClientChannel.xhr(
  Uri.parse('https://gwp-query.$APPLICATION_DOMAIN'),
);

// ignore: non_constant_identifier_names
final BotClientChannel = ClientChannel(
  "ms-bot.$APPLICATION_DOMAIN",
  options: ChannelOptions(
    credentials: ChannelCredentials.secure(onBadCertificate: (c, d) => true),
    connectionTimeout: const Duration(seconds: 2),
  ),
);
final webBotClientChannel = GrpcWebClientChannel.xhr(
  Uri(scheme: "https", host: "gwp-ms-bot.$APPLICATION_DOMAIN"),
);

// ignore: non_constant_identifier_names
final StickerClientChannel = ClientChannel(
  "ms-sticker.$APPLICATION_DOMAIN",
  port: 8081,
  options: const ChannelOptions(
    credentials: ChannelCredentials.insecure(),
    connectionTimeout: Duration(seconds: 2),
  ),
);

final webStickerClientChannel = GrpcWebClientChannel.xhr(
  Uri(scheme: "https", host: "gwp-ms-sticker-co.ir"),
);

// ignore: non_constant_identifier_names
final MucServicesClientChannel = ClientChannel(
  "query.$APPLICATION_DOMAIN",
  options: ChannelOptions(
    credentials: ChannelCredentials.secure(onBadCertificate: (c, d) => true),
    connectionTimeout: const Duration(seconds: 2),
  ),
);

final webMucServicesClientChannel = GrpcWebClientChannel.xhr(
  Uri.parse('https://gwp-query.$APPLICATION_DOMAIN'),
);

// ignore: non_constant_identifier_names
final CoreServicesClientChannel = ClientChannel(
  "core.$APPLICATION_DOMAIN",
  options: ChannelOptions(
    credentials: ChannelCredentials.secure(onBadCertificate: (c, d) => true),
    connectionTimeout: const Duration(seconds: 2),
  ),
);

final webCoreServicesClientChannel =
    GrpcWebClientChannel.xhr(Uri.parse("https://gwp-core.$APPLICATION_DOMAIN"));

// ignore: non_constant_identifier_names, constant_identifier_names
const FileServiceBaseUrl = "https://ms-file.$APPLICATION_DOMAIN";

// ignore: non_constant_identifier_names

// ignore: non_constant_identifier_names
final ProfileServicesClientChannel = ClientChannel(
  "ms-profile.$APPLICATION_DOMAIN",
  options: ChannelOptions(
    credentials: ChannelCredentials.secure(onBadCertificate: (c, d) => true),
    connectionTimeout: const Duration(seconds: 2),
  ),
);

final webProfileServicesClientChannel = GrpcWebClientChannel.xhr(
  Uri.parse('https://gwp-ms-profile.$APPLICATION_DOMAIN'),
);

// ignore: non_constant_identifier_names
final AvatarServicesClientChannel = ClientChannel(
  "ms-avatar.$APPLICATION_DOMAIN",
  options: ChannelOptions(
    credentials: ChannelCredentials.secure(onBadCertificate: (c, d) => true),
    connectionTimeout: const Duration(seconds: 2),
  ),
);

final webAvatarServicesClientChannel = GrpcWebClientChannel.xhr(
  Uri.parse("https://gwp-ms-avatar.$APPLICATION_DOMAIN"),
);

// ignore: non_constant_identifier_names
final FirebaseServicesClientChannel = ClientChannel(
  "ms-firebase.$APPLICATION_DOMAIN",
  options: ChannelOptions(
    credentials: ChannelCredentials.secure(onBadCertificate: (c, d) => true),
    connectionTimeout: const Duration(seconds: 2),
  ),
);

final webFirebaseServicesClientChannel = GrpcWebClientChannel.xhr(
  Uri(scheme: "https", host: "gwp-ms-firebase.$APPLICATION_DOMAIN"),
);

final webLiveLocationClientChannel = GrpcWebClientChannel.xhr(
  Uri(scheme: "https", host: "gwp-ms-livelocation.$APPLICATION_DOMAIN"),
);

// ignore: non_constant_identifier_names
final LiveLocationServiceClientChannel = ClientChannel(
  "ms-livelocation.$APPLICATION_DOMAIN",
  options: ChannelOptions(
    credentials: ChannelCredentials.secure(onBadCertificate: (c, d) => true),
    connectionTimeout: const Duration(seconds: 2),
  ),
);
