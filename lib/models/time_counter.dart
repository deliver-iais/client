import 'package:json_annotation/json_annotation.dart';

part 'time_counter.g.dart';

@JsonSerializable()
class TimeCounter {
  int count;
  int time;

  TimeCounter({required this.count, required this.time});

  @override
  String toString() {
    return "TimeCounter([count:$count],[time:$time])";
  }
}

const TimeCounterFromJson = _$TimeCounterFromJson;
const TimeCounterToJson = _$TimeCounterToJson;
