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
import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart' as bot;
import 'package:deliver_public_protocol/pub/v1/broadcast.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/group.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/lb.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/live_location.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/service_discovery.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_connection_interface.dart';

class ServicesDiscoveryRepo {
  String GWP = "https://gwp-";
  String _fileServiceBaseUrl = "https://ms-file.$APPLICATION_DOMAIN";

  CoreServiceClient? _coreServiceClient;
  ServiceDiscoveryClient? _serviceDiscoveryClient;
  bot.BotServiceClient? _botServiceClient;
  SessionServiceClient? _sessionServiceClient;
  QueryServiceClient? _queryServiceClient;
  ContactServiceClient? _contactServiceClient;
  StickerServiceClient? _stickerServiceClient;
  FirebaseServiceClient? _firebaseServiceClient;
  AvatarServiceClient? _avatarServiceClient;
  GroupServiceClient? _groupServiceClient;
  BroadcastServiceClient? _broadcastServiceClient;
  ChannelServiceClient? _channelServiceClient;
  LiveLocationServiceClient? _liveLocationServiceClient;
  UserServiceClient? _userServiceClient;
  AuthServiceClient? _authServiceClient;

  ChannelCredentials get channelCredentials =>
      ChannelCredentials.secure(
        onBadCertificate: (c, d) => settings.useBadCertificateConnection.value,
      );

  String ipOrAddress(String address) {
    final ip = settings.hostSetByUser.value;

    if (ip.isEmpty) {
      return address;
    }
    return ip;
  }

