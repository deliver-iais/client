// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FileInfo _$FileInfoFromJson(Map<String, dynamic> json) {
  return _FileInfo.fromJson(json);
}

/// @nodoc
mixin _$FileInfo {
  String get name => throw _privateConstructorUsedError;
  String get uuid => throw _privateConstructorUsedError;
  String get sizeType => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FileInfoCopyWith<FileInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FileInfoCopyWith<$Res> {
  factory $FileInfoCopyWith(FileInfo value, $Res Function(FileInfo) then) =
      _$FileInfoCopyWithImpl<$Res, FileInfo>;
  @useResult
  $Res call({String name, String uuid, String sizeType, String path});
}

/// @nodoc
class _$FileInfoCopyWithImpl<$Res, $Val extends FileInfo>
    implements $FileInfoCopyWith<$Res> {
  _$FileInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? uuid = null,
    Object? sizeType = null,
    Object? path = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      sizeType: null == sizeType
          ? _value.sizeType
          : sizeType // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FileInfoImplCopyWith<$Res>
    implements $FileInfoCopyWith<$Res> {
  factory _$$FileInfoImplCopyWith(
          _$FileInfoImpl value, $Res Function(_$FileInfoImpl) then) =
      __$$FileInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String uuid, String sizeType, String path});
}

/// @nodoc
class __$$FileInfoImplCopyWithImpl<$Res>
    extends _$FileInfoCopyWithImpl<$Res, _$FileInfoImpl>
    implements _$$FileInfoImplCopyWith<$Res> {
  __$$FileInfoImplCopyWithImpl(
      _$FileInfoImpl _value, $Res Function(_$FileInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? uuid = null,
    Object? sizeType = null,
    Object? path = null,
  }) {
    return _then(_$FileInfoImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      sizeType: null == sizeType
          ? _value.sizeType
          : sizeType // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FileInfoImpl implements _FileInfo {
  const _$FileInfoImpl(
      {required this.name,
      required this.uuid,
      required this.sizeType,
      required this.path});

  factory _$FileInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FileInfoImplFromJson(json);

  @override
  final String name;
  @override
  final String uuid;
  @override
  final String sizeType;
  @override
  final String path;

  @override
  String toString() {
    return 'FileInfo(name: $name, uuid: $uuid, sizeType: $sizeType, path: $path)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileInfoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.sizeType, sizeType) ||
                other.sizeType == sizeType) &&
            (identical(other.path, path) || other.path == path));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, uuid, sizeType, path);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FileInfoImplCopyWith<_$FileInfoImpl> get copyWith =>
      __$$FileInfoImplCopyWithImpl<_$FileInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FileInfoImplToJson(
      this,
    );
  }
}

abstract class _FileInfo implements FileInfo {
  const factory _FileInfo(
      {required final String name,
      required final String uuid,
      required final String sizeType,
      required final String path}) = _$FileInfoImpl;

  factory _FileInfo.fromJson(Map<String, dynamic> json) =
      _$FileInfoImpl.fromJson;

  @override
  String get name;
  @override
  String get uuid;
  @override
  String get sizeType;
  @override
  String get path;
  @override
  @JsonKey(ignore: true)
  _$$FileInfoImplCopyWith<_$FileInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
