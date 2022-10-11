import 'dart:io';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// ignore: implementation_imports
import 'package:logger/src/outputs/file_output.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DeliverLogFilter extends LogFilter {
  DeliverLogFilter() {
    GetIt.I
        .get<SharedDao>()
        .getStream(
          SHARED_DAO_LOG_LEVEL,
          defaultValue: defaultLevel(),
        )
        .listen((level) => setLevel(level));
  }

  static String defaultLevel() => kDebugMode ? "INFO" : "NOTHING";

  void setLevel(String? logLevel) {
    level = LogLevelHelper.stringToLevel(logLevel ?? defaultLevel());
  }

  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= (level ?? Level.nothing).index;
  }
}

class DeliverLogOutput extends LogOutput {
  final consoleOutput = ConsoleOutput();

  late final FileOutput? fileOutput;

  bool saveInFileIsEnabled = false;

  DeliverLogOutput() {
    GetIt.I
        .get<SharedDao>()
        .getBooleanStream(SHARED_DAO_LOG_IN_FILE_ENABLE)
        .listen((sif) => saveInFileIsEnabled = sif);
  }

  @override
  Future<void> init() async {
    if (!isWeb) {
      final appDir = await getApplicationDocumentsDirectory();
      fileOutput = FileOutput(
        file: File(join(appDir.path, APPLICATION_FOLDER_NAME, "log.txt")),
      );
      fileOutput?.init();
      consoleOutput.init();
    }
  }

  @override
  void output(OutputEvent event) {
    consoleOutput.output(event);
    if (saveInFileIsEnabled) fileOutput?.output(event);
  }

  @override
  void destroy() {
    consoleOutput.destroy();
    fileOutput?.destroy();
  }
}

class LogLevelHelper {
  static String levelToString(Level level) {
    switch (level) {
      case Level.debug:
        return "DEBUG";
      case Level.verbose:
        return "VERBOSE";
      case Level.error:
        return "ERROR";
      case Level.info:
        return "INFO";
      case Level.warning:
        return "WARNING";
      case Level.wtf:
        return "WTF";
      case Level.nothing:
        return "NOTHING";
    }
  }

  static Level stringToLevel(String level) {
    switch (level) {
      case "DEBUG":
        return Level.debug;
      case "VERBOSE":
        return Level.verbose;
      case "ERROR":
        return Level.error;
      case "INFO":
        return Level.info;
      case "WARNING":
        return Level.warning;
      case "WTF":
        return Level.wtf;
      case "NOTHING":
        return Level.nothing;
      default:
        return Level.debug;
    }
  }

  static List<String> levels() =>
      ["DEBUG", "VERBOSE", "ERROR", "INFO", "WARNING", "WTF", "NOTHING"];
}
