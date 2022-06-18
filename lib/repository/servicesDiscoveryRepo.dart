// ignore_for_file: file_names

import 'dart:core';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/main.dart';
import 'package:deliver/repository/analytics_repo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/web_classes/grpc_web.dart'
    if (dart.library.html) 'package:grpc/grpc_web.dart';
import 'package:deliver_public_protocol/pub/v1/avatar.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/group.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/live_location.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class ServicesDiscoveryRepo {
  late ClientChannel _botClientChannel;
  late ClientChannel _queryClientChannel;
  late ClientChannel stickerClientChannel;
  late ClientChannel mucServicesClientChannel;
  late ClientChannel coreServicesClientChannel;
  late ClientChannel avatarServicesClientChannel;
  late ClientChannel profileServicesClientChannel;
  late ClientChannel firebaseServicesClientChannel;
  late ClientChannel liveLocationServiceClientChannel;

  late GrpcWebClientChannel webStickerClientChannel;
  late GrpcWebClientChannel webProfileServicesClientChannel;
  late GrpcWebClientChannel webBotClientChannel;
  late GrpcWebClientChannel webCoreServicesClientChannel;
  late GrpcWebClientChannel webMucServicesClientChannel;
  late GrpcWebClientChannel webFirebaseServicesClientChannel;
  late GrpcWebClientChannel webLiveLocationClientChannel;
  late GrpcWebClientChannel webQueryClientChannel;
  late GrpcWebClientChannel webAvatarServicesClientChannel;

  final fileServiceBaseUrl = "https://ms-file.$APPLICATION_DOMAIN";

  bool badCertificateConnection = true;

  final _shareDao = GetIt.I.get<SharedDao>();

  void initAuthRepo() {
    try{
      registerSingleton<AuthServiceClient>(
        AuthServiceClient(
          isWeb ? webProfileServicesClientChannel : profileServicesClientChannel,
        ),
      );
    }catch(e){
      print(e.toString());
    }
    // Order is important, don't change it!

  }

  ServicesDiscoveryRepo() {
    _initRepo();
  }

  Future<void> _initRepo() async {
    final ip = (await _shareDao.get(SHARE_DAO_HOST_SET_BY_USER)) ?? "";
    initClientChannel(ip: ip);
  }

  void initClientChannel({String ip = ""}) {
    _queryClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "query.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        userAgent: "query",
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    webQueryClientChannel = GrpcWebClientChannel.xhr(
      Uri.parse('https://gwp-query.$APPLICATION_DOMAIN'),
    );

// ignore: non_constant_identifier_names
    _botClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "ms-bot.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        userAgent: "ms-bot",
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );
    webBotClientChannel = GrpcWebClientChannel.xhr(
      Uri(scheme: "https", host: "gwp-ms-bot.$APPLICATION_DOMAIN"),
    );

// ignore: non_constant_identifier_names
    stickerClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "ms-sticker.$APPLICATION_DOMAIN",
      options: const ChannelOptions(
        userAgent: "ms-sticker",
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2),
      ),
    );

    webStickerClientChannel = GrpcWebClientChannel.xhr(
      Uri(scheme: "https", host: "gwp-ms-sticker-co.ir"),
    );

// ignore: non_constant_identifier_names
    mucServicesClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "query.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        userAgent: "query",
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    webMucServicesClientChannel = GrpcWebClientChannel.xhr(
      Uri.parse('https://gwp-query.$APPLICATION_DOMAIN'),
    );

// ignore: non_constant_identifier_names
    coreServicesClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "core.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        userAgent: "core",
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    webCoreServicesClientChannel = GrpcWebClientChannel.xhr(
      Uri.parse("https://gwp-core.$APPLICATION_DOMAIN"),
    );

// ignore: non_constant_identifier_names
    profileServicesClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "ms-profile.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        userAgent: "ms-profile",
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    webProfileServicesClientChannel = GrpcWebClientChannel.xhr(
      Uri.parse('https://gwp-ms-profile.$APPLICATION_DOMAIN'),
    );

// ignore: non_constant_identifier_names
    avatarServicesClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "ms-avatar.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        userAgent: "ms-avatar",
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    webAvatarServicesClientChannel = GrpcWebClientChannel.xhr(
      Uri.parse("https://gwp-ms-avatar.$APPLICATION_DOMAIN"),
    );

