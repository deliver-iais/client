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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

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

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MemberCopyWith<Member> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberCopyWith<$Res> {
  factory $MemberCopyWith(Member value, $Res Function(Member) then) =
      _$MemberCopyWithImpl<$Res, Member>;
  @useResult
  $Res call({@UidJsonKey Uid mucUid, @UidJsonKey Uid memberUid, MucRole role});
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MemberCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$$_MemberCopyWith(_$_Member value, $Res Function(_$_Member) then) =
      __$$_MemberCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@UidJsonKey Uid mucUid, @UidJsonKey Uid memberUid, MucRole role});
}

/// @nodoc
class __$$_MemberCopyWithImpl<$Res>
    extends _$MemberCopyWithImpl<$Res, _$_Member>
    implements _$$_MemberCopyWith<$Res> {
  __$$_MemberCopyWithImpl(_$_Member _value, $Res Function(_$_Member) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mucUid = null,
    Object? memberUid = null,
    Object? role = null,
  }) {
    return _then(_$_Member(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Member implements _Member {
  const _$_Member(
      {@UidJsonKey required this.mucUid,
      @UidJsonKey required this.memberUid,
      this.role = MucRole.NONE});

  factory _$_Member.fromJson(Map<String, dynamic> json) =>
      _$$_MemberFromJson(json);

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
  String toString() {
    return 'Member(mucUid: $mucUid, memberUid: $memberUid, role: $role)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Member &&
            (identical(other.mucUid, mucUid) || other.mucUid == mucUid) &&
            (identical(other.memberUid, memberUid) ||
                other.memberUid == memberUid) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, mucUid, memberUid, role);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MemberCopyWith<_$_Member> get copyWith =>
      __$$_MemberCopyWithImpl<_$_Member>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MemberToJson(
      this,
    );
  }
}

abstract class _Member implements Member {
  const factory _Member(
      {@UidJsonKey required final Uid mucUid,
      @UidJsonKey required final Uid memberUid,
      final MucRole role}) = _$_Member;

  factory _Member.fromJson(Map<String, dynamic> json) = _$_Member.fromJson;

  @override
  @UidJsonKey
  Uid get mucUid;
  @override
  @UidJsonKey
  Uid get memberUid;
  @override
  MucRole get role;
  @override
  @JsonKey(ignore: true)
  _$$_MemberCopyWith<_$_Member> get copyWith =>
      throw _privateConstructorUsedError;
}