  void initClientChannels({GetInfoRes? getInfoRes}) {
    if (getInfoRes != null &&
        getInfoRes.msFile.bareAddresses.firstOrNull != null) {
      _fileServiceBaseUrl = "https://${getInfoRes.msFile.bareAddresses.first}";
    }
    final grpcClientInterceptors = [
      GetIt.I.get<DeliverClientInterceptor>(),
      GetIt.I.get<AnalyticsClientInterceptor>()
    ];
    _initQueryClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.query,
    );
    _initServiceDiscoveryChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
    );

    _initBotClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.msBot,
    );
    _initStickerClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.msSticker,
    );
    _initGroupClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.query,
    );
    _initBroadcastClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.query,
    );
    _initChannelClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.query,
    );
    _initCoreClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.core,
    );
    _initUserServiceClintChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.msProfile,
    );
    _initContactServiceClintChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.msProfile,
    );
    _initAuthServiceClintChannelServices(
      serviceConfig: getInfoRes?.msProfile,
    );
    _initSessionServiceClintChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.msProfile,
    );
    _initAvatarChannelClientServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.msAvatar,
    );
    _initFirebaseClientChannelServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.msFirebase,
    );
    _initLiverLocationClientServices(
      grpcClientInterceptors: grpcClientInterceptors,
      serviceConfig: getInfoRes?.msLivelocation,
    );
  }

  QueryServiceClient _initQueryClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    ClientChannelBase clientChannel;
    var address = serviceConfig?.bareAddresses.firstOrNull;
    if (isWeb) {
      address = '$GWP${address ?? "query.$APPLICATION_DOMAIN"}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(
          address ?? "query.$APPLICATION_DOMAIN",
        ),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _queryServiceClient = QueryServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("query"),
      ),
    );

    return _queryServiceClient!;
  }

  ServiceDiscoveryClient _initServiceDiscoveryChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;
    if (isWeb) {
      address = '$GWP${address ?? "ms-sd.$APPLICATION_DOMAIN"}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "ms-sd.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _serviceDiscoveryClient = ServiceDiscoveryClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("ms-sd"),
      ),
    );

    return _serviceDiscoveryClient!;
  }

  bot.BotServiceClient _initBotClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;
    if (isWeb) {
      address = '$GWP${address ?? "ms-bot.$APPLICATION_DOMAIN"}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "ms-bot.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _botServiceClient = bot.BotServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("ms-bot"),
      ),
    );

    return _botServiceClient!;
  }

  StickerServiceClient _initStickerClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;

    if (isWeb) {
      address = '$GWP${address ?? "ms-sticker.$APPLICATION_DOMAIN"}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "ms-sticker.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          userAgent: "ms-sticker",
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _stickerServiceClient = StickerServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("ms-sticker"),
      ),
    );

    return _stickerServiceClient!;
  }

  GroupServiceClient _initGroupClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;
    if (isWeb) {
      address = '$GWP${address ?? 'query.$APPLICATION_DOMAIN'}';

      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "query.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _groupServiceClient = GroupServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("query"),
      ),
    );

    return _groupServiceClient!;
  }

  BroadcastServiceClient _initBroadcastClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;
    if (isWeb) {
      address = '$GWP${address ?? 'query.$APPLICATION_DOMAIN'}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "query.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _broadcastServiceClient = BroadcastServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("query"),
      ),
    );

    return _broadcastServiceClient!;
  }

  ChannelServiceClient _initChannelClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;
    if (isWeb) {
      address = '$GWP${address ?? 'query.$APPLICATION_DOMAIN'}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "query.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _channelServiceClient = ChannelServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("query"),
      ),
    );

    return _channelServiceClient!;
  }

  CoreServiceClient _initCoreClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;
    if (isWeb) {
      address = '$GWP${address ?? 'core.$APPLICATION_DOMAIN'}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "core.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _coreServiceClient = CoreServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("core"),
      ),
    );

    return _coreServiceClient!;
  }

  UserServiceClient _initUserServiceClintChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;

    if (isWeb) {
      address = '$GWP${address ?? 'ms-profile.$APPLICATION_DOMAIN'}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "ms-profile.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _userServiceClient = UserServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("ms-profile"),
      ),
    );

    return _userServiceClient!;
  }

  ContactServiceClient _initContactServiceClintChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;

    if (isWeb) {
      address = '$GWP${address ?? 'ms-profile.$APPLICATION_DOMAIN'}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "ms-profile.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _contactServiceClient = ContactServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("ms-profile"),
      ),
    );

    return _contactServiceClient!;
  }

  AuthServiceClient _initAuthServiceClintChannelServices({
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;

    if (isWeb) {
      address = '$GWP${address ?? 'ms-profile.$APPLICATION_DOMAIN'}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "ms-profile.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _authServiceClient = AuthServiceClient(
      clientChannel,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("ms-profile"),
      ),
    );

    return _authServiceClient!;
  }

  SessionServiceClient _initSessionServiceClintChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;
    if (isWeb) {
      address = '$GWP${address ?? 'ms-profile.$APPLICATION_DOMAIN'}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "ms-profile.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _sessionServiceClient = SessionServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("ms-profile"),
      ),
    );

    return _sessionServiceClient!;
  }

  AvatarServiceClient _initAvatarChannelClientServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;

    if (isWeb) {
      address = '$GWP${address ?? 'ms-avatar.$APPLICATION_DOMAIN'}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "ms-avatar.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _avatarServiceClient = AvatarServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("ms-avatar"),
      ),
    );

    return _avatarServiceClient!;
  }

  FirebaseServiceClient _initFirebaseClientChannelServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;

    if (isWeb) {
      address = '$GWP${address ?? 'ms-firebase.$APPLICATION_DOMAIN'}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "ms-firebase.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _firebaseServiceClient = FirebaseServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("ms-firebase"),
      ),
    );

    return _firebaseServiceClient!;
  }

  LiveLocationServiceClient _initLiverLocationClientServices({
    List<ClientInterceptor>? grpcClientInterceptors,
    ServiceConfig? serviceConfig,
  }) {
    var address = serviceConfig?.bareAddresses.firstOrNull;
    ClientChannelBase clientChannel;
    if (isWeb) {
      address = '$GWP${address ?? 'ms-livelocation.$APPLICATION_DOMAIN'}';
      clientChannel = GrpcWebClientChannel.xhr(
        Uri.parse(address),
      );
    } else {
      clientChannel = ClientChannel(
        ipOrAddress(address ?? "ms-livelocation.$APPLICATION_DOMAIN"),
        options: ChannelOptions(
          credentials: channelCredentials,
          connectionTimeout: const Duration(seconds: 2),
        ),
      );
    }

    _liveLocationServiceClient = LiveLocationServiceClient(
      clientChannel,
      interceptors: grpcClientInterceptors,
      options: _getCallOption(
        (serviceConfig?.extraHeaders) ?? _getDefaultHeader("ms-livelocation"),
      ),
    );

    return _liveLocationServiceClient!;
  }

  CallOptions _getCallOption(Map<String, String> headers) =>
      CallOptions(metadata: headers);

  CoreServiceClient get coreServiceClient =>
      _coreServiceClient ?? _initCoreClientChannelServices();

  bot.BotServiceClient get botServiceClient =>
      _botServiceClient ?? _initBotClientChannelServices();

  SessionServiceClient get sessionServiceClient =>
      _sessionServiceClient ?? _initSessionServiceClintChannelServices();

  QueryServiceClient get queryServiceClient =>
      _queryServiceClient ?? _initQueryClientChannelServices();

  ServiceDiscoveryClient get serviceDiscoveryServiceClient =>
      _serviceDiscoveryClient ?? _initServiceDiscoveryChannelServices();

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

  BroadcastServiceClient get broadcastServiceClient =>
      _broadcastServiceClient ?? _initBroadcastClientChannelServices();

  String get fileServiceBaseUrl => _fileServiceBaseUrl;

  LBClient get lbcClient =>
      LBClient(
        isWeb
            ? GrpcWebClientChannel.xhr(
          Uri.parse('https://gwp-$LB_ADDRESS'),
        )
            : ClientChannel(
          ipOrAddress(LB_ADDRESS),
          options: ChannelOptions(
            credentials: channelCredentials,
            connectionTimeout: const Duration(seconds: 10),
          ),
        ),
      );

  Map<String, String> _getDefaultHeader(String value) => {"service": value};
}
