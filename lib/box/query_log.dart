import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'query_log.g.dart';

@HiveType(typeId: QUERY_LOG_TRACK_ID)

class QueryLog {
  // DbId
  @HiveField(0)
  String address;

  @HiveField(1)
  int count = 0;


  QueryLog({required this.address, required this.count});
}