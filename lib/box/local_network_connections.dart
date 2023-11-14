import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_network_connections.freezed.dart';

part 'local_network_connections.g.dart';

@freezed
class LocalNetworkConnections with _$LocalNetworkConnections {
  const factory LocalNetworkConnections({
    @UidJsonKey required Uid uid,
    required String ip,
    required int lastUpdateTime,
  }) = _LocalNetworkConnections;

  factory LocalNetworkConnections.fromJson(Map<String, Object?> json) =>
      _$LocalNetworkConnectionsFromJson(json);
}
