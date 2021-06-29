import 'package:flutter/foundation.dart';

const TraceIsEnabled = false;

void debug(Object object) {
  if (kDebugMode) print(object);
}

void trace(Object object) {
  if (kDebugMode && TraceIsEnabled) print(object);
}
