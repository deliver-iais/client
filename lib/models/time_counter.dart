class TimeCounter {
  int count;
  int time;

  TimeCounter.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        time = json['time'];

  Map<String, dynamic> toJson() => {
        'count': count,
        'time': time,
      };

  TimeCounter({required this.count, required this.time});

  @override
  String toString() {
    return "TimeCounter([count:$count],[time:$time])";
  }
}
