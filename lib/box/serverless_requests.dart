import 'package:deliver/shared/constants.dart';
import 'package:hive_flutter/adapters.dart';

part 'serverless_requests.g.dart';

@HiveType(typeId: SERVERLESS_REQUEST_TRACK_ID)
class ServerLessRequest{

  @HiveField(0)
  String uid;

  @HiveField(1)
  String info;

  @HiveField(2)
  int time;

  ServerLessRequest({required this.uid, required this.info, required this.time});

}