///
//  Generated code. Do not modify.
//  source: pub/v1/models/event.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'uid.pb.dart' as $5;

class Seen extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Seen', package: const $pb.PackageName('proto.pub.v1.models'), createEmptyInstance: create)
    ..aOM<$5.Uid>(1, 'from', subBuilder: $5.Uid.create)
    ..aOM<$5.Uid>(2, 'to', subBuilder: $5.Uid.create)
    ..aInt64(3, 'id')
    ..hasRequiredFields = false
  ;

  Seen._() : super();
  factory Seen() => create();
  factory Seen.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Seen.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Seen clone() => Seen()..mergeFromMessage(this);
  Seen copyWith(void Function(Seen) updates) => super.copyWith((message) => updates(message as Seen));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Seen create() => Seen._();
  Seen createEmptyInstance() => create();
  static $pb.PbList<Seen> createRepeated() => $pb.PbList<Seen>();
  @$core.pragma('dart2js:noInline')
  static Seen getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Seen>(create);
  static Seen _defaultInstance;

  @$pb.TagNumber(1)
  $5.Uid get from => $_getN(0);
  @$pb.TagNumber(1)
  set from($5.Uid v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasFrom() => $_has(0);
  @$pb.TagNumber(1)
  void clearFrom() => clearField(1);
  @$pb.TagNumber(1)
  $5.Uid ensureFrom() => $_ensure(0);

  @$pb.TagNumber(2)
  $5.Uid get to => $_getN(1);
  @$pb.TagNumber(2)
  set to($5.Uid v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTo() => $_has(1);
  @$pb.TagNumber(2)
  void clearTo() => clearField(2);
  @$pb.TagNumber(2)
  $5.Uid ensureTo() => $_ensure(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get id => $_getI64(2);
  @$pb.TagNumber(3)
  set id($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => clearField(3);
}

class SeenByClient extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SeenByClient', package: const $pb.PackageName('proto.pub.v1.models'), createEmptyInstance: create)
    ..aOM<$5.Uid>(2, 'to', subBuilder: $5.Uid.create)
    ..aInt64(3, 'id')
    ..hasRequiredFields = false
  ;

  SeenByClient._() : super();
  factory SeenByClient() => create();
  factory SeenByClient.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SeenByClient.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  SeenByClient clone() => SeenByClient()..mergeFromMessage(this);
  SeenByClient copyWith(void Function(SeenByClient) updates) => super.copyWith((message) => updates(message as SeenByClient));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SeenByClient create() => SeenByClient._();
  SeenByClient createEmptyInstance() => create();
  static $pb.PbList<SeenByClient> createRepeated() => $pb.PbList<SeenByClient>();
  @$core.pragma('dart2js:noInline')
  static SeenByClient getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SeenByClient>(create);
  static SeenByClient _defaultInstance;

  @$pb.TagNumber(2)
  $5.Uid get to => $_getN(0);
  @$pb.TagNumber(2)
  set to($5.Uid v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTo() => $_has(0);
  @$pb.TagNumber(2)
  void clearTo() => clearField(2);
  @$pb.TagNumber(2)
  $5.Uid ensureTo() => $_ensure(0);

  @$pb.TagNumber(3)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(3)
  set id($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(3)
  void clearId() => clearField(3);
}

class Activity extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Activity', package: const $pb.PackageName('proto.pub.v1.models'), createEmptyInstance: create)
    ..aOM<$5.Uid>(1, 'from', subBuilder: $5.Uid.create)
    ..aOM<$5.Uid>(2, 'to', subBuilder: $5.Uid.create)
    ..aOS(3, 'typeOfActivity')
    ..hasRequiredFields = false
  ;

  Activity._() : super();
  factory Activity() => create();
  factory Activity.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Activity.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Activity clone() => Activity()..mergeFromMessage(this);
  Activity copyWith(void Function(Activity) updates) => super.copyWith((message) => updates(message as Activity));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Activity create() => Activity._();
  Activity createEmptyInstance() => create();
  static $pb.PbList<Activity> createRepeated() => $pb.PbList<Activity>();
  @$core.pragma('dart2js:noInline')
  static Activity getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Activity>(create);
  static Activity _defaultInstance;

  @$pb.TagNumber(1)
  $5.Uid get from => $_getN(0);
  @$pb.TagNumber(1)
  set from($5.Uid v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasFrom() => $_has(0);
  @$pb.TagNumber(1)
  void clearFrom() => clearField(1);
  @$pb.TagNumber(1)
  $5.Uid ensureFrom() => $_ensure(0);

  @$pb.TagNumber(2)
  $5.Uid get to => $_getN(1);
  @$pb.TagNumber(2)
  set to($5.Uid v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTo() => $_has(1);
  @$pb.TagNumber(2)
  void clearTo() => clearField(2);
  @$pb.TagNumber(2)
  $5.Uid ensureTo() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get typeOfActivity => $_getSZ(2);
  @$pb.TagNumber(3)
  set typeOfActivity($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTypeOfActivity() => $_has(2);
  @$pb.TagNumber(3)
  void clearTypeOfActivity() => clearField(3);
}

class ActivityByClient extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ActivityByClient', package: const $pb.PackageName('proto.pub.v1.models'), createEmptyInstance: create)
    ..aOM<$5.Uid>(2, 'to', subBuilder: $5.Uid.create)
    ..aOS(3, 'typeOfActivity')
    ..hasRequiredFields = false
  ;

  ActivityByClient._() : super();
  factory ActivityByClient() => create();
  factory ActivityByClient.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ActivityByClient.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ActivityByClient clone() => ActivityByClient()..mergeFromMessage(this);
  ActivityByClient copyWith(void Function(ActivityByClient) updates) => super.copyWith((message) => updates(message as ActivityByClient));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ActivityByClient create() => ActivityByClient._();
  ActivityByClient createEmptyInstance() => create();
  static $pb.PbList<ActivityByClient> createRepeated() => $pb.PbList<ActivityByClient>();
  @$core.pragma('dart2js:noInline')
  static ActivityByClient getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActivityByClient>(create);
  static ActivityByClient _defaultInstance;

  @$pb.TagNumber(2)
  $5.Uid get to => $_getN(0);
  @$pb.TagNumber(2)
  set to($5.Uid v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTo() => $_has(0);
  @$pb.TagNumber(2)
  void clearTo() => clearField(2);
  @$pb.TagNumber(2)
  $5.Uid ensureTo() => $_ensure(0);

  @$pb.TagNumber(3)
  $core.String get typeOfActivity => $_getSZ(1);
  @$pb.TagNumber(3)
  set typeOfActivity($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(3)
  $core.bool hasTypeOfActivity() => $_has(1);
  @$pb.TagNumber(3)
  void clearTypeOfActivity() => clearField(3);
}

class PollStatusChanged extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PollStatusChanged', package: const $pb.PackageName('proto.pub.v1.models'), createEmptyInstance: create)
    ..aOS(1, 'uuid')
    ..hasRequiredFields = false
  ;

  PollStatusChanged._() : super();
  factory PollStatusChanged() => create();
  factory PollStatusChanged.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PollStatusChanged.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  PollStatusChanged clone() => PollStatusChanged()..mergeFromMessage(this);
  PollStatusChanged copyWith(void Function(PollStatusChanged) updates) => super.copyWith((message) => updates(message as PollStatusChanged));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PollStatusChanged create() => PollStatusChanged._();
  PollStatusChanged createEmptyInstance() => create();
  static $pb.PbList<PollStatusChanged> createRepeated() => $pb.PbList<PollStatusChanged>();
  @$core.pragma('dart2js:noInline')
  static PollStatusChanged getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PollStatusChanged>(create);
  static PollStatusChanged _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uuid => $_getSZ(0);
  @$pb.TagNumber(1)
  set uuid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUuid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUuid() => clearField(1);
}

class LiveLocationStatusChanged extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('LiveLocationStatusChanged', package: const $pb.PackageName('proto.pub.v1.models'), createEmptyInstance: create)
    ..aOS(1, 'uuid')
    ..hasRequiredFields = false
  ;

  LiveLocationStatusChanged._() : super();
  factory LiveLocationStatusChanged() => create();
  factory LiveLocationStatusChanged.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LiveLocationStatusChanged.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  LiveLocationStatusChanged clone() => LiveLocationStatusChanged()..mergeFromMessage(this);
  LiveLocationStatusChanged copyWith(void Function(LiveLocationStatusChanged) updates) => super.copyWith((message) => updates(message as LiveLocationStatusChanged));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static LiveLocationStatusChanged create() => LiveLocationStatusChanged._();
  LiveLocationStatusChanged createEmptyInstance() => create();
  static $pb.PbList<LiveLocationStatusChanged> createRepeated() => $pb.PbList<LiveLocationStatusChanged>();
  @$core.pragma('dart2js:noInline')
  static LiveLocationStatusChanged getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LiveLocationStatusChanged>(create);
  static LiveLocationStatusChanged _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uuid => $_getSZ(0);
  @$pb.TagNumber(1)
  set uuid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUuid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUuid() => clearField(1);
}

