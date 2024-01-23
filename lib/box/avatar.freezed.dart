// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'avatar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Avatar _$AvatarFromJson(Map<String, dynamic> json) {
  return _Avatar.fromJson(json);
}

/// @nodoc
mixin _$Avatar {
  @UidJsonKey
  Uid get uid => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get fileUuid => throw _privateConstructorUsedError;
  int get lastUpdateTime => throw _privateConstructorUsedError;
  bool get avatarIsEmpty => throw _privateConstructorUsedError;
  int get createdOn => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AvatarCopyWith<Avatar> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvatarCopyWith<$Res> {
  factory $AvatarCopyWith(Avatar value, $Res Function(Avatar) then) =
      _$AvatarCopyWithImpl<$Res, Avatar>;
  @useResult
  $Res call(
      {@UidJsonKey Uid uid,
      String fileName,
      String fileUuid,
      int lastUpdateTime,
      bool avatarIsEmpty,
      int createdOn});
}

/// @nodoc
class _$AvatarCopyWithImpl<$Res, $Val extends Avatar>
    implements $AvatarCopyWith<$Res> {
  _$AvatarCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? fileName = null,
    Object? fileUuid = null,
    Object? lastUpdateTime = null,
    Object? avatarIsEmpty = null,
    Object? createdOn = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as Uid,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileUuid: null == fileUuid
          ? _value.fileUuid
          : fileUuid // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdateTime: null == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as int,
      avatarIsEmpty: null == avatarIsEmpty
          ? _value.avatarIsEmpty
          : avatarIsEmpty // ignore: cast_nullable_to_non_nullable
              as bool,
      createdOn: null == createdOn
          ? _value.createdOn
          : createdOn // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AvatarImplCopyWith<$Res> implements $AvatarCopyWith<$Res> {
  factory _$$AvatarImplCopyWith(
          _$AvatarImpl value, $Res Function(_$AvatarImpl) then) =
      __$$AvatarImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@UidJsonKey Uid uid,
      String fileName,
      String fileUuid,
      int lastUpdateTime,
      bool avatarIsEmpty,
      int createdOn});
}

/// @nodoc
class __$$AvatarImplCopyWithImpl<$Res>
    extends _$AvatarCopyWithImpl<$Res, _$AvatarImpl>
    implements _$$AvatarImplCopyWith<$Res> {
  __$$AvatarImplCopyWithImpl(
      _$AvatarImpl _value, $Res Function(_$AvatarImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? fileName = null,
    Object? fileUuid = null,
    Object? lastUpdateTime = null,
    Object? avatarIsEmpty = null,
    Object? createdOn = null,
  }) {
    return _then(_$AvatarImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as Uid,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileUuid: null == fileUuid
          ? _value.fileUuid
          : fileUuid // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdateTime: null == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as int,
      avatarIsEmpty: null == avatarIsEmpty
          ? _value.avatarIsEmpty
          : avatarIsEmpty // ignore: cast_nullable_to_non_nullable
              as bool,
      createdOn: null == createdOn
          ? _value.createdOn
          : createdOn // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AvatarImpl implements _Avatar {
  const _$AvatarImpl(
      {@UidJsonKey required this.uid,
      required this.fileName,
      required this.fileUuid,
      required this.lastUpdateTime,
      this.avatarIsEmpty = false,
      required this.createdOn});

  factory _$AvatarImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvatarImplFromJson(json);

  @override
  @UidJsonKey
  final Uid uid;
  @override
  final String fileName;
  @override
  final String fileUuid;
  @override
  final int lastUpdateTime;
  @override
  @JsonKey()
  final bool avatarIsEmpty;
  @override
  final int createdOn;

  @override
  String toString() {
    return 'Avatar(uid: $uid, fileName: $fileName, fileUuid: $fileUuid, lastUpdateTime: $lastUpdateTime, avatarIsEmpty: $avatarIsEmpty, createdOn: $createdOn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvatarImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileUuid, fileUuid) ||
                other.fileUuid == fileUuid) &&
            (identical(other.lastUpdateTime, lastUpdateTime) ||
                other.lastUpdateTime == lastUpdateTime) &&
            (identical(other.avatarIsEmpty, avatarIsEmpty) ||
                other.avatarIsEmpty == avatarIsEmpty) &&
            (identical(other.createdOn, createdOn) ||
                other.createdOn == createdOn));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, uid, fileName, fileUuid,
      lastUpdateTime, avatarIsEmpty, createdOn);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AvatarImplCopyWith<_$AvatarImpl> get copyWith =>
      __$$AvatarImplCopyWithImpl<_$AvatarImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AvatarImplToJson(
      this,
    );
  }
}

abstract class _Avatar implements Avatar {
  const factory _Avatar(
      {@UidJsonKey required final Uid uid,
      required final String fileName,
      required final String fileUuid,
      required final int lastUpdateTime,
      final bool avatarIsEmpty,
      required final int createdOn}) = _$AvatarImpl;

  factory _Avatar.fromJson(Map<String, dynamic> json) = _$AvatarImpl.fromJson;

  @override
  @UidJsonKey
  Uid get uid;
  @override
  String get fileName;
  @override
  String get fileUuid;
  @override
  int get lastUpdateTime;
  @override
  bool get avatarIsEmpty;
  @override
  int get createdOn;
  @override
  @JsonKey(ignore: true)
  _$$AvatarImplCopyWith<_$AvatarImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
