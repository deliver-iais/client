// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Member _$MemberFromJson(Map<String, dynamic> json) {
  return _Member.fromJson(json);
}

/// @nodoc
mixin _$Member {
  @UidJsonKey
  Uid get mucUid => throw _privateConstructorUsedError;
  @UidJsonKey
  Uid get memberUid => throw _privateConstructorUsedError;
  MucRole get role => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get realName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MemberCopyWith<Member> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberCopyWith<$Res> {
  factory $MemberCopyWith(Member value, $Res Function(Member) then) =
      _$MemberCopyWithImpl<$Res, Member>;
  @useResult
  $Res call(
      {@UidJsonKey Uid mucUid,
      @UidJsonKey Uid memberUid,
      MucRole role,
      String username,
      String name,
      String realName});
}

/// @nodoc
class _$MemberCopyWithImpl<$Res, $Val extends Member>
    implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mucUid = null,
    Object? memberUid = null,
    Object? role = null,
    Object? username = null,
    Object? name = null,
    Object? realName = null,
  }) {
    return _then(_value.copyWith(
      mucUid: null == mucUid
          ? _value.mucUid
          : mucUid // ignore: cast_nullable_to_non_nullable
              as Uid,
      memberUid: null == memberUid
          ? _value.memberUid
          : memberUid // ignore: cast_nullable_to_non_nullable
              as Uid,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as MucRole,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      realName: null == realName
          ? _value.realName
          : realName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MemberImplCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$$MemberImplCopyWith(
          _$MemberImpl value, $Res Function(_$MemberImpl) then) =
      __$$MemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@UidJsonKey Uid mucUid,
      @UidJsonKey Uid memberUid,
      MucRole role,
      String username,
      String name,
      String realName});
}

/// @nodoc
class __$$MemberImplCopyWithImpl<$Res>
    extends _$MemberCopyWithImpl<$Res, _$MemberImpl>
    implements _$$MemberImplCopyWith<$Res> {
  __$$MemberImplCopyWithImpl(
      _$MemberImpl _value, $Res Function(_$MemberImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mucUid = null,
    Object? memberUid = null,
    Object? role = null,
    Object? username = null,
    Object? name = null,
    Object? realName = null,
  }) {
    return _then(_$MemberImpl(
      mucUid: null == mucUid
          ? _value.mucUid
          : mucUid // ignore: cast_nullable_to_non_nullable
              as Uid,
      memberUid: null == memberUid
          ? _value.memberUid
          : memberUid // ignore: cast_nullable_to_non_nullable
              as Uid,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as MucRole,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      realName: null == realName
          ? _value.realName
          : realName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberImpl implements _Member {
  const _$MemberImpl(
      {@UidJsonKey required this.mucUid,
      @UidJsonKey required this.memberUid,
      this.role = MucRole.NONE,
      this.username = "",
      this.name = "",
      this.realName = ""});

  factory _$MemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberImplFromJson(json);

  @override
  @UidJsonKey
  final Uid mucUid;
  @override
  @UidJsonKey
  final Uid memberUid;
  @override
  @JsonKey()
  final MucRole role;
  @override
  @JsonKey()
  final String username;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String realName;

  @override
  String toString() {
    return 'Member(mucUid: $mucUid, memberUid: $memberUid, role: $role, username: $username, name: $name, realName: $realName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberImpl &&
            (identical(other.mucUid, mucUid) || other.mucUid == mucUid) &&
            (identical(other.memberUid, memberUid) ||
                other.memberUid == memberUid) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.realName, realName) ||
                other.realName == realName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, mucUid, memberUid, role, username, name, realName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberImplCopyWith<_$MemberImpl> get copyWith =>
      __$$MemberImplCopyWithImpl<_$MemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberImplToJson(
      this,
    );
  }
}

abstract class _Member implements Member {
  const factory _Member(
      {@UidJsonKey required final Uid mucUid,
      @UidJsonKey required final Uid memberUid,
      final MucRole role,
      final String username,
      final String name,
      final String realName}) = _$MemberImpl;

  factory _Member.fromJson(Map<String, dynamic> json) = _$MemberImpl.fromJson;

  @override
  @UidJsonKey
  Uid get mucUid;
  @override
  @UidJsonKey
  Uid get memberUid;
  @override
  MucRole get role;
  @override
  String get username;
  @override
  String get name;
  @override
  String get realName;
  @override
  @JsonKey(ignore: true)
  _$$MemberImplCopyWith<_$MemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
