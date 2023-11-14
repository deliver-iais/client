// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  @UidJsonKey
  Uid get roomUid => throw _privateConstructorUsedError;
  @UidJsonKey
  Uid get from => throw _privateConstructorUsedError;
  @UidJsonKey
  Uid get to => throw _privateConstructorUsedError;
  String get packetId => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;
  String get json => throw _privateConstructorUsedError;
  int get replyToId => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  bool get edited => throw _privateConstructorUsedError;
  bool get encrypted => throw _privateConstructorUsedError;
  bool get isHidden => throw _privateConstructorUsedError;
  bool get isLocalMessage => throw _privateConstructorUsedError;
  String? get markup => throw _privateConstructorUsedError;
  int? get id => throw _privateConstructorUsedError;
  int? get localNetworkMessageId => throw _privateConstructorUsedError;
  @NullableUidJsonKey
  Uid? get forwardedFrom => throw _privateConstructorUsedError;
  @NullableUidJsonKey
  Uid? get generatedBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {@UidJsonKey Uid roomUid,
      @UidJsonKey Uid from,
      @UidJsonKey Uid to,
      String packetId,
      int time,
      String json,
      int replyToId,
      MessageType type,
      bool edited,
      bool encrypted,
      bool isHidden,
      bool isLocalMessage,
      String? markup,
      int? id,
      int? localNetworkMessageId,
      @NullableUidJsonKey Uid? forwardedFrom,
      @NullableUidJsonKey Uid? generatedBy});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomUid = null,
    Object? from = null,
    Object? to = null,
    Object? packetId = null,
    Object? time = null,
    Object? json = null,
    Object? replyToId = null,
    Object? type = null,
    Object? edited = null,
    Object? encrypted = null,
    Object? isHidden = null,
    Object? isLocalMessage = null,
    Object? markup = freezed,
    Object? id = freezed,
    Object? localNetworkMessageId = freezed,
    Object? forwardedFrom = freezed,
    Object? generatedBy = freezed,
  }) {
    return _then(_value.copyWith(
      roomUid: null == roomUid
          ? _value.roomUid
          : roomUid // ignore: cast_nullable_to_non_nullable
              as Uid,
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as Uid,
      to: null == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as Uid,
      packetId: null == packetId
          ? _value.packetId
          : packetId // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      json: null == json
          ? _value.json
          : json // ignore: cast_nullable_to_non_nullable
              as String,
      replyToId: null == replyToId
          ? _value.replyToId
          : replyToId // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      edited: null == edited
          ? _value.edited
          : edited // ignore: cast_nullable_to_non_nullable
              as bool,
      encrypted: null == encrypted
          ? _value.encrypted
          : encrypted // ignore: cast_nullable_to_non_nullable
              as bool,
      isHidden: null == isHidden
          ? _value.isHidden
          : isHidden // ignore: cast_nullable_to_non_nullable
              as bool,
      isLocalMessage: null == isLocalMessage
          ? _value.isLocalMessage
          : isLocalMessage // ignore: cast_nullable_to_non_nullable
              as bool,
      markup: freezed == markup
          ? _value.markup
          : markup // ignore: cast_nullable_to_non_nullable
              as String?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      localNetworkMessageId: freezed == localNetworkMessageId
          ? _value.localNetworkMessageId
          : localNetworkMessageId // ignore: cast_nullable_to_non_nullable
              as int?,
      forwardedFrom: freezed == forwardedFrom
          ? _value.forwardedFrom
          : forwardedFrom // ignore: cast_nullable_to_non_nullable
              as Uid?,
      generatedBy: freezed == generatedBy
          ? _value.generatedBy
          : generatedBy // ignore: cast_nullable_to_non_nullable
              as Uid?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@UidJsonKey Uid roomUid,
      @UidJsonKey Uid from,
      @UidJsonKey Uid to,
      String packetId,
      int time,
      String json,
      int replyToId,
      MessageType type,
      bool edited,
      bool encrypted,
      bool isHidden,
      bool isLocalMessage,
      String? markup,
      int? id,
      int? localNetworkMessageId,
      @NullableUidJsonKey Uid? forwardedFrom,
      @NullableUidJsonKey Uid? generatedBy});
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomUid = null,
    Object? from = null,
    Object? to = null,
    Object? packetId = null,
    Object? time = null,
    Object? json = null,
    Object? replyToId = null,
    Object? type = null,
    Object? edited = null,
    Object? encrypted = null,
    Object? isHidden = null,
    Object? isLocalMessage = null,
    Object? markup = freezed,
    Object? id = freezed,
    Object? localNetworkMessageId = freezed,
    Object? forwardedFrom = freezed,
    Object? generatedBy = freezed,
  }) {
    return _then(_$MessageImpl(
      roomUid: null == roomUid
          ? _value.roomUid
          : roomUid // ignore: cast_nullable_to_non_nullable
              as Uid,
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as Uid,
      to: null == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as Uid,
      packetId: null == packetId
          ? _value.packetId
          : packetId // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      json: null == json
          ? _value.json
          : json // ignore: cast_nullable_to_non_nullable
              as String,
      replyToId: null == replyToId
          ? _value.replyToId
          : replyToId // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      edited: null == edited
          ? _value.edited
          : edited // ignore: cast_nullable_to_non_nullable
              as bool,
      encrypted: null == encrypted
          ? _value.encrypted
          : encrypted // ignore: cast_nullable_to_non_nullable
              as bool,
      isHidden: null == isHidden
          ? _value.isHidden
          : isHidden // ignore: cast_nullable_to_non_nullable
              as bool,
      isLocalMessage: null == isLocalMessage
          ? _value.isLocalMessage
          : isLocalMessage // ignore: cast_nullable_to_non_nullable
              as bool,
      markup: freezed == markup
          ? _value.markup
          : markup // ignore: cast_nullable_to_non_nullable
              as String?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      localNetworkMessageId: freezed == localNetworkMessageId
          ? _value.localNetworkMessageId
          : localNetworkMessageId // ignore: cast_nullable_to_non_nullable
              as int?,
      forwardedFrom: freezed == forwardedFrom
          ? _value.forwardedFrom
          : forwardedFrom // ignore: cast_nullable_to_non_nullable
              as Uid?,
      generatedBy: freezed == generatedBy
          ? _value.generatedBy
          : generatedBy // ignore: cast_nullable_to_non_nullable
              as Uid?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl(
      {@UidJsonKey required this.roomUid,
      @UidJsonKey required this.from,
      @UidJsonKey required this.to,
      required this.packetId,
      required this.time,
      required this.json,
      this.replyToId = 0,
      this.type = MessageType.NOT_SET,
      this.edited = false,
      this.encrypted = false,
      this.isHidden = false,
      this.isLocalMessage = false,
      this.markup,
      this.id,
      this.localNetworkMessageId,
      @NullableUidJsonKey this.forwardedFrom,
      @NullableUidJsonKey this.generatedBy});

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  @UidJsonKey
  final Uid roomUid;
  @override
  @UidJsonKey
  final Uid from;
  @override
  @UidJsonKey
  final Uid to;
  @override
  final String packetId;
  @override
  final int time;
  @override
  final String json;
  @override
  @JsonKey()
  final int replyToId;
  @override
  @JsonKey()
  final MessageType type;
  @override
  @JsonKey()
  final bool edited;
  @override
  @JsonKey()
  final bool encrypted;
  @override
  @JsonKey()
  final bool isHidden;
  @override
  @JsonKey()
  final bool isLocalMessage;
  @override
  final String? markup;
  @override
  final int? id;
  @override
  final int? localNetworkMessageId;
  @override
  @NullableUidJsonKey
  final Uid? forwardedFrom;
  @override
  @NullableUidJsonKey
  final Uid? generatedBy;

  @override
  String toString() {
    return 'Message(roomUid: $roomUid, from: $from, to: $to, packetId: $packetId, time: $time, json: $json, replyToId: $replyToId, type: $type, edited: $edited, encrypted: $encrypted, isHidden: $isHidden, isLocalMessage: $isLocalMessage, markup: $markup, id: $id, localNetworkMessageId: $localNetworkMessageId, forwardedFrom: $forwardedFrom, generatedBy: $generatedBy)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.roomUid, roomUid) || other.roomUid == roomUid) &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            (identical(other.packetId, packetId) ||
                other.packetId == packetId) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.json, json) || other.json == json) &&
            (identical(other.replyToId, replyToId) ||
                other.replyToId == replyToId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.edited, edited) || other.edited == edited) &&
            (identical(other.encrypted, encrypted) ||
                other.encrypted == encrypted) &&
            (identical(other.isHidden, isHidden) ||
                other.isHidden == isHidden) &&
            (identical(other.isLocalMessage, isLocalMessage) ||
                other.isLocalMessage == isLocalMessage) &&
            (identical(other.markup, markup) || other.markup == markup) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.localNetworkMessageId, localNetworkMessageId) ||
                other.localNetworkMessageId == localNetworkMessageId) &&
            (identical(other.forwardedFrom, forwardedFrom) ||
                other.forwardedFrom == forwardedFrom) &&
            (identical(other.generatedBy, generatedBy) ||
                other.generatedBy == generatedBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      roomUid,
      from,
      to,
      packetId,
      time,
      json,
      replyToId,
      type,
      edited,
      encrypted,
      isHidden,
      isLocalMessage,
      markup,
      id,
      localNetworkMessageId,
      forwardedFrom,
      generatedBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message implements Message {
  const factory _Message(
      {@UidJsonKey required final Uid roomUid,
      @UidJsonKey required final Uid from,
      @UidJsonKey required final Uid to,
      required final String packetId,
      required final int time,
      required final String json,
      final int replyToId,
      final MessageType type,
      final bool edited,
      final bool encrypted,
      final bool isHidden,
      final bool isLocalMessage,
      final String? markup,
      final int? id,
      final int? localNetworkMessageId,
      @NullableUidJsonKey final Uid? forwardedFrom,
      @NullableUidJsonKey final Uid? generatedBy}) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  @UidJsonKey
  Uid get roomUid;
  @override
  @UidJsonKey
  Uid get from;
  @override
  @UidJsonKey
  Uid get to;
  @override
  String get packetId;
  @override
  int get time;
  @override
  String get json;
  @override
  int get replyToId;
  @override
  MessageType get type;
  @override
  bool get edited;
  @override
  bool get encrypted;
  @override
  bool get isHidden;
  @override
  bool get isLocalMessage;
  @override
  String? get markup;
  @override
  int? get id;
  @override
  int? get localNetworkMessageId;
  @override
  @NullableUidJsonKey
  Uid? get forwardedFrom;
  @override
  @NullableUidJsonKey
  Uid? get generatedBy;
  @override
  @JsonKey(ignore: true)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
