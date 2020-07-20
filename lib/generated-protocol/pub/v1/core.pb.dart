///
//  Generated code. Do not modify.
//  source: pub/v1/core.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'models/message.pb.dart' as $8;
import 'models/error.pb.dart' as $9;
import 'models/event.pb.dart' as $10;

enum ServerPacket_Type {
  message, 
  error, 
  seen, 
  activity, 
  pollStatusChanged, 
  liveLocationStatusChanged, 
  notSet
}

class ServerPacket extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, ServerPacket_Type> _ServerPacket_TypeByTag = {
    1 : ServerPacket_Type.message,
    2 : ServerPacket_Type.error,
    3 : ServerPacket_Type.seen,
    4 : ServerPacket_Type.activity,
    6 : ServerPacket_Type.pollStatusChanged,
    7 : ServerPacket_Type.liveLocationStatusChanged,
    0 : ServerPacket_Type.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ServerPacket', package: const $pb.PackageName('proto.pub.v1.core'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 6, 7])
    ..aOM<$8.Message>(1, 'message', subBuilder: $8.Message.create)
    ..aOM<$9.Error>(2, 'error', subBuilder: $9.Error.create)
    ..aOM<$10.Seen>(3, 'seen', subBuilder: $10.Seen.create)
    ..aOM<$10.Activity>(4, 'activity', subBuilder: $10.Activity.create)
    ..aOM<$10.PollStatusChanged>(6, 'pollStatusChanged', subBuilder: $10.PollStatusChanged.create)
    ..aOM<$10.LiveLocationStatusChanged>(7, 'liveLocationStatusChanged', subBuilder: $10.LiveLocationStatusChanged.create)
    ..hasRequiredFields = false
  ;

  ServerPacket._() : super();
  factory ServerPacket() => create();
  factory ServerPacket.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ServerPacket.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ServerPacket clone() => ServerPacket()..mergeFromMessage(this);
  ServerPacket copyWith(void Function(ServerPacket) updates) => super.copyWith((message) => updates(message as ServerPacket));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ServerPacket create() => ServerPacket._();
  ServerPacket createEmptyInstance() => create();
  static $pb.PbList<ServerPacket> createRepeated() => $pb.PbList<ServerPacket>();
  @$core.pragma('dart2js:noInline')
  static ServerPacket getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServerPacket>(create);
  static ServerPacket _defaultInstance;

  ServerPacket_Type whichType() => _ServerPacket_TypeByTag[$_whichOneof(0)];
  void clearType() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $8.Message get message => $_getN(0);
  @$pb.TagNumber(1)
  set message($8.Message v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);
  @$pb.TagNumber(1)
  $8.Message ensureMessage() => $_ensure(0);

  @$pb.TagNumber(2)
  $9.Error get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($9.Error v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => clearField(2);
  @$pb.TagNumber(2)
  $9.Error ensureError() => $_ensure(1);

  @$pb.TagNumber(3)
  $10.Seen get seen => $_getN(2);
  @$pb.TagNumber(3)
  set seen($10.Seen v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSeen() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeen() => clearField(3);
  @$pb.TagNumber(3)
  $10.Seen ensureSeen() => $_ensure(2);

  @$pb.TagNumber(4)
  $10.Activity get activity => $_getN(3);
  @$pb.TagNumber(4)
  set activity($10.Activity v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasActivity() => $_has(3);
  @$pb.TagNumber(4)
  void clearActivity() => clearField(4);
  @$pb.TagNumber(4)
  $10.Activity ensureActivity() => $_ensure(3);

  @$pb.TagNumber(6)
  $10.PollStatusChanged get pollStatusChanged => $_getN(4);
  @$pb.TagNumber(6)
  set pollStatusChanged($10.PollStatusChanged v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasPollStatusChanged() => $_has(4);
  @$pb.TagNumber(6)
  void clearPollStatusChanged() => clearField(6);
  @$pb.TagNumber(6)
  $10.PollStatusChanged ensurePollStatusChanged() => $_ensure(4);

  @$pb.TagNumber(7)
  $10.LiveLocationStatusChanged get liveLocationStatusChanged => $_getN(5);
  @$pb.TagNumber(7)
  set liveLocationStatusChanged($10.LiveLocationStatusChanged v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasLiveLocationStatusChanged() => $_has(5);
  @$pb.TagNumber(7)
  void clearLiveLocationStatusChanged() => clearField(7);
  @$pb.TagNumber(7)
  $10.LiveLocationStatusChanged ensureLiveLocationStatusChanged() => $_ensure(5);
}

enum ClientPacket_Type {
  message, 
  seen, 
  activity, 
  notSet
}

class ClientPacket extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, ClientPacket_Type> _ClientPacket_TypeByTag = {
    1 : ClientPacket_Type.message,
    2 : ClientPacket_Type.seen,
    3 : ClientPacket_Type.activity,
    0 : ClientPacket_Type.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ClientPacket', package: const $pb.PackageName('proto.pub.v1.core'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<$8.MessageByClient>(1, 'message', subBuilder: $8.MessageByClient.create)
    ..aOM<$10.SeenByClient>(2, 'seen', subBuilder: $10.SeenByClient.create)
    ..aOM<$10.ActivityByClient>(3, 'activity', subBuilder: $10.ActivityByClient.create)
    ..hasRequiredFields = false
  ;

  ClientPacket._() : super();
  factory ClientPacket() => create();
  factory ClientPacket.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientPacket.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ClientPacket clone() => ClientPacket()..mergeFromMessage(this);
  ClientPacket copyWith(void Function(ClientPacket) updates) => super.copyWith((message) => updates(message as ClientPacket));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ClientPacket create() => ClientPacket._();
  ClientPacket createEmptyInstance() => create();
  static $pb.PbList<ClientPacket> createRepeated() => $pb.PbList<ClientPacket>();
  @$core.pragma('dart2js:noInline')
  static ClientPacket getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientPacket>(create);
  static ClientPacket _defaultInstance;

  ClientPacket_Type whichType() => _ClientPacket_TypeByTag[$_whichOneof(0)];
  void clearType() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $8.MessageByClient get message => $_getN(0);
  @$pb.TagNumber(1)
  set message($8.MessageByClient v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);
  @$pb.TagNumber(1)
  $8.MessageByClient ensureMessage() => $_ensure(0);

  @$pb.TagNumber(2)
  $10.SeenByClient get seen => $_getN(1);
  @$pb.TagNumber(2)
  set seen($10.SeenByClient v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSeen() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeen() => clearField(2);
  @$pb.TagNumber(2)
  $10.SeenByClient ensureSeen() => $_ensure(1);

  @$pb.TagNumber(3)
  $10.ActivityByClient get activity => $_getN(2);
  @$pb.TagNumber(3)
  set activity($10.ActivityByClient v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasActivity() => $_has(2);
  @$pb.TagNumber(3)
  void clearActivity() => clearField(3);
  @$pb.TagNumber(3)
  $10.ActivityByClient ensureActivity() => $_ensure(2);
}

