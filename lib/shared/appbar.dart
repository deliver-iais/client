import 'package:auto_route/auto_route.dart';
import '../routes/router.gr.dart';
import 'appbarTitle.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:deliver_flutter/shared/appbarPic.dart';
import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Appbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AppBar(
        leading: currentPageService.currentPage == -1
            ? new IconButton(
                icon: new Icon(Icons.arrow_back),
                onPressed: () {
                  currentPageService.setToHome();
                  ExtendedNavigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.homePage, (_) => false);
                },
              )
            : null,
        backgroundColor: Theme.of(context).backgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                AppbarPic(),
                SizedBox(
                  width: 10,
                ),
                AppbarTitle(),
              ],
            ),
            Container(
              child: IconButton(
                icon: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeColors.secondColor,
                  ),
                  child: Icon(
                    currentPageService.currentPage == -1
                        ? Icons.settings
                        : currentPageService.currentPage == 0
                            ? Icons.create
                            : Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: null,
              ),
            )
          ],
        ),
      ),
    );
  }
}
