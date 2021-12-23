// ignore_for_file: file_names

import 'dart:core';

import 'package:grpc/grpc.dart';
import 'package:deliver/web_classes/grpc_web.dart'
    if (dart.library.html) 'package:grpc/grpc_web.dart';

// ignore: non_constant_identifier_names
final QueryClientChannel = ClientChannel("query.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials:
            ChannelCredentials.secure(onBadCertificate: (c, d) => true),
        connectionTimeout: const Duration(seconds: 2)));

final webQueryClientChannel =
    GrpcWebClientChannel.xhr(Uri.parse('https://gwp-query.deliver-co.ir'));

// ignore: non_constant_identifier_names
final BotClientChannel = ClientChannel("ms-bot.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials:
            ChannelCredentials.secure(onBadCertificate: (c, d) => true),
        connectionTimeout: const Duration(seconds: 2)));
final webBotClientChannel = GrpcWebClientChannel.xhr(
    Uri(scheme: "https", host: "gwp-ms-bot.deliver-co.ir"));

// ignore: non_constant_identifier_names
final StickerClientChannel = ClientChannel("ms-sticker.deliver-co.ir",
    port: 8081,
    options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2)));

final webStickerClientChannel = GrpcWebClientChannel.xhr(
    Uri(scheme: "https", host: "gwp-ms-sticker-co.ir"));

// ignore: non_constant_identifier_names
final MucServicesClientChannel = ClientChannel("query.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials:
            ChannelCredentials.secure(onBadCertificate: (c, d) => true),
        connectionTimeout: const Duration(seconds: 2)));

final webMucServicesClientChannel =
    GrpcWebClientChannel.xhr(Uri.parse('https://gwp-query.deliver-co.ir'));

// ignore: non_constant_identifier_names
final CoreServicesClientChannel = ClientChannel("core.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials:
            ChannelCredentials.secure(onBadCertificate: (c, d) => true),
        connectionTimeout: const Duration(seconds: 2)));

final webCoreServicesClientChannel =
    GrpcWebClientChannel.xhr(Uri.parse("https://gwp-core.deliver-co.ir"));

// ignore: non_constant_identifier_names, constant_identifier_names
const FileServiceBaseUrl = "https://ms-file.deliver-co.ir";

// ignore: non_constant_identifier_names

// ignore: non_constant_identifier_names
final ProfileServicesClientChannel = ClientChannel("ms-profile.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials:
            ChannelCredentials.secure(onBadCertificate: (c, d) => true),
        connectionTimeout: const Duration(seconds: 2)));

final webProfileServicesClientChannel =
    GrpcWebClientChannel.xhr(Uri.parse('https://gwp-ms-profile.deliver-co.ir'));

// ignore: non_constant_identifier_names
final AvatarServicesClientChannel = ClientChannel("ms-avatar.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials:
            ChannelCredentials.secure(onBadCertificate: (c, d) => true),
        connectionTimeout: const Duration(seconds: 2)));

final webAvatarServicesClientChannel =
    GrpcWebClientChannel.xhr(Uri.parse("https://gwp-ms-avatar.deliver-co.ir"));

// ignore: non_constant_identifier_names
final FirebaseServicesClientChannel = ClientChannel("ms-firebase.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials:
            ChannelCredentials.secure(onBadCertificate: (c, d) => true),
        connectionTimeout: const Duration(seconds: 2)));

final webFirebaseServicesClientChannel = GrpcWebClientChannel.xhr(
    Uri(scheme: "https", host: "gwp-ms-firebase.deliver-co.ir"));

final webLiveLocationClientChannel = GrpcWebClientChannel.xhr(
    Uri(scheme: "https", host: "gwp-ms-firebase.deliver-co.ir"));

// ignore: non_constant_identifier_names
final LiveLocationServiceClientChannel = ClientChannel(
    "ms-livelocation.deliver-co.ir",
    port: 443,
    options: ChannelOptions(
        credentials:
            ChannelCredentials.secure(onBadCertificate: (c, d) => true),
        connectionTimeout: const Duration(seconds: 2)));
