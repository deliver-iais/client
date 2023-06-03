// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'current_call_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CurrentCallInfo _$CurrentCallInfoFromJson(Map<String, dynamic> json) {
  return _CurrentCallInfo.fromJson(json);
}

/// @nodoc
mixin _$CurrentCallInfo {
  @CallEventV2JsonKey
  CallEventV2 get callEvent => throw _privateConstructorUsedError;
  String get from => throw _privateConstructorUsedError;
  String get to => throw _privateConstructorUsedError;
  int get expireTime => throw _privateConstructorUsedError;
  bool get notificationSelected => throw _privateConstructorUsedError;
  bool get isAccepted => throw _privateConstructorUsedError;
  String get offerBody => throw _privateConstructorUsedError;
  String get offerCandidate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CurrentCallInfoCopyWith<CurrentCallInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrentCallInfoCopyWith<$Res> {
  factory $CurrentCallInfoCopyWith(
          CurrentCallInfo value, $Res Function(CurrentCallInfo) then) =
      _$CurrentCallInfoCopyWithImpl<$Res, CurrentCallInfo>;
  @useResult
  $Res call(
      {@CallEventV2JsonKey CallEventV2 callEvent,
      String from,
      String to,
      int expireTime,
      bool notificationSelected,
      bool isAccepted,
      String offerBody,
      String offerCandidate});
}

/// @nodoc
class _$CurrentCallInfoCopyWithImpl<$Res, $Val extends CurrentCallInfo>
    implements $CurrentCallInfoCopyWith<$Res> {
  _$CurrentCallInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? callEvent = null,
    Object? from = null,
    Object? to = null,
    Object? expireTime = null,
    Object? notificationSelected = null,
    Object? isAccepted = null,
    Object? offerBody = null,
    Object? offerCandidate = null,
  }) {
    return _then(_value.copyWith(
      callEvent: null == callEvent
          ? _value.callEvent
          : callEvent // ignore: cast_nullable_to_non_nullable
              as CallEventV2,
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String,
      to: null == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as String,
      expireTime: null == expireTime
          ? _value.expireTime
          : expireTime // ignore: cast_nullable_to_non_nullable
              as int,
      notificationSelected: null == notificationSelected
          ? _value.notificationSelected
          : notificationSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isAccepted: null == isAccepted
          ? _value.isAccepted
          : isAccepted // ignore: cast_nullable_to_non_nullable
              as bool,
      offerBody: null == offerBody
          ? _value.offerBody
          : offerBody // ignore: cast_nullable_to_non_nullable
              as String,
      offerCandidate: null == offerCandidate
          ? _value.offerCandidate
          : offerCandidate // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CurrentCallInfoCopyWith<$Res>
    implements $CurrentCallInfoCopyWith<$Res> {
  factory _$$_CurrentCallInfoCopyWith(
          _$_CurrentCallInfo value, $Res Function(_$_CurrentCallInfo) then) =
      __$$_CurrentCallInfoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@CallEventV2JsonKey CallEventV2 callEvent,
      String from,
      String to,
      int expireTime,
      bool notificationSelected,
      bool isAccepted,
      String offerBody,
      String offerCandidate});
}

/// @nodoc
class __$$_CurrentCallInfoCopyWithImpl<$Res>
    extends _$CurrentCallInfoCopyWithImpl<$Res, _$_CurrentCallInfo>
    implements _$$_CurrentCallInfoCopyWith<$Res> {
  __$$_CurrentCallInfoCopyWithImpl(
      _$_CurrentCallInfo _value, $Res Function(_$_CurrentCallInfo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? callEvent = null,
    Object? from = null,
    Object? to = null,
    Object? expireTime = null,
    Object? notificationSelected = null,
    Object? isAccepted = null,
    Object? offerBody = null,
    Object? offerCandidate = null,
  }) {
    return _then(_$_CurrentCallInfo(
      callEvent: null == callEvent
          ? _value.callEvent
          : callEvent // ignore: cast_nullable_to_non_nullable
              as CallEventV2,
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String,
      to: null == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as String,
      expireTime: null == expireTime
          ? _value.expireTime
          : expireTime // ignore: cast_nullable_to_non_nullable
              as int,
      notificationSelected: null == notificationSelected
          ? _value.notificationSelected
          : notificationSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isAccepted: null == isAccepted
          ? _value.isAccepted
          : isAccepted // ignore: cast_nullable_to_non_nullable
              as bool,
      offerBody: null == offerBody
          ? _value.offerBody
          : offerBody // ignore: cast_nullable_to_non_nullable
              as String,
      offerCandidate: null == offerCandidate
          ? _value.offerCandidate
          : offerCandidate // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CurrentCallInfo implements _CurrentCallInfo {
  const _$_CurrentCallInfo(
      {@CallEventV2JsonKey required this.callEvent,
      required this.from,
      required this.to,
      required this.expireTime,
      required this.notificationSelected,
      required this.isAccepted,
      this.offerBody = "",
      this.offerCandidate = ""});

  factory _$_CurrentCallInfo.fromJson(Map<String, dynamic> json) =>
      _$$_CurrentCallInfoFromJson(json);

  @override
  @CallEventV2JsonKey
  final CallEventV2 callEvent;
  @override
  final String from;
  @override
  final String to;
  @override
  final int expireTime;
  @override
  final bool notificationSelected;
  @override
  final bool isAccepted;
  @override
  @JsonKey()
  final String offerBody;
  @override
  @JsonKey()
  final String offerCandidate;

  @override
  String toString() {
    return 'CurrentCallInfo(callEvent: $callEvent, from: $from, to: $to, expireTime: $expireTime, notificationSelected: $notificationSelected, isAccepted: $isAccepted, offerBody: $offerBody, offerCandidate: $offerCandidate)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CurrentCallInfo &&
            (identical(other.callEvent, callEvent) ||
                other.callEvent == callEvent) &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            (identical(other.expireTime, expireTime) ||
                other.expireTime == expireTime) &&
            (identical(other.notificationSelected, notificationSelected) ||
                other.notificationSelected == notificationSelected) &&
            (identical(other.isAccepted, isAccepted) ||
                other.isAccepted == isAccepted) &&
            (identical(other.offerBody, offerBody) ||
                other.offerBody == offerBody) &&
            (identical(other.offerCandidate, offerCandidate) ||
                other.offerCandidate == offerCandidate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, callEvent, from, to, expireTime,
      notificationSelected, isAccepted, offerBody, offerCandidate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CurrentCallInfoCopyWith<_$_CurrentCallInfo> get copyWith =>
      __$$_CurrentCallInfoCopyWithImpl<_$_CurrentCallInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CurrentCallInfoToJson(
      this,
    );
  }
}

abstract class _CurrentCallInfo implements CurrentCallInfo {
  const factory _CurrentCallInfo(
      {@CallEventV2JsonKey required final CallEventV2 callEvent,
      required final String from,
      required final String to,
      required final int expireTime,
      required final bool notificationSelected,
      required final bool isAccepted,
      final String offerBody,
      final String offerCandidate}) = _$_CurrentCallInfo;

  factory _CurrentCallInfo.fromJson(Map<String, dynamic> json) =
      _$_CurrentCallInfo.fromJson;

  @override
  @CallEventV2JsonKey
  CallEventV2 get callEvent;
  @override
  String get from;
  @override
  String get to;
  @override
  int get expireTime;
  @override
  bool get notificationSelected;
  @override
  bool get isAccepted;
  @override
  String get offerBody;
  @override
  String get offerCandidate;
  @override
  @JsonKey(ignore: true)
  _$$_CurrentCallInfoCopyWith<_$_CurrentCallInfo> get copyWith =>
      throw _privateConstructorUsedError;
}
