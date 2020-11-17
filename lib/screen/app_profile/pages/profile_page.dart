import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/mediaType.dart';
//import 'package:deliver_flutter/models/memberType.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app_profile/pages/media_details_page.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/group_Ui_widget.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/memberWidget.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:deliver_flutter/shared/Widget/profileAvatar.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/user.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class ProfilePage extends StatefulWidget {
  Uid userUid;

  ProfilePage(this.userUid, {Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  List<String> _mediaUrls = [];
  List<String> mediaUrls = [];
 var mediasLength;
  Room currentRoomId;
  List<Media> _fetchedMedia;

  var _routingService = GetIt.I.get<RoutingService>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _contactRepo = GetIt.I.get<ContactRepo>();
  var _fileRepo = GetIt.I.get<FileRepo>();

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
        body: DefaultTabController(
            length: widget.userUid.category == Categories.USER ? 3 : 4,
            child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                        ProfileAvatar(
                      innerBoxIsScrolled: innerBoxIsScrolled,
                      roomUid: widget.userUid,
                      ),
                    widget.userUid.category == Categories.USER
                        ? SliverList(
                            delegate: SliverChildListDelegate([
                            Container(
                              height: 80,
                              child: Align(
                                alignment: Alignment.centerLeft,
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
                                      FutureBuilder<Contact>(
                                        future: _contactRepo
                                            .getContact(widget.userUid),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<Contact> snapshot) {
                                          if (snapshot.data != null) {
                                            return _showUsername(
                                                snapshot.data.username);
                                          } else {
                                            return FutureBuilder<UserAsContact>(
                                              future:
                                                  _contactRepo.searchUserByUid(
                                                      widget.userUid),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<UserAsContact>
                                                      snapshot) {
                                                if (snapshot.data != null) {
                                                  return _showUsername(
                                                      snapshot.data.username);
                                                } else {
                                                  return SizedBox.shrink();
                                                }
                                              },
                                            );
                                          }
                                        },
                                      ),
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
                                child: GestureDetector(
                                  child: Row(children: <Widget>[
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Icon(Icons.message),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    //  SizedBox(width: 10),
                                    Text(appLocalization
                                        .getTraslateValue("sendMessage")),
                                  ]),
                                  onTap: () {
                                    _routingService
                                        .openRoom(widget.userUid.string);
                                  },
                                )),
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
                                      StreamBuilder<Room>(
                                        stream: _roomDao
                                            .getByRoomId(widget.userUid.string),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<Room> snapshot) {
                                          if (snapshot.data != null) {
                                            return Switch(
                                              activeColor:
                                                  ExtraTheme.of(context)
                                                      .blueOfProfilePage,
                                              value: !snapshot.data.mute,
                                              onChanged: (newNotifState) {
                                                setState(() {
                                                  _roomDao.insertRoom(Room(
                                                      roomId:
                                                          widget.userUid.string,
                                                      mute: !newNotifState));
                                                });
                                              },
                                            );
                                          } else {
                                            return SizedBox.shrink();
                                          }
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
                                child: FutureBuilder<Contact>(
                                  future:
                                      _contactRepo.getContact(widget.userUid),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<Contact> snapshot) {
                                    if (snapshot.data != null) {
                                      return Stack(children: <Widget>[
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.phone),
                                              onPressed: () {},
                                            ),
                                            Text(appLocalization
                                                .getTraslateValue("phone")),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(snapshot.data.phoneNumber),
                                            ],
                                          ),
                                        ),
                                        // kDebugMode
                                        //     ? IconButton(
                                        //         icon: Icon(Icons.add),
                                        //         onPressed: () {
                                        //           DateFormat dateFormat =
                                        //               DateFormat(
                                        //                   "yyyy-MM-dd HH:mm");
                                        //           DateTime sendTime =
                                        //               DateTime.now();
                                        //           String time = dateFormat
                                        //               .format(sendTime);
                                        //           _mediaQueryRepo
                                        //               .insertMediaQueryInfo(
                                        //                   1,
                                        //                   "https://picsum.photos/250?image=9",
                                        //                   "parinaz",
                                        //                   "laptop",
                                        //                   "image",
                                        //                   time,
                                        //                   "p.asghari",
                                        //                   "laptop");
                                        //           _mediaQueryRepo
                                        //               .insertMediaQueryInfo(
                                        //                   2,
                                        //                   "https://picsum.photos/seed/picsum/200/300",
                                        //                   "parinaz",
                                        //                   "sky",
                                        //                   "image",
                                        //                   time,
                                        //                   "p.asghari",
                                        //                   "skyy");
                                        //           _mediaQueryRepo
                                        //               .insertMediaQueryInfo(
                                        //                   3,
                                        //                   "https://picsum.photos/seed/picsum/200/300",
                                        //                   "parinaz",
                                        //                   "sky1",
                                        //                   "image",
                                        //                   time,
                                        //                   "p.asghari",
                                        //                   "skyy1");
                                        //           _mediaQueryRepo
                                        //               .insertMediaQueryInfo(
                                        //                   14,
                                        //                   "https://picsum.photos/seed/picsum/200/300",
                                        //                   "parinaz",
                                        //                   "sky1",
                                        //                   "image",
                                        //                   time,
                                        //                   "p.asghari",
                                        //                   "skyy1");
                                        //           _mediaQueryRepo
                                        //               .insertMediaQueryInfo(
                                        //                   19,
                                        //                   "https://picsum.photos/seed/picsum/200/300",
                                        //                   "parinaz",
                                        //                   "sky1",
                                        //                   "image",
                                        //                   time,
                                        //                   "p.asghari",
                                        //                   "skyy1");
                                        //         },
                                        //       )
                                           // : SizedBox.shrink(),
                                      ]);
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                  },
                                )),
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
                                if (widget.userUid.category != Categories.USER)
                                  Tab(
                                    text: appLocalization
                                        .getTraslateValue("members"),
                                  ),
                                Tab(
                                  text:
                                      appLocalization.getTraslateValue("media"),
                                ),
                                Tab(
                                  text:
                                      appLocalization.getTraslateValue("file"),
                                ),
                                Tab(
                                  text:
                                      appLocalization.getTraslateValue("links"),
                                ),
                              ],
                            )),
                      ),
                    ),
                  ];
                },
                body:
                       Container(
                          child: TabBarView(children: [
                            if (widget.userUid.category != Categories.USER)
                              SingleChildScrollView(
                                child: Column(children: [
                                  MucMemberWidget(
                                    mucUid: widget.userUid,
                                  ),
                                ]),
                              ),
                            mediaWidget(widget.userUid,_mediaQueryRepo,_fileRepo),
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
                            linkWidget(widget.userUid,_mediaQueryRepo),
                          ])))));
                    }
  }



  Widget mediaWidget(Uid userUid ,MediaQueryRepo mediaQueryRepo ,FileRepo fileRepo) {
    return FutureBuilder<List<Media>>(
        future:  mediaQueryRepo.getMedias(userUid.string, DateTime.now().microsecondsSinceEpoch,2020, FetchMediasReq_MediaType.IMAGES, 50),
    builder: (BuildContext context,
    AsyncSnapshot<List<Media>> snapshot) {
    if (snapshot.hasData && snapshot.data.length != null) {
    //_fetchedMedia = snapshot.data;
     return GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: snapshot.data.length,
        scrollDirection: Axis.vertical,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          //crossAxisSpacing: 2.0, mainAxisSpacing: 2.0,
        ),
        itemBuilder: (context, position) {

          var fileId = jsonDecode(snapshot.data[position].json)["uuid"];
          var fileName = jsonDecode(snapshot.data[position].json)["name"];
          return FutureBuilder(
            future: fileRepo.getFile(fileId, fileName),
            builder:
            (BuildContext c, AsyncSnapshot snaps) {
              if (snaps.hasData &&
                 snaps.data != null &&
                     snaps.connectionState ==
                   ConnectionState.done) {
               return Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: Image.file(
                        snaps.data,
                      ).image,
                      fit: BoxFit.cover,
                    ),
                      border: Border.all(
                        width: 1,
                        color: ExtraTheme.of(context).secondColor,
                  ),
                ));
              }
            }
            // child: GestureDetector(
            //   // onTap: () {
            //   //   _routingService.openShowAllMedia(
            //   //     mediaPosition: position,
            //   //     heroTag: "btn$position",
            //   //     mediasLength: medias.length,
            //   //   );
            //   // },
            //  child: Hero(
            //       tag: "btn$position",
            //       child: Container(
            //         decoration: new BoxDecoration(
            //           image: new DecorationImage(
            //               // image: new NetworkImage(
            //               //   medias[position].mediaUrl,
            //               //    //imageList[position],
            //               // ),
            //               fit: BoxFit.cover),
            //           border: Border.all(
            //             width: 1,
            //             color: ExtraTheme.of(context).secondColor,
            //           ),
            //         ),
            //       ), // transitionOnUserGestures: true,
            //
            //   ),
            // ),
          );
        });}
    else {
      return Text("...");
    }
        });
  }

  Widget linkWidget(Uid userUid , MediaQueryRepo mediaQueryRepo){
   return FutureBuilder<List<Media>>(
        future:  mediaQueryRepo.getMedias(userUid.string, DateTime.now().microsecondsSinceEpoch,2020, FetchMediasReq_MediaType.LINKS, 50),
    builder: (BuildContext context,
    AsyncSnapshot<List<Media>> snapshot) {
    if (snapshot.hasData && snapshot.data.length != null) {
      return ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Text("File"),
          Text("File"),
          Text("File"),
          Text("File"),
          Text("File"),
        ],
      );
    }
    });

  }

  Widget _showUsername(String username) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
      child: Text(
        username!=null?"@$username":'',
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.blue
        ),
      ),
    );
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
