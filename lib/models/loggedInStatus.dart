enum LoggedInStatus {
  loggedIn,
  waitForVerify,
  noLoggedIn,
  unknown,
}

String enumToString(Object o) => o.toString().split('.').last;

LoggedInStatus enumFromString(String key) =>
    LoggedInStatus.values.firstWhere((v) => key == enumToString(v),
        orElse: () => LoggedInStatus.noLoggedIn);