// ignore: non_constant_identifier_names
    firebaseServicesClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "ms-firebase.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        userAgent: "ms-firebase",
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    webFirebaseServicesClientChannel = GrpcWebClientChannel.xhr(
      Uri(scheme: "https", host: "gwp-ms-firebase.$APPLICATION_DOMAIN"),
    );

    webLiveLocationClientChannel = GrpcWebClientChannel.xhr(
      Uri(scheme: "https", host: "gwp-ms-livelocation.$APPLICATION_DOMAIN"),
    );

// ignore: non_constant_identifier_names
    liveLocationServiceClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "ms-livelocation.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        userAgent: "ms-livelocation",
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> initCertificate() async {
    badCertificateConnection = (await (GetIt.I.get<SharedDao>().getBoolean(
          SHARED_DAO_BAD_CERTIFICATE_CONNECTION,
          defaultValue: true,
        )));
  }

  void setCertificate({required bool onBadCertificate}) {
    (GetIt.I
        .get<SharedDao>()
        .putBoolean(SHARED_DAO_BAD_CERTIFICATE_CONNECTION, onBadCertificate));
    badCertificateConnection = onBadCertificate;
  }

  void registerClientChannel() {
    final grpcClientInterceptors = [
      GetIt.I.get<DeliverClientInterceptor>(),
      GetIt.I.get<AnalyticsClientInterceptor>()
    ];
    registerSingleton<UserServiceClient>(
      UserServiceClient(
        isWeb ? webProfileServicesClientChannel : profileServicesClientChannel,
        interceptors: grpcClientInterceptors,
      ),
    );
    registerSingleton<ContactServiceClient>(
      ContactServiceClient(
        isWeb ? webProfileServicesClientChannel : profileServicesClientChannel,
        interceptors: grpcClientInterceptors,
      ),
    );

    registerSingleton<QueryServiceClient>(
      QueryServiceClient(
        isWeb ? webQueryClientChannel : _queryClientChannel,
        interceptors: grpcClientInterceptors,
      ),
    );
    registerSingleton<CoreServiceClient>(
      CoreServiceClient(
        isWeb ? webCoreServicesClientChannel : coreServicesClientChannel,
        interceptors: grpcClientInterceptors,
      ),
    );

    registerSingleton<BotServiceClient>(
      BotServiceClient(
        isWeb ? webBotClientChannel : _botClientChannel,
        interceptors: grpcClientInterceptors,
      ),
    );
    registerSingleton<StickerServiceClient>(
      StickerServiceClient(
        isWeb ? webStickerClientChannel : stickerClientChannel,
        interceptors: grpcClientInterceptors,
      ),
    );
    registerSingleton<GroupServiceClient>(
      GroupServiceClient(
        isWeb ? webMucServicesClientChannel : mucServicesClientChannel,
        interceptors: grpcClientInterceptors,
      ),
    );
    registerSingleton<ChannelServiceClient>(
      ChannelServiceClient(
        isWeb ? webMucServicesClientChannel : mucServicesClientChannel,
        interceptors: grpcClientInterceptors,
      ),
    );
    registerSingleton<AvatarServiceClient>(
      AvatarServiceClient(
        isWeb ? webAvatarServicesClientChannel : avatarServicesClientChannel,
        interceptors: grpcClientInterceptors,
      ),
    );
    registerSingleton<FirebaseServiceClient>(
      FirebaseServiceClient(
        isWeb
            ? webFirebaseServicesClientChannel
            : firebaseServicesClientChannel,
        interceptors: grpcClientInterceptors,
      ),
    );

    registerSingleton<SessionServiceClient>(
      SessionServiceClient(
        isWeb ? webProfileServicesClientChannel : profileServicesClientChannel,
        interceptors: grpcClientInterceptors,
      ),
    );
    registerSingleton<LiveLocationServiceClient>(
      LiveLocationServiceClient(
        isWeb ? webLiveLocationClientChannel : liveLocationServiceClientChannel,
        interceptors: grpcClientInterceptors,
      ),
    );
  }

// ignore: non_constant_identifier_names

}
