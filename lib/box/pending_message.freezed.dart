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
  bool get isLocalMessage => throw _privateConstructorUsedError;
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
      bool isLocalMessage,
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
    Object? isLocalMessage = null,
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
      isLocalMessage: null == isLocalMessage
          ? _value.isLocalMessage
          : isLocalMessage // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PendingMessageImplCopyWith<$Res>
    implements $PendingMessageCopyWith<$Res> {
  factory _$$PendingMessageImplCopyWith(_$PendingMessageImpl value,
          $Res Function(_$PendingMessageImpl) then) =
      __$$PendingMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@UidJsonKey Uid roomUid,
      String packetId,
      @MessageJsonKey Message msg,
      bool failed,
      bool isLocalMessage,
      SendingStatus status});

  @override
  $MessageCopyWith<$Res> get msg;
}

/// @nodoc
class __$$PendingMessageImplCopyWithImpl<$Res>
    extends _$PendingMessageCopyWithImpl<$Res, _$PendingMessageImpl>
    implements _$$PendingMessageImplCopyWith<$Res> {
  __$$PendingMessageImplCopyWithImpl(
      _$PendingMessageImpl _value, $Res Function(_$PendingMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomUid = null,
    Object? packetId = null,
    Object? msg = null,
    Object? failed = null,
    Object? isLocalMessage = null,
    Object? status = null,
  }) {
    return _then(_$PendingMessageImpl(
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
      isLocalMessage: null == isLocalMessage
          ? _value.isLocalMessage
          : isLocalMessage // ignore: cast_nullable_to_non_nullable
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
class _$PendingMessageImpl implements _PendingMessage {
  const _$PendingMessageImpl(
      {@UidJsonKey required this.roomUid,
      required this.packetId,
      @MessageJsonKey required this.msg,
      this.failed = false,
      this.isLocalMessage = false,
      required this.status});

  factory _$PendingMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$PendingMessageImplFromJson(json);

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
  @JsonKey()
  final bool isLocalMessage;
  @override
  final SendingStatus status;

  @override
  String toString() {
    return 'PendingMessage(roomUid: $roomUid, packetId: $packetId, msg: $msg, failed: $failed, isLocalMessage: $isLocalMessage, status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PendingMessageImpl &&
            (identical(other.roomUid, roomUid) || other.roomUid == roomUid) &&
            (identical(other.packetId, packetId) ||
                other.packetId == packetId) &&
            (identical(other.msg, msg) || other.msg == msg) &&
            (identical(other.failed, failed) || other.failed == failed) &&
            (identical(other.isLocalMessage, isLocalMessage) ||
                other.isLocalMessage == isLocalMessage) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, roomUid, packetId, msg, failed, isLocalMessage, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PendingMessageImplCopyWith<_$PendingMessageImpl> get copyWith =>
      __$$PendingMessageImplCopyWithImpl<_$PendingMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PendingMessageImplToJson(
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
      final bool isLocalMessage,
      required final SendingStatus status}) = _$PendingMessageImpl;

  factory _PendingMessage.fromJson(Map<String, dynamic> json) =
      _$PendingMessageImpl.fromJson;

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
  bool get isLocalMessage;
  @override
  SendingStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$PendingMessageImplCopyWith<_$PendingMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
