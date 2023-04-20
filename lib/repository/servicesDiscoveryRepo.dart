// TODO(any): change file name
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
  BotServiceClient? _botServiceClient;
  SessionServiceClient? _sessionServiceClient;
  QueryServiceClient? _queryServiceClient;
  ContactServiceClient? _contactServiceClient;
  StickerServiceClient? _stickerServiceClient;
  FirebaseServiceClient? _firebaseServiceClient;
  AvatarServiceClient? _avatarServiceClient;
  GroupServiceClient? _groupServiceClient;
  ChannelServiceClient? _channelServiceClient;
  LiveLocationServiceClient? _liveLocationServiceClient;
  UserServiceClient? _userServiceClient;
  AuthServiceClient? _authServiceClient;

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
    _initQueryClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );
    _initBotClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );
    _initStickerClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );
    _initGroupClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );
    _initChannelClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );
    _initCoreClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );
    _initUserServiceClintChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );
    _initContactServiceClintChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );
    _initAuthServiceClintChannelServices();
    _initSessionServiceClintChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );
    _initAvatarChannelClientServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );
    _initFirebaseClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );
    _initLiverLocationClientServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );
  }

  QueryServiceClient _initQueryClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
  }) {
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

    return _queryServiceClient!;
  }

  BotServiceClient _initBotClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
  }) {
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

    return _botServiceClient!;
  }

  StickerServiceClient _initStickerClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
  }) {
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

    return _stickerServiceClient!;
  }

  GroupServiceClient _initGroupClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
  }) {
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

    return _groupServiceClient!;
  }

  ChannelServiceClient _initChannelClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
  }) {
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

    _channelServiceClient = ChannelServiceClient(
      isWeb ? webMucServicesClientChannel : mucServicesClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("query"),
    );

    return _channelServiceClient!;
  }

  CoreServiceClient _initCoreClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
  }) {
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

    return _coreServiceClient!;
  }

  UserServiceClient _initUserServiceClintChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
  }) {
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

    return _userServiceClient!;
  }

  ContactServiceClient _initContactServiceClintChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
  }) {
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

    _contactServiceClient = ContactServiceClient(
      isWeb ? webProfileServicesClientChannel : profileServicesClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("ms-profile"),
    );

    return _contactServiceClient!;
  }

  AuthServiceClient _initAuthServiceClintChannelServices() {
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

    _authServiceClient = AuthServiceClient(
      isWeb ? webProfileServicesClientChannel : profileServicesClientChannel,
      options: _getCallOption("ms-profile"),
    );

    return _authServiceClient!;
  }

  SessionServiceClient _initSessionServiceClintChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
  }) {
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

    _sessionServiceClient = SessionServiceClient(
      isWeb ? webProfileServicesClientChannel : profileServicesClientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption("ms-profile"),
    );

    return _sessionServiceClient!;
  }

  AvatarServiceClient _initAvatarChannelClientServices({
    List<ClientInterceptor>? grpcClientInterceptors,
  }) {
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

    return _avatarServiceClient!;
  }

  FirebaseServiceClient _initFirebaseClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
  }) {
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

    return _firebaseServiceClient!;
  }

  LiveLocationServiceClient _initLiverLocationClientServices({
    List<ClientInterceptor>? grpcClientInterceptors,
  }) {
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

    return _liveLocationServiceClient!;
  }

  CallOptions _getCallOption(String address) =>
      CallOptions(metadata: {"service": address});

  CoreServiceClient get coreServiceClient =>
      _coreServiceClient ?? _initCoreClientChannelServices();

  BotServiceClient get botServiceClient =>
      _botServiceClient ?? _initBotClientChannelServices();

  SessionServiceClient get sessionServiceClient =>
      _sessionServiceClient ?? _initSessionServiceClintChannelServices();

  QueryServiceClient get queryServiceClient =>
      _queryServiceClient ?? _initQueryClientChannelServices();

  ContactServiceClient get contactServiceClient =>
      _contactServiceClient ?? _initContactServiceClintChannelServices();

  StickerServiceClient get stickerServiceClient =>
      _stickerServiceClient ?? _initStickerClientChannelServices();

  FirebaseServiceClient get firebaseServiceClient =>
      _firebaseServiceClient ?? _initFirebaseClientChannelServices();

  AvatarServiceClient get avatarServiceClient =>
      _avatarServiceClient ?? _initAvatarChannelClientServices();

  GroupServiceClient get groupServiceClient =>
      _groupServiceClient ?? _initGroupClientChannelServices();

  ChannelServiceClient get channelServiceClient =>
      _channelServiceClient ?? _initChannelClientChannelServices();

  LiveLocationServiceClient get liveLocationServiceClient =>
      _liveLocationServiceClient ?? _initLiverLocationClientServices();

  UserServiceClient get userServiceClient =>
      _userServiceClient ?? _initUserServiceClintChannelServices();

  AuthServiceClient get authServiceClient =>
      _authServiceClient ?? _initAuthServiceClintChannelServices();
}
