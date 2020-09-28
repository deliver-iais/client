import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/memberType.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/screen/app_profile/pages/media_details_page.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/group_Ui_widget.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/memberWidget.dart';
import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:deliver_flutter/shared/Widget/profileAvatar.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  Uid userUid;
  bool isOnline = true;

  ProfilePage(this.userUid, {Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notification = true;
  var _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  List<String> mediaUrls = [];
  var memberLength;

  var accountRepo = GetIt.I.get<AccountRepo>();

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
        body: DefaultTabController(
            length: 4,
            child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    ProfileAvatar(
                      innerBoxIsScrolled: innerBoxIsScrolled,
                      userUid: accountRepo.currentUserUid,
                      settingProfile: false,
                    ),
                    widget.userUid.category == Categories.User
                        ? SliverList(
                            delegate: SliverChildListDelegate([
                            Container(
                              height: 80,
                              // padding:
                              //const EdgeInsetsDirectional.only(start: 20, end: 15),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                // child:Padding(
                                //  padding: EdgeInsets.fromLTRB(20,20,0,0),
                                child: Wrap(
                                    direction: Axis.vertical,
                                    runSpacing: 40,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 0, 0),
                                        child: Text(
                                          appLocalization
                                              .getTraslateValue("info"),
                                          style: TextStyle(
                                            color: ExtraTheme.of(context)
                                                .blueOfProfilePage,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 0, 0),
                                        child: Text(
                                          appLocalization
                                              .getTraslateValue("Description"),
                                          style: TextStyle(
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      )
                                    ]),
                                // )
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ExtraTheme.of(context)
                                          .borderOfProfilePage),
                                  color: ExtraTheme.of(context)
                                      .backgroundOfProfilePage,
                                ),
                                height: 60,
                                padding: const EdgeInsetsDirectional.only(
                                    start: 5, end: 15),
                                child: Row(children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.message),
                                    onPressed: () {},
                                  ),
                                  /* Icon(
                  Icons.message,
                  size: 30,
                ),*/
                                  //  SizedBox(width: 10),
                                  Text(appLocalization
                                      .getTraslateValue("sendMessage")),
                                ])),
                            Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ExtraTheme.of(context)
                                          .borderOfProfilePage),
                                  color: ExtraTheme.of(context)
                                      .backgroundOfProfilePage,
                                ),
                                height: 60,
                                padding: const EdgeInsetsDirectional.only(
                                    start: 13, end: 15),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.notifications_active,
                                              size: 30,
                                            ),
                                            SizedBox(width: 10),
                                            Text(appLocalization
                                                .getTraslateValue(
                                                    "notification")),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        activeColor: ExtraTheme.of(context)
                                            .blueOfProfilePage,
                                        value: notification,
                                        onChanged: (newNotifState) {
                                          setState(() {
                                            notification = newNotifState;
                                          });
                                        },
                                      )
                                    ])),
                            Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ExtraTheme.of(context)
                                          .borderOfProfilePage),
                                  color: ExtraTheme.of(context)
                                      .backgroundOfProfilePage,
                                ),
                                height: 60,
                                padding: const EdgeInsetsDirectional.only(
                                    start: 7, end: 15),
                                child: Row(children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.phone),
                                    onPressed: () {},
                                  ),
                                  Text(appLocalization
                                      .getTraslateValue("phone")),
                                  kDebugMode
                                      ? IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: () {
                                            DateFormat dateFormat =
                                                DateFormat("yyyy-MM-dd HH:mm");
                                            DateTime sendTime = DateTime.now();
                                            String time =
                                                dateFormat.format(sendTime);
                                            _mediaQueryRepo.insertMediaQueryInfo(
                                                1,
                                                "https://picsum.photos/250?image=9",
                                                "parinaz",
                                                "laptop",
                                                "image",
                                                time,
                                                "p.asghari",
                                                "laptop");
                                            _mediaQueryRepo.insertMediaQueryInfo(
                                                2,
                                                "https://picsum.photos/seed/picsum/200/300",
                                                "parinaz",
                                                "sky",
                                                "image",
                                                time,
                                                "p.asghari",
                                                "skyy");
                                            _mediaQueryRepo.insertMediaQueryInfo(
                                                3,
                                                "https://picsum.photos/seed/picsum/200/300",
                                                "parinaz",
                                                "sky1",
                                                "image",
                                                time,
                                                "p.asghari",
                                                "skyy1");
                                            _mediaQueryRepo.insertMediaQueryInfo(
                                                14,
                                                "https://picsum.photos/seed/picsum/200/300",
                                                "parinaz",
                                                "sky1",
                                                "image",
                                                time,
                                                "p.asghari",
                                                "skyy1");
                                            _mediaQueryRepo.insertMediaQueryInfo(
                                                19,
                                                "https://picsum.photos/seed/picsum/200/300",
                                                "parinaz",
                                                "sky1",
                                                "image",
                                                time,
                                                "p.asghari",
                                                "skyy1");
                                          },
                                        )
                                      : SizedBox.shrink(),
                                ])),
                            SizedBox(
                              height: 40,
                            )
                          ]))
                        : GroupUiWidget(
                            mucUid: widget.userUid,
                          ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        maxHeight: 60,
                        minHeight: 60,
                        child: Container(
                          color: Theme.of(context).backgroundColor,
                          child: TabBar(
                            tabs: [
                              widget.userUid.category == Categories.User
                                  ? SizedBox.shrink()
                                  : Tab(
                                      text: appLocalization
                                          .getTraslateValue("members"),
                                    ),
                              Tab(
                                text: appLocalization.getTraslateValue("media"),
                              ),
                              Tab(
                                text: appLocalization.getTraslateValue("file"),
                              ),
                              Tab(
                                text: appLocalization.getTraslateValue("links"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: FutureBuilder<List<Media>>(
                  future: _mediaQueryRepo.getMediaQuery("p.asghari"),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Media>> snapshot) {
                    if (snapshot.hasData && snapshot.data.length != null) {
                      for (int i = 0; i < snapshot.data.length; i++) {
                        mediaUrls.add(snapshot.data[i].mediaUrl);
                      }
                      return Container(
                          child: TabBarView(children: [
                        widget.userUid.category == Categories.User? SizedBox.shrink():SingleChildScrollView(
                          child: Column(children: [
                            MucMemberWidget(
                              mucUid: widget.userUid,
                            ),
                          ]),
                        ),
                        GridView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: snapshot.data.length,
                            scrollDirection: Axis.vertical,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              //crossAxisSpacing: 2.0, mainAxisSpacing: 2.0,
                            ),
                            itemBuilder: (context, position) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return MediaDetailsPage(
                                      mediaUrl:
                                          snapshot.data[position].mediaUrl,
                                      mediaListLenght: snapshot.data.length,
                                      mediaPosition: position,
                                      heroTag: "btn$position",
                                      mediaList: mediaUrls,
                                      mediaSender:
                                          snapshot.data[position].mediaSender,
                                      mediaTime: snapshot.data[position].time,
                                    );
                                  }));
                                },
                                child: Hero(
                                    tag: "btn$position",
                                    child: Container(
                                      decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                            image: new NetworkImage(
                                              snapshot.data[position].mediaUrl,
                                              // imageList[position],
                                            ),
                                            fit: BoxFit.cover),
                                        border: Border.all(
                                          width: 1,
                                          color: ExtraTheme.of(context)
                                              .secondColor,
                                        ),
                                      ),
                                    )),
                              );
                            }),
                        ListView(
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            Text("File"),
                            Text("File"),
                            Text("File"),
                            Text("File"),
                            Text("File"),
                          ],
                        ),
                        ListView(),
                      ]));
                    } else {
                      return Text("...");
                    }
                  },
                ))));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight > minHeight ? maxHeight : minHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
