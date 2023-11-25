// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Room _$RoomFromJson(Map<String, dynamic> json) {
  return _Room.fromJson(json);
}

/// @nodoc
mixin _$Room {
  @UidJsonKey
  Uid get uid => throw _privateConstructorUsedError;
  @NullableMessageJsonKey
  Message? get lastMessage => throw _privateConstructorUsedError;
  String? get replyKeyboardMarkup => throw _privateConstructorUsedError;
  String get draft => throw _privateConstructorUsedError;
  List<int> get mentionsId => throw _privateConstructorUsedError;
  int get lastUpdateTime => throw _privateConstructorUsedError;
  int get lastMessageId => throw _privateConstructorUsedError;
  int get localNetworkMessageCount => throw _privateConstructorUsedError;
  int get lastLocalNetworkMessageId => throw _privateConstructorUsedError;
  int get firstMessageId => throw _privateConstructorUsedError;
  int get pinId => throw _privateConstructorUsedError;
  int get lastCurrentUserSentMessageId => throw _privateConstructorUsedError;
  bool get deleted => throw _privateConstructorUsedError;
  bool get pinned => throw _privateConstructorUsedError;
  bool get synced => throw _privateConstructorUsedError;
  bool get seenSynced => throw _privateConstructorUsedError;
  bool get shouldUpdateMediaCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoomCopyWith<Room> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomCopyWith<$Res> {
  factory $RoomCopyWith(Room value, $Res Function(Room) then) =
      _$RoomCopyWithImpl<$Res, Room>;
  @useResult
  $Res call(
      {@UidJsonKey Uid uid,
      @NullableMessageJsonKey Message? lastMessage,
      String? replyKeyboardMarkup,
      String draft,
      List<int> mentionsId,
      int lastUpdateTime,
      int lastMessageId,
      int localNetworkMessageCount,
      int lastLocalNetworkMessageId,
      int firstMessageId,
      int pinId,
      int lastCurrentUserSentMessageId,
      bool deleted,
      bool pinned,
      bool synced,
      bool seenSynced,
      bool shouldUpdateMediaCount});

  $MessageCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class _$RoomCopyWithImpl<$Res, $Val extends Room>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? lastMessage = freezed,
    Object? replyKeyboardMarkup = freezed,
    Object? draft = null,
    Object? mentionsId = null,
    Object? lastUpdateTime = null,
    Object? lastMessageId = null,
    Object? localNetworkMessageCount = null,
    Object? lastLocalNetworkMessageId = null,
    Object? firstMessageId = null,
    Object? pinId = null,
    Object? lastCurrentUserSentMessageId = null,
    Object? deleted = null,
    Object? pinned = null,
    Object? synced = null,
    Object? seenSynced = null,
    Object? shouldUpdateMediaCount = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as Uid,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as Message?,
      replyKeyboardMarkup: freezed == replyKeyboardMarkup
          ? _value.replyKeyboardMarkup
          : replyKeyboardMarkup // ignore: cast_nullable_to_non_nullable
              as String?,
      draft: null == draft
          ? _value.draft
          : draft // ignore: cast_nullable_to_non_nullable
              as String,
      mentionsId: null == mentionsId
          ? _value.mentionsId
          : mentionsId // ignore: cast_nullable_to_non_nullable
              as List<int>,
      lastUpdateTime: null == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as int,
      lastMessageId: null == lastMessageId
          ? _value.lastMessageId
          : lastMessageId // ignore: cast_nullable_to_non_nullable
              as int,
      localNetworkMessageCount: null == localNetworkMessageCount
          ? _value.localNetworkMessageCount
          : localNetworkMessageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastLocalNetworkMessageId: null == lastLocalNetworkMessageId
          ? _value.lastLocalNetworkMessageId
          : lastLocalNetworkMessageId // ignore: cast_nullable_to_non_nullable
              as int,
      firstMessageId: null == firstMessageId
          ? _value.firstMessageId
          : firstMessageId // ignore: cast_nullable_to_non_nullable
              as int,
      pinId: null == pinId
          ? _value.pinId
          : pinId // ignore: cast_nullable_to_non_nullable
              as int,
      lastCurrentUserSentMessageId: null == lastCurrentUserSentMessageId
          ? _value.lastCurrentUserSentMessageId
          : lastCurrentUserSentMessageId // ignore: cast_nullable_to_non_nullable
              as int,
      deleted: null == deleted
          ? _value.deleted
          : deleted // ignore: cast_nullable_to_non_nullable
              as bool,
      pinned: null == pinned
          ? _value.pinned
          : pinned // ignore: cast_nullable_to_non_nullable
              as bool,
      synced: null == synced
          ? _value.synced
          : synced // ignore: cast_nullable_to_non_nullable
              as bool,
      seenSynced: null == seenSynced
          ? _value.seenSynced
          : seenSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      shouldUpdateMediaCount: null == shouldUpdateMediaCount
          ? _value.shouldUpdateMediaCount
          : shouldUpdateMediaCount // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MessageCopyWith<$Res>? get lastMessage {
    if (_value.lastMessage == null) {
      return null;
    }

    return $MessageCopyWith<$Res>(_value.lastMessage!, (value) {
      return _then(_value.copyWith(lastMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RoomImplCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$$RoomImplCopyWith(
          _$RoomImpl value, $Res Function(_$RoomImpl) then) =
      __$$RoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@UidJsonKey Uid uid,
      @NullableMessageJsonKey Message? lastMessage,
      String? replyKeyboardMarkup,
      String draft,
      List<int> mentionsId,
      int lastUpdateTime,
      int lastMessageId,
      int localNetworkMessageCount,
      int lastLocalNetworkMessageId,
      int firstMessageId,
      int pinId,
      int lastCurrentUserSentMessageId,
      bool deleted,
      bool pinned,
      bool synced,
      bool seenSynced,
      bool shouldUpdateMediaCount});

  @override
  $MessageCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class __$$RoomImplCopyWithImpl<$Res>
    extends _$RoomCopyWithImpl<$Res, _$RoomImpl>
    implements _$$RoomImplCopyWith<$Res> {
  __$$RoomImplCopyWithImpl(_$RoomImpl _value, $Res Function(_$RoomImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? lastMessage = freezed,
    Object? replyKeyboardMarkup = freezed,
    Object? draft = null,
    Object? mentionsId = null,
    Object? lastUpdateTime = null,
    Object? lastMessageId = null,
    Object? localNetworkMessageCount = null,
    Object? lastLocalNetworkMessageId = null,
    Object? firstMessageId = null,
    Object? pinId = null,
    Object? lastCurrentUserSentMessageId = null,
    Object? deleted = null,
    Object? pinned = null,
    Object? synced = null,
    Object? seenSynced = null,
    Object? shouldUpdateMediaCount = null,
  }) {
    return _then(_$RoomImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as Uid,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as Message?,
      replyKeyboardMarkup: freezed == replyKeyboardMarkup
          ? _value.replyKeyboardMarkup
          : replyKeyboardMarkup // ignore: cast_nullable_to_non_nullable
              as String?,
      draft: null == draft
          ? _value.draft
          : draft // ignore: cast_nullable_to_non_nullable
              as String,
      mentionsId: null == mentionsId
          ? _value._mentionsId
          : mentionsId // ignore: cast_nullable_to_non_nullable
              as List<int>,
      lastUpdateTime: null == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as int,
      lastMessageId: null == lastMessageId
          ? _value.lastMessageId
          : lastMessageId // ignore: cast_nullable_to_non_nullable
              as int,
      localNetworkMessageCount: null == localNetworkMessageCount
          ? _value.localNetworkMessageCount
          : localNetworkMessageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastLocalNetworkMessageId: null == lastLocalNetworkMessageId
          ? _value.lastLocalNetworkMessageId
          : lastLocalNetworkMessageId // ignore: cast_nullable_to_non_nullable
              as int,
      firstMessageId: null == firstMessageId
          ? _value.firstMessageId
          : firstMessageId // ignore: cast_nullable_to_non_nullable
              as int,
      pinId: null == pinId
          ? _value.pinId
          : pinId // ignore: cast_nullable_to_non_nullable
              as int,
      lastCurrentUserSentMessageId: null == lastCurrentUserSentMessageId
          ? _value.lastCurrentUserSentMessageId
          : lastCurrentUserSentMessageId // ignore: cast_nullable_to_non_nullable
              as int,
      deleted: null == deleted
          ? _value.deleted
          : deleted // ignore: cast_nullable_to_non_nullable
              as bool,
      pinned: null == pinned
          ? _value.pinned
          : pinned // ignore: cast_nullable_to_non_nullable
              as bool,
      synced: null == synced
          ? _value.synced
          : synced // ignore: cast_nullable_to_non_nullable
              as bool,
      seenSynced: null == seenSynced
          ? _value.seenSynced
          : seenSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      shouldUpdateMediaCount: null == shouldUpdateMediaCount
          ? _value.shouldUpdateMediaCount
          : shouldUpdateMediaCount // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomImpl implements _Room {
  const _$RoomImpl(
      {@UidJsonKey required this.uid,
      @NullableMessageJsonKey this.lastMessage,
      this.replyKeyboardMarkup,
      this.draft = "",
      final List<int> mentionsId = const [],
      this.lastUpdateTime = 0,
      this.lastMessageId = 0,
      this.localNetworkMessageCount = 0,
      this.lastLocalNetworkMessageId = 0,
      this.firstMessageId = 0,
      this.pinId = 0,
      this.lastCurrentUserSentMessageId = 0,
      this.deleted = false,
      this.pinned = false,
      this.synced = false,
      this.seenSynced = false,
      this.shouldUpdateMediaCount = true})
      : _mentionsId = mentionsId;

  factory _$RoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomImplFromJson(json);

  @override
  @UidJsonKey
  final Uid uid;
  @override
  @NullableMessageJsonKey
  final Message? lastMessage;
  @override
  final String? replyKeyboardMarkup;
  @override
  @JsonKey()
  final String draft;
  final List<int> _mentionsId;
  @override
  @JsonKey()
  List<int> get mentionsId {
    if (_mentionsId is EqualUnmodifiableListView) return _mentionsId;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mentionsId);
  }

  @override
  @JsonKey()
  final int lastUpdateTime;
  @override
  @JsonKey()
  final int lastMessageId;
  @override
  @JsonKey()
  final int localNetworkMessageCount;
  @override
  @JsonKey()
  final int lastLocalNetworkMessageId;
  @override
  @JsonKey()
  final int firstMessageId;
  @override
  @JsonKey()
  final int pinId;
  @override
  @JsonKey()
  final int lastCurrentUserSentMessageId;
  @override
  @JsonKey()
  final bool deleted;
  @override
  @JsonKey()
  final bool pinned;
  @override
  @JsonKey()
  final bool synced;
  @override
  @JsonKey()
  final bool seenSynced;
  @override
  @JsonKey()
  final bool shouldUpdateMediaCount;

  @override
  String toString() {
    return 'Room(uid: $uid, lastMessage: $lastMessage, replyKeyboardMarkup: $replyKeyboardMarkup, draft: $draft, mentionsId: $mentionsId, lastUpdateTime: $lastUpdateTime, lastMessageId: $lastMessageId, localNetworkMessageCount: $localNetworkMessageCount, lastLocalNetworkMessageId: $lastLocalNetworkMessageId, firstMessageId: $firstMessageId, pinId: $pinId, lastCurrentUserSentMessageId: $lastCurrentUserSentMessageId, deleted: $deleted, pinned: $pinned, synced: $synced, seenSynced: $seenSynced, shouldUpdateMediaCount: $shouldUpdateMediaCount)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.replyKeyboardMarkup, replyKeyboardMarkup) ||
                other.replyKeyboardMarkup == replyKeyboardMarkup) &&
            (identical(other.draft, draft) || other.draft == draft) &&
            const DeepCollectionEquality()
                .equals(other._mentionsId, _mentionsId) &&
            (identical(other.lastUpdateTime, lastUpdateTime) ||
                other.lastUpdateTime == lastUpdateTime) &&
            (identical(other.lastMessageId, lastMessageId) ||
                other.lastMessageId == lastMessageId) &&
            (identical(
                    other.localNetworkMessageCount, localNetworkMessageCount) ||
                other.localNetworkMessageCount == localNetworkMessageCount) &&
            (identical(other.lastLocalNetworkMessageId,
                    lastLocalNetworkMessageId) ||
                other.lastLocalNetworkMessageId == lastLocalNetworkMessageId) &&
            (identical(other.firstMessageId, firstMessageId) ||
                other.firstMessageId == firstMessageId) &&
            (identical(other.pinId, pinId) || other.pinId == pinId) &&
            (identical(other.lastCurrentUserSentMessageId,
                    lastCurrentUserSentMessageId) ||
                other.lastCurrentUserSentMessageId ==
                    lastCurrentUserSentMessageId) &&
            (identical(other.deleted, deleted) || other.deleted == deleted) &&
            (identical(other.pinned, pinned) || other.pinned == pinned) &&
            (identical(other.synced, synced) || other.synced == synced) &&
            (identical(other.seenSynced, seenSynced) ||
                other.seenSynced == seenSynced) &&
            (identical(other.shouldUpdateMediaCount, shouldUpdateMediaCount) ||
                other.shouldUpdateMediaCount == shouldUpdateMediaCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      lastMessage,
      replyKeyboardMarkup,
      draft,
      const DeepCollectionEquality().hash(_mentionsId),
      lastUpdateTime,
      lastMessageId,
      localNetworkMessageCount,
      lastLocalNetworkMessageId,
      firstMessageId,
      pinId,
      lastCurrentUserSentMessageId,
      deleted,
      pinned,
      synced,
      seenSynced,
      shouldUpdateMediaCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      __$$RoomImplCopyWithImpl<_$RoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomImplToJson(
      this,
    );
  }
}

abstract class _Room implements Room {
  const factory _Room(
      {@UidJsonKey required final Uid uid,
      @NullableMessageJsonKey final Message? lastMessage,
      final String? replyKeyboardMarkup,
      final String draft,
      final List<int> mentionsId,
      final int lastUpdateTime,
      final int lastMessageId,
      final int localNetworkMessageCount,
      final int lastLocalNetworkMessageId,
      final int firstMessageId,
      final int pinId,
      final int lastCurrentUserSentMessageId,
      final bool deleted,
      final bool pinned,
      final bool synced,
      final bool seenSynced,
      final bool shouldUpdateMediaCount}) = _$RoomImpl;

  factory _Room.fromJson(Map<String, dynamic> json) = _$RoomImpl.fromJson;

  @override
  @UidJsonKey
  Uid get uid;
  @override
  @NullableMessageJsonKey
  Message? get lastMessage;
  @override
  String? get replyKeyboardMarkup;
  @override
  String get draft;
  @override
  List<int> get mentionsId;
  @override
  int get lastUpdateTime;
  @override
  int get lastMessageId;
  @override
  int get localNetworkMessageCount;
  @override
  int get lastLocalNetworkMessageId;
  @override
  int get firstMessageId;
  @override
  int get pinId;
  @override
  int get lastCurrentUserSentMessageId;
  @override
  bool get deleted;
  @override
  bool get pinned;
  @override
  bool get synced;
  @override
  bool get seenSynced;
  @override
  bool get shouldUpdateMediaCount;
  @override
  @JsonKey(ignore: true)
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
