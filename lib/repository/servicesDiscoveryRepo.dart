// ignore_for_file: file_names

import 'dart:core';

import 'package:deliver/box/dao/shared_dao.dart';
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
  late CoreServiceClient _coreServiceClient;
  late BotServiceClient _botServiceClient;
  late SessionServiceClient _sessionServiceClient;
  late QueryServiceClient _queryServiceClient;
  late ContactServiceClient _contactServiceClient;
  late StickerServiceClient _stickerServiceClient;
  late FirebaseServiceClient _firebaseServiceClient;
  late AvatarServiceClient _avatarServiceClient;
  late GroupServiceClient _groupServiceClient;
  late ChannelServiceClient _channelServiceClient;
  late LiveLocationServiceClient _liveLocationServiceClient;
  late UserServiceClient _userServiceClient;
  late AuthServiceClient _authServiceClient;

  final fileServiceBaseUrl = "https://ms-file.$APPLICATION_DOMAIN";

  bool _badCertificateConnection = true;

  bool isInitialize = false;

  final _shareDao = GetIt.I.get<SharedDao>();

  Future<void> initRepo() async {
    if(!isInitialize) {
      final ip = (await _shareDao.get(SHARE_DAO_HOST_SET_BY_USER)) ?? "";
      initClientChannel(ip: ip);
      isInitialize = true;
    }
  }

  void initClientChannel({String ip = ""}) {
    final grpcClientInterceptors = [
      GetIt.I.get<DeliverClientInterceptor>(),
      GetIt.I.get<AnalyticsClientInterceptor>()
    ];
    _initQueryClientChannelServices(ip, grpcClientInterceptors);
    _initBotClientChannelServices(ip, grpcClientInterceptors);
    _initStickerClientChannelServices(ip, grpcClientInterceptors);
    _initMucClientChannelServices(ip, grpcClientInterceptors);
    _initCoreClientChannelServices(ip, grpcClientInterceptors);
    _initProfileClintChannelServices(ip, grpcClientInterceptors);
    _initAvatarChannelClientServices(ip, grpcClientInterceptors);
    _initFirebaseClientChannelServices(ip, grpcClientInterceptors);
    _initLiverLocationClientServices(ip, grpcClientInterceptors);
  }
  void _initQueryClientChannelServices(
    String ip,
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final queryClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "query.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    final webQueryClientChannel = GrpcWebClientChannel.xhr(
      Uri.parse('https://gwp-query.$APPLICATION_DOMAIN'),
    );
    _queryServiceClient = QueryServiceClient(
      isWeb ? webQueryClientChannel : queryClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("query"),
    );
  }

  void _initBotClientChannelServices(
    String ip,
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final botClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "ms-bot.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );
    final webBotClientChannel = GrpcWebClientChannel.xhr(
      Uri(scheme: "https", host: "gwp-ms-bot.$APPLICATION_DOMAIN"),
    );

    _botServiceClient = BotServiceClient(
      isWeb ? webBotClientChannel : botClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("ms-bot"),
    );
  }

  void _initStickerClientChannelServices(
    String ip,
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final stickerClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "ms-sticker.$APPLICATION_DOMAIN",
      options: const ChannelOptions(
        userAgent: "ms-sticker",
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 2),
      ),
    );

    final webStickerClientChannel = GrpcWebClientChannel.xhr(
      Uri(scheme: "https", host: "gwp-ms-sticker-co.ir"),
    );

    _stickerServiceClient = StickerServiceClient(
      isWeb ? webStickerClientChannel : stickerClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("ms-sticker"),
    );
  }

  void _initMucClientChannelServices(
    String ip,
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final mucServicesClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "query.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    final webMucServicesClientChannel = GrpcWebClientChannel.xhr(
      Uri.parse('https://gwp-query.$APPLICATION_DOMAIN'),
    );

    _groupServiceClient = GroupServiceClient(
      isWeb ? webMucServicesClientChannel : mucServicesClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("query"),
    );

    _channelServiceClient = ChannelServiceClient(
      isWeb ? webMucServicesClientChannel : mucServicesClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("query"),
    );
  }

  void _initCoreClientChannelServices(
    String ip,
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final coreServicesClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "core.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    final webCoreServicesClientChannel = GrpcWebClientChannel.xhr(
      Uri.parse("https://gwp-core.$APPLICATION_DOMAIN"),
    );

    _coreServiceClient = CoreServiceClient(
      isWeb ? webCoreServicesClientChannel : coreServicesClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("core"),
    );
  }

  void _initProfileClintChannelServices(
    String ip,
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final profileServicesClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "ms-profile.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    final webProfileServicesClientChannel = GrpcWebClientChannel.xhr(
      Uri.parse('https://gwp-ms-profile.$APPLICATION_DOMAIN'),
    );

    _userServiceClient = UserServiceClient(
      isWeb ? webProfileServicesClientChannel : profileServicesClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("ms-profile"),
    );
    _contactServiceClient = ContactServiceClient(
      isWeb ? webProfileServicesClientChannel : profileServicesClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("ms-profile"),
    );
    _authServiceClient = AuthServiceClient(
      isWeb ? webProfileServicesClientChannel : profileServicesClientChannel,
      options: _getCallOption("ms-profile"),
    );

    _sessionServiceClient = SessionServiceClient(
      isWeb ? webProfileServicesClientChannel : profileServicesClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("ms-profile"),
    );
  }

  void _initAvatarChannelClientServices(
    String ip,
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    // ignore: non_constant_identifier_names
    final avatarServicesClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "ms-avatar.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    final webAvatarServicesClientChannel = GrpcWebClientChannel.xhr(
      Uri.parse("https://gwp-ms-avatar.$APPLICATION_DOMAIN"),
    );

    _avatarServiceClient = AvatarServiceClient(
      isWeb ? webAvatarServicesClientChannel : avatarServicesClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("ms-avatar"),
    );
  }

  void _initFirebaseClientChannelServices(
    String ip,
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final firebaseServicesClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "ms-firebase.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    final webFirebaseServicesClientChannel = GrpcWebClientChannel.xhr(
      Uri(scheme: "https", host: "gwp-ms-firebase.$APPLICATION_DOMAIN"),
    );

    _firebaseServiceClient = FirebaseServiceClient(
      isWeb ? webFirebaseServicesClientChannel : firebaseServicesClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("ms-firebase"),
    );
  }

  void _initLiverLocationClientServices(
    String ip,
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final liveLocationServiceClientChannel = ClientChannel(
      ip.isNotEmpty ? ip : "ms-livelocation.$APPLICATION_DOMAIN",
      options: ChannelOptions(
        credentials: ChannelCredentials.secure(
          onBadCertificate: (c, d) => badCertificateConnection,
        ),
        connectionTimeout: const Duration(seconds: 2),
      ),
    );

    final webLiveLocationClientChannel = GrpcWebClientChannel.xhr(
      Uri(scheme: "https", host: "gwp-ms-livelocation.$APPLICATION_DOMAIN"),
    );

    _liveLocationServiceClient = LiveLocationServiceClient(
      isWeb ? webLiveLocationClientChannel : liveLocationServiceClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("ms-livelocation"),
    );
  }

  Future<void> initCertificate() async {
    _badCertificateConnection = (await (GetIt.I.get<SharedDao>().getBoolean(
          SHARED_DAO_BAD_CERTIFICATE_CONNECTION,
          defaultValue: true,
        )));
  }

  void setCertificate({required bool onBadCertificate}) {
    (GetIt.I
        .get<SharedDao>()
        .putBoolean(SHARED_DAO_BAD_CERTIFICATE_CONNECTION, onBadCertificate));
    _badCertificateConnection = onBadCertificate;
  }

  CallOptions _getCallOption(String address) =>
      CallOptions(metadata: {"service": address});

  bool get badCertificateConnection => _badCertificateConnection;

  CoreServiceClient get coreServiceClient => _coreServiceClient;

  BotServiceClient get botServiceClient => _botServiceClient;

  SessionServiceClient get sessionServiceClient => _sessionServiceClient;

  QueryServiceClient get queryServiceClient => _queryServiceClient;

  ContactServiceClient get contactServiceClient => _contactServiceClient;

  StickerServiceClient get stickerServiceClient => _stickerServiceClient;

  FirebaseServiceClient get firebaseServiceClient => _firebaseServiceClient;

  AvatarServiceClient get avatarServiceClient => _avatarServiceClient;

  GroupServiceClient get groupServiceClient => _groupServiceClient;

  ChannelServiceClient get channelServiceClient => _channelServiceClient;

  LiveLocationServiceClient get liveLocationServiceClient =>
      _liveLocationServiceClient;

  UserServiceClient get userServiceClient => _userServiceClient;

  AuthServiceClient get authServiceClient => _authServiceClient;
}
