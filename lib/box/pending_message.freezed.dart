// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PendingMessage _$PendingMessageFromJson(Map<String, dynamic> json) {
  return _PendingMessage.fromJson(json);
}

/// @nodoc
mixin _$PendingMessage {
  @UidJsonKey
  Uid get roomUid => throw _privateConstructorUsedError;
  String get packetId => throw _privateConstructorUsedError;
  @MessageJsonKey
  Message get msg => throw _privateConstructorUsedError;
  bool get failed => throw _privateConstructorUsedError;
  SendingStatus get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PendingMessageCopyWith<PendingMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PendingMessageCopyWith<$Res> {
  factory $PendingMessageCopyWith(
          PendingMessage value, $Res Function(PendingMessage) then) =
      _$PendingMessageCopyWithImpl<$Res, PendingMessage>;
  @useResult
  $Res call(
      {@UidJsonKey Uid roomUid,
      String packetId,
      @MessageJsonKey Message msg,
      bool failed,
      SendingStatus status});

  $MessageCopyWith<$Res> get msg;
}

/// @nodoc
class _$PendingMessageCopyWithImpl<$Res, $Val extends PendingMessage>
    implements $PendingMessageCopyWith<$Res> {
  _$PendingMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomUid = null,
    Object? packetId = null,
    Object? msg = null,
    Object? failed = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      roomUid: null == roomUid
          ? _value.roomUid
          : roomUid // ignore: cast_nullable_to_non_nullable
              as Uid,
      packetId: null == packetId
          ? _value.packetId
          : packetId // ignore: cast_nullable_to_non_nullable
              as String,
      msg: null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as Message,
      failed: null == failed
          ? _value.failed
          : failed // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SendingStatus,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MessageCopyWith<$Res> get msg {
    return $MessageCopyWith<$Res>(_value.msg, (value) {
      return _then(_value.copyWith(msg: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_PendingMessageCopyWith<$Res>
    implements $PendingMessageCopyWith<$Res> {
  factory _$$_PendingMessageCopyWith(
          _$_PendingMessage value, $Res Function(_$_PendingMessage) then) =
      __$$_PendingMessageCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@UidJsonKey Uid roomUid,
      String packetId,
      @MessageJsonKey Message msg,
      bool failed,
      SendingStatus status});

  @override
  $MessageCopyWith<$Res> get msg;
}

/// @nodoc
class __$$_PendingMessageCopyWithImpl<$Res>
    extends _$PendingMessageCopyWithImpl<$Res, _$_PendingMessage>
    implements _$$_PendingMessageCopyWith<$Res> {
  __$$_PendingMessageCopyWithImpl(
      _$_PendingMessage _value, $Res Function(_$_PendingMessage) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomUid = null,
    Object? packetId = null,
    Object? msg = null,
    Object? failed = null,
    Object? status = null,
  }) {
    return _then(_$_PendingMessage(
      roomUid: null == roomUid
          ? _value.roomUid
          : roomUid // ignore: cast_nullable_to_non_nullable
              as Uid,
      packetId: null == packetId
          ? _value.packetId
          : packetId // ignore: cast_nullable_to_non_nullable
              as String,
      msg: null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as Message,
      failed: null == failed
          ? _value.failed
          : failed // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SendingStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PendingMessage implements _PendingMessage {
  const _$_PendingMessage(
      {@UidJsonKey required this.roomUid,
      required this.packetId,
      @MessageJsonKey required this.msg,
      this.failed = false,
      required this.status});

  factory _$_PendingMessage.fromJson(Map<String, dynamic> json) =>
      _$$_PendingMessageFromJson(json);

  @override
  @UidJsonKey
  final Uid roomUid;
  @override
  final String packetId;
  @override
  @MessageJsonKey
  final Message msg;
  @override
  @JsonKey()
  final bool failed;
  @override
  final SendingStatus status;

  @override
  String toString() {
    return 'PendingMessage(roomUid: $roomUid, packetId: $packetId, msg: $msg, failed: $failed, status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PendingMessage &&
            (identical(other.roomUid, roomUid) || other.roomUid == roomUid) &&
            (identical(other.packetId, packetId) ||
                other.packetId == packetId) &&
            (identical(other.msg, msg) || other.msg == msg) &&
            (identical(other.failed, failed) || other.failed == failed) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, roomUid, packetId, msg, failed, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PendingMessageCopyWith<_$_PendingMessage> get copyWith =>
      __$$_PendingMessageCopyWithImpl<_$_PendingMessage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PendingMessageToJson(
      this,
    );
  }
}

abstract class _PendingMessage implements PendingMessage {
  const factory _PendingMessage(
      {@UidJsonKey required final Uid roomUid,
      required final String packetId,
      @MessageJsonKey required final Message msg,
      final bool failed,
      required final SendingStatus status}) = _$_PendingMessage;

  factory _PendingMessage.fromJson(Map<String, dynamic> json) =
      _$_PendingMessage.fromJson;

  @override
  @UidJsonKey
  Uid get roomUid;
  @override
  String get packetId;
  @override
  @MessageJsonKey
  Message get msg;
  @override
  bool get failed;
  @override
  SendingStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$_PendingMessageCopyWith<_$_PendingMessage> get copyWith =>
      throw _privateConstructorUsedError;
}
