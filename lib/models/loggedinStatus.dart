enum LoggedinStatus {
  loggedin,
  waitForVerify,
  noLoggeding,
  unknow,
}

String enumToString(Object o) => o.toString().split('.').last;

LoggedinStatus enumFromString(String key) =>
    LoggedinStatus.values.firstWhere((v) => key == enumToString(v),
        orElse: () => LoggedinStatus.noLoggeding);
