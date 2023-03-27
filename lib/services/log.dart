import 'dart:io';

import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:logger/logger.dart';

// ignore: implementation_imports
import 'package:logger/src/outputs/file_output.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DeliverLogFilter extends LogFilter {
  DeliverLogFilter() {
    settings.logLevel.stream.listen((level) {
      this.level = level;
    });
  }

  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= (level ?? Level.nothing).index;
  }
}

class DeliverLogOutput extends LogOutput {
  final consoleOutput = ConsoleOutput();

  late final FileOutput? fileOutput;

  Future<String> getLogFilePath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return join(appDir.path, APPLICATION_FOLDER_NAME, "log.txt");
  }

  @override
  Future<void> init() async {
    if (!isWeb) {
      fileOutput = FileOutput(file: File(await getLogFilePath()));
      fileOutput?.init();
      consoleOutput.init();
    }
  }

  @override
  void output(OutputEvent event) {
    consoleOutput.output(event);
    if (settings.logInFileEnable.value) fileOutput?.output(event);
  }

  @override
  void destroy() {
    consoleOutput.destroy();
    fileOutput?.destroy();
  }
}
