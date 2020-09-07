import 'package:carousel_slider/carousel_slider.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/shared/Widget/profileAvatar.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProfilePage extends StatefulWidget {

  Uid userUid;
  ProfilePage(this.userUid);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notification = true;
  var accountRepo = GetIt.I.get<AccountRepo>();

  List<String> imageList = [
    "https://picsum.photos/250?image=9",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/200/300?grayscale",
    "https://picsum.photos/250?image=9",
  ];

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
                    userUid:accountRepo.currentUserUid ,
                    settingProfile: false,
                  ),
                  SliverList(
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
                                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Text(
                                  appLocalization.getTraslateValue("info"),
                                  style: TextStyle(
                                    color: ExtraTheme.of(context)
                                        .blueOfProfilePage,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Text(
                                  "No Description",
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
                              color:
                                  ExtraTheme.of(context).borderOfProfilePage),
                          color: ExtraTheme.of(context).backgroundOfProfilePage,
                        ),
                        height: 60,
                        padding:
                            const EdgeInsetsDirectional.only(start: 5, end: 15),
                        child: Row(
                          children: <Widget>[
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
                          ],
                        )),
                    Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  ExtraTheme.of(context).borderOfProfilePage),
                          color: ExtraTheme.of(context).backgroundOfProfilePage,
                        ),
                        height: 60,
                        padding: const EdgeInsetsDirectional.only(
                            start: 13, end: 15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        .getTraslateValue("notification")),
                                  ],
                                ),
                              ),
                              Switch(
                                activeColor:
                                    ExtraTheme.of(context).blueOfProfilePage,
                                value: notification,
                                onChanged: (newNotifState) {
                                  setState(() {
                                    notification = newNotifState;
                                  });
                                },
                              )
                              /*IconButton(
                   icon: Icon(Icons.notifications_active),
                   onPressed: () {
                   },
                 ),*/
                            ])),
                    Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  ExtraTheme.of(context).borderOfProfilePage),
                          color: ExtraTheme.of(context).backgroundOfProfilePage,
                        ),
                        height: 60,
                        padding:
                            const EdgeInsetsDirectional.only(start: 7, end: 15),
                        child: Row(children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.phone),
                            onPressed: () {},
                          ),
                          /*Icon(
                        Icons.phone,
                        size: 30,
                      ),*/
                          //SizedBox(width:10),
                          Text(appLocalization.getTraslateValue("phone")),
                        ])),
                    SizedBox(
                      height: 40,
                    )
                  ])),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      maxHeight: 60,
                      minHeight: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  ExtraTheme.of(context).borderOfProfilePage),
                          color: ExtraTheme.of(context).backgroundOfProfilePage,
                        ),
                        // constraints: BoxConstraints(maxHeight: 300.0),
                        child: TabBar(
                          indicatorColor:
                              ExtraTheme.of(context).blueOfProfilePage,
                          labelColor: ExtraTheme.of(context).blueOfProfilePage,
                          unselectedLabelColor:
                              ExtraTheme.of(context).tabsColor,
                          tabs: [
                            Tab(
                              text: appLocalization.getTraslateValue("media"),
                            ),
                            Tab(
                              text: appLocalization.getTraslateValue("file"),
                            ),
                            Tab(
                              text: appLocalization.getTraslateValue("links"),
                            ),
                            Tab(
                              text: appLocalization.getTraslateValue("groups"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Container(
                  child: TabBarView(children: [
                GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: imageList.length,
                    //scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      //crossAxisSpacing: 2.0, mainAxisSpacing: 2.0,
                    ),
                    itemBuilder: (context, position) {
                      return Container(
                        decoration: new BoxDecoration(
                          image: new DecorationImage(
                              image: new NetworkImage(
                                imageList[position],
                              ),
                              fit: BoxFit.cover),
                          border: Border.all(
                            width: 1,
                            color: ExtraTheme.of(context).tabsColor,
                          ),
                        ),
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
                ListView(),
              ])),
            )));
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
