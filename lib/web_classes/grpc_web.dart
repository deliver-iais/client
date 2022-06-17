import 'package:grpc/grpc_connection_interface.dart';

class GrpcWebClientChannel extends ClientChannelBase {
  final Uri uri;

  GrpcWebClientChannel.xhr(this.uri);

  @override
  ClientConnection createConnection() {
    throw UnimplementedError();
  }
}
