// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'broadcast_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BroadcastMember _$BroadcastMemberFromJson(Map<String, dynamic> json) {
  return _BroadcastMember.fromJson(json);
}

/// @nodoc
mixin _$BroadcastMember {
  @UidJsonKey
  Uid get broadcastUid => throw _privateConstructorUsedError;
  @NullableUidJsonKey
  Uid? get memberUid => throw _privateConstructorUsedError;
  @NullablePhoneNumberJsonKey
  PhoneNumber? get phoneNumber => throw _privateConstructorUsedError;
  BroadCastMemberType get type => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BroadcastMemberCopyWith<BroadcastMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BroadcastMemberCopyWith<$Res> {
  factory $BroadcastMemberCopyWith(
          BroadcastMember value, $Res Function(BroadcastMember) then) =
      _$BroadcastMemberCopyWithImpl<$Res, BroadcastMember>;
  @useResult
  $Res call(
      {@UidJsonKey Uid broadcastUid,
      @NullableUidJsonKey Uid? memberUid,
      @NullablePhoneNumberJsonKey PhoneNumber? phoneNumber,
      BroadCastMemberType type,
      String name});
}

/// @nodoc
class _$BroadcastMemberCopyWithImpl<$Res, $Val extends BroadcastMember>
    implements $BroadcastMemberCopyWith<$Res> {
  _$BroadcastMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? broadcastUid = null,
    Object? memberUid = freezed,
    Object? phoneNumber = freezed,
    Object? type = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      broadcastUid: null == broadcastUid
          ? _value.broadcastUid
          : broadcastUid // ignore: cast_nullable_to_non_nullable
              as Uid,
      memberUid: freezed == memberUid
          ? _value.memberUid
          : memberUid // ignore: cast_nullable_to_non_nullable
              as Uid?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as PhoneNumber?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as BroadCastMemberType,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BroadcastMemberImplCopyWith<$Res>
    implements $BroadcastMemberCopyWith<$Res> {
  factory _$$BroadcastMemberImplCopyWith(_$BroadcastMemberImpl value,
          $Res Function(_$BroadcastMemberImpl) then) =
      __$$BroadcastMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@UidJsonKey Uid broadcastUid,
      @NullableUidJsonKey Uid? memberUid,
      @NullablePhoneNumberJsonKey PhoneNumber? phoneNumber,
      BroadCastMemberType type,
      String name});
}

/// @nodoc
class __$$BroadcastMemberImplCopyWithImpl<$Res>
    extends _$BroadcastMemberCopyWithImpl<$Res, _$BroadcastMemberImpl>
    implements _$$BroadcastMemberImplCopyWith<$Res> {
  __$$BroadcastMemberImplCopyWithImpl(
      _$BroadcastMemberImpl _value, $Res Function(_$BroadcastMemberImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? broadcastUid = null,
    Object? memberUid = freezed,
    Object? phoneNumber = freezed,
    Object? type = null,
    Object? name = null,
  }) {
    return _then(_$BroadcastMemberImpl(
      broadcastUid: null == broadcastUid
          ? _value.broadcastUid
          : broadcastUid // ignore: cast_nullable_to_non_nullable
              as Uid,
      memberUid: freezed == memberUid
          ? _value.memberUid
          : memberUid // ignore: cast_nullable_to_non_nullable
              as Uid?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as PhoneNumber?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as BroadCastMemberType,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BroadcastMemberImpl implements _BroadcastMember {
  const _$BroadcastMemberImpl(
      {@UidJsonKey required this.broadcastUid,
      @NullableUidJsonKey this.memberUid,
      @NullablePhoneNumberJsonKey this.phoneNumber,
      this.type = BroadCastMemberType.MESSAGE,
      this.name = ""});

  factory _$BroadcastMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$BroadcastMemberImplFromJson(json);

  @override
  @UidJsonKey
  final Uid broadcastUid;
  @override
  @NullableUidJsonKey
  final Uid? memberUid;
  @override
  @NullablePhoneNumberJsonKey
  final PhoneNumber? phoneNumber;
  @override
  @JsonKey()
  final BroadCastMemberType type;
  @override
  @JsonKey()
  final String name;

  @override
  String toString() {
    return 'BroadcastMember(broadcastUid: $broadcastUid, memberUid: $memberUid, phoneNumber: $phoneNumber, type: $type, name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BroadcastMemberImpl &&
            (identical(other.broadcastUid, broadcastUid) ||
                other.broadcastUid == broadcastUid) &&
            (identical(other.memberUid, memberUid) ||
                other.memberUid == memberUid) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, broadcastUid, memberUid, phoneNumber, type, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BroadcastMemberImplCopyWith<_$BroadcastMemberImpl> get copyWith =>
      __$$BroadcastMemberImplCopyWithImpl<_$BroadcastMemberImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BroadcastMemberImplToJson(
      this,
    );
  }
}

abstract class _BroadcastMember implements BroadcastMember {
  const factory _BroadcastMember(
      {@UidJsonKey required final Uid broadcastUid,
      @NullableUidJsonKey final Uid? memberUid,
      @NullablePhoneNumberJsonKey final PhoneNumber? phoneNumber,
      final BroadCastMemberType type,
      final String name}) = _$BroadcastMemberImpl;

  factory _BroadcastMember.fromJson(Map<String, dynamic> json) =
      _$BroadcastMemberImpl.fromJson;

  @override
  @UidJsonKey
  Uid get broadcastUid;
  @override
  @NullableUidJsonKey
  Uid? get memberUid;
  @override
  @NullablePhoneNumberJsonKey
  PhoneNumber? get phoneNumber;
  @override
  BroadCastMemberType get type;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$BroadcastMemberImplCopyWith<_$BroadcastMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
