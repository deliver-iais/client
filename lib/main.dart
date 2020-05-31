import 'package:deliver_flutter/services/ux_service.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import './screen/app-intro/pages/intro.dart';

void setupDI() {
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<UxService>(UxService());
}

void main() {
  setupDI();

  runApp(MyApp());

  Fimber.plantTree(DebugTree.elapsed());
  Fimber.i("Application has been started");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var uxService = GetIt.I.get<UxService>();
    return StreamBuilder(
        stream: uxService.themeStream,
        builder: (context, snapshot) {
          Fimber.d("theme changed ${uxService.theme.toString()}");
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: uxService.theme,
            home: IntroPage(key: Key(uxService.theme.toString())),
          );
        });
  }
}
