// ignore_for_file: file_names

import 'dart:core';

import 'package:deliver/repository/analytics_repo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/settings.dart';
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
  CoreServiceClient? _coreServiceClient;
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

  ChannelCredentials get channelCredentials => ChannelCredentials.secure(
        onBadCertificate: (c, d) => settings.useBadCertificateConnection.value,
      );

  String ipOrAddress(String address) {
    final ip = settings.hostSetByUser.value;

    if (ip.isEmpty) return address;
    return ip;
  }

  void initClientChannels() {
    final grpcClientInterceptors = [
      GetIt.I.get<DeliverClientInterceptor>(),
      GetIt.I.get<AnalyticsClientInterceptor>()
    ];
    _initQueryClientChannelServices(grpcClientInterceptors);
    _initBotClientChannelServices(grpcClientInterceptors);
    _initStickerClientChannelServices(grpcClientInterceptors);
    _initMucClientChannelServices(grpcClientInterceptors);
    _initCoreClientChannelServices(grpcClientInterceptors);
    _initProfileClintChannelServices(grpcClientInterceptors);
    _initAvatarChannelClientServices(grpcClientInterceptors);
    _initFirebaseClientChannelServices(grpcClientInterceptors);
    _initLiverLocationClientServices(grpcClientInterceptors);
  }

  void _initQueryClientChannelServices(
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final queryClientChannel = ClientChannel(
      ipOrAddress("query.$APPLICATION_DOMAIN"),
      options: ChannelOptions(
        credentials: channelCredentials,
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
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final botClientChannel = ClientChannel(
      ipOrAddress("ms-bot.$APPLICATION_DOMAIN"),
      options: ChannelOptions(
        credentials: channelCredentials,
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
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final stickerClientChannel = ClientChannel(
      ipOrAddress("ms-sticker.$APPLICATION_DOMAIN"),
      options: ChannelOptions(
        userAgent: "ms-sticker",
        credentials: channelCredentials,
        connectionTimeout: const Duration(seconds: 2),
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
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final mucServicesClientChannel = ClientChannel(
      ipOrAddress("query.$APPLICATION_DOMAIN"),
      options: ChannelOptions(
        credentials: channelCredentials,
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
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final coreServicesClientChannel = ClientChannel(
      ipOrAddress("core.$APPLICATION_DOMAIN"),
      options: ChannelOptions(
        credentials: channelCredentials,
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
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final profileServicesClientChannel = ClientChannel(
      ipOrAddress("ms-profile.$APPLICATION_DOMAIN"),
      options: ChannelOptions(
        credentials: channelCredentials,
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
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    // ignore: non_constant_identifier_names
    final avatarServicesClientChannel = ClientChannel(
      ipOrAddress("ms-avatar.$APPLICATION_DOMAIN"),
      options: ChannelOptions(
        credentials: channelCredentials,
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
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final firebaseServicesClientChannel = ClientChannel(
      ipOrAddress("ms-firebase.$APPLICATION_DOMAIN"),
      options: ChannelOptions(
        credentials: channelCredentials,
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
    List<ClientInterceptor> grpcClientInterceptors,
  ) {
    final liveLocationServiceClientChannel = ClientChannel(
      ipOrAddress("ms-livelocation.$APPLICATION_DOMAIN"),
      options: ChannelOptions(
        credentials: channelCredentials,
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

  CallOptions _getCallOption(String address) =>
      CallOptions(metadata: {"service": address});

  CoreServiceClient? get coreServiceClient {
    if (_coreServiceClient == null) initClientChannels();
    return _coreServiceClient;
  }

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
