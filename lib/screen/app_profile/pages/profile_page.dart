import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/document_and_File_ui.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/group_Ui_widget.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/image_tab_ui.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/memberWidget.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/music_and_audio_ui.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/video_tab_ui.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/Widget/profileAvatar.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/user.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  final Uid userUid;

  ProfilePage(this.userUid, {Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  var mediasLength;
  Room currentRoomId;
  var _routingService = GetIt.I.get<RoutingService>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _contactRepo = GetIt.I.get<ContactRepo>();
  var _uxService = GetIt.I.get<UxService>();
  var _roomRepo = GetIt.I.get<RoomRepo>();
  TabController _tabController;
  int tabsCount;

  @override
  void initState() {
    _mediaQueryRepo.getMediaMetaDataReq(widget.userUid);
    if (_uxService.getTabIndex(widget.userUid.asString()) == null) {
      _uxService.setTabIndex(widget.userUid.asString(), 0);
    }
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _uxService.setTabIndex(widget.userUid.asString(), 0);
    super.dispose();
  }

  download(String uuid, String name) async {
    await GetIt.I.get<FileRepo>().getFile(uuid, name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);

    return StreamBuilder<MediasMetaDataData>(
        stream: _mediaQueryRepo.getMediasMetaDataCountFromDB(widget.userUid),
        builder: (context, AsyncSnapshot<MediasMetaDataData> snapshot) {
          tabsCount = 0;
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data.imagesCount != 0) {
              tabsCount = tabsCount + 1;
            }
            if (snapshot.data.videosCount != 0) {
              tabsCount = tabsCount + 1;
            }
            if (snapshot.data.linkCount != 0) {
              tabsCount = tabsCount + 1;
            }
            if (snapshot.data.filesCount != 0) {
              tabsCount = tabsCount + 1;
            }
            if (snapshot.data.documentsCount != 0) {
              tabsCount = tabsCount + 1;
            }
            if (snapshot.data.musicsCount != 0) {
              tabsCount = tabsCount + 1;
            }
            if (snapshot.data.audiosCount != 0) {
              tabsCount = tabsCount + 1;
            }

          }

          _tabController = TabController(
              length: (widget.userUid.category == Categories.GROUP ||
                  widget.userUid.category == Categories.CHANNEL)
                  ? tabsCount + 1
                  : tabsCount,
              vsync: this,
              initialIndex:
              _uxService.getTabIndex(widget.userUid.asString()));
          _tabController.addListener(() {
            _uxService.setTabIndex(
                widget.userUid.asString(), _tabController.index);
          });

          return Scaffold(
              body: DefaultTabController(
                  length: (widget.userUid.category == Categories.USER ||
                          widget.userUid.category == Categories.SYSTEM ||
                          widget.userUid.category == Categories.BOT)
                      ? tabsCount
                      : tabsCount + 1,
                  child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          ProfileAvatar(
                            innerBoxIsScrolled: innerBoxIsScrolled,
                            roomUid: widget.userUid,
                          ),
                          widget.userUid.category == Categories.USER ||
                                  widget.userUid.category == Categories.SYSTEM
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
                                              padding: EdgeInsets.fromLTRB(
                                                  20, 0, 0, 0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    appLocalization
                                                        .getTraslateValue(
                                                            "info"),
                                                    style: TextStyle(
                                                      color: ExtraTheme.of(
                                                              context)
                                                          .blueOfProfilePage,
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            widget.userUid.category ==
                                                    Categories.SYSTEM
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 25),
                                                    child: Text(
                                                      "@ Deliver",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ))
                                                : FutureBuilder<String>(
                                                    future:
                                                        _roomRepo.getUsername(
                                                            widget.userUid),
                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<String>
                                                            snapshot) {
                                                      if (snapshot.data !=
                                                          null) {
                                                        return _showUsername(
                                                            snapshot.data,
                                                            widget.userUid);
                                                      } else {
                                                        return SizedBox
                                                            .shrink();
                                                      }
                                                    },
                                                  ),
                                          ]),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  if (widget.userUid.category !=
                                      Categories.SYSTEM)
                                    Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: ExtraTheme.of(context)
                                                  .borderOfProfilePage),
                                          color: ExtraTheme.of(context)
                                              .backgroundOfProfilePage,
                                        ),
                                        height: 60,
                                        padding:
                                            const EdgeInsetsDirectional.only(
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
                                            Text(appLocalization
                                                .getTraslateValue(
                                                    "sendMessage")),
                                          ]),
                                          onTap: () {
                                            _routingService.openRoom(
                                                widget.userUid.asString());
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
                                              stream: _roomDao.getByRoomId(
                                                  widget.userUid.asString()),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<Room>
                                                      snapshot) {
                                                if (snapshot.data != null) {
                                                  return Switch(
                                                    activeColor:
                                                        ExtraTheme.of(context)
                                                            .blueOfProfilePage,
                                                    value: !snapshot.data.mute,
                                                    onChanged: (newNotifState) {
                                                      setState(() {
                                                        _roomDao.insertRoom(Room(
                                                            roomId: widget
                                                                .userUid
                                                                .asString(),
                                                            mute:
                                                                !newNotifState));
                                                      });
                                                    },
                                                  );
                                                } else {
                                                  return SizedBox.shrink();
                                                }
                                              },
                                            )
                                          ])),
                                  if (widget.userUid.category !=
                                      Categories.SYSTEM)
                                    Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: ExtraTheme.of(context)
                                                  .borderOfProfilePage),
                                          color: ExtraTheme.of(context)
                                              .backgroundOfProfilePage,
                                        ),
                                        height: 60,
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 7, end: 15),
                                        child: FutureBuilder<Contact>(
                                          future: _contactRepo
                                              .getContact(widget.userUid),
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
                                                        .getTraslateValue(
                                                            "phone")),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 20),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      ParsedText(
                                                        textDirection:
                                                            TextDirection.ltr,
                                                        text:
                                                            "0${snapshot.data.phoneNumber}",
                                                        parse: <MatchText>[
                                                          MatchText(
                                                            type: ParsedType
                                                                .PHONE,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontSize: 16,
                                                            ),
                                                            onTap:
                                                                (phone) async {
                                                              await launch(
                                                                  "tel:$phone");
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
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
                                    onTap: (index) {
                                      _uxService.setTabIndex(
                                          widget.userUid.asString(), index);
                                    },
                                    tabs: [
                                      if (widget.userUid.category ==
                                              Categories.GROUP ||
                                          widget.userUid.category ==
                                              Categories.CHANNEL)
                                        Tab(
                                          text: appLocalization
                                              .getTraslateValue("members"),
                                        ),

                                      if (snapshot.hasData &&
                                          snapshot.data.imagesCount != 0)
                                        Tab(
                                          text: appLocalization
                                              .getTraslateValue("images"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.videosCount != 0)
                                        Tab(
                                          text: appLocalization
                                              .getTraslateValue("videos"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.filesCount != 0)
                                        Tab(
                                          text: appLocalization
                                              .getTraslateValue("file"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.linkCount != 0)
                                        Tab(
                                            text: appLocalization
                                                .getTraslateValue("links")),
                                      if (snapshot.hasData &&
                                          snapshot.data.documentsCount != 0)
                                        Tab(
                                            text: appLocalization
                                                .getTraslateValue("documents")),
                                      if (snapshot.hasData &&
                                          snapshot.data.musicsCount != 0)
                                        Tab(
                                            text: appLocalization
                                                .getTraslateValue("musics")),
                                      if (snapshot.hasData &&
                                          snapshot.data.audiosCount != 0)
                                        Tab(
                                            text: appLocalization
                                                .getTraslateValue("audios")),
                                    ],
                                    controller: _tabController,
                                  ),
                                )),
                          ),
                        ];
                      },
                      body: Container(
                          child: TabBarView(
                        children: [
                          if (widget.userUid.category != Categories.USER &&
                              widget.userUid.category != Categories.SYSTEM)
                            SingleChildScrollView(
                              child: Column(children: [
                                MucMemberWidget(
                                  mucUid: widget.userUid,
                                ),
                              ]),
                            ),
                          if (snapshot.hasData &&
                              snapshot.data.imagesCount != 0)
                            ImageUi(snapshot.data.imagesCount, widget.userUid),
                          if (snapshot.hasData &&
                              snapshot.data.videosCount != 0)
                            VideoTabUi(
                                userUid: widget.userUid,
                                videoCount: snapshot.data.videosCount),
                          if (snapshot.hasData && snapshot.data.filesCount != 0)
                            DocumentAndFileUi(
                              userUid: widget.userUid,
                              documentCount: snapshot.data.filesCount,
                              type: FetchMediasReq_MediaType.FILES,
                            ),
                          if (snapshot.hasData && snapshot.data.linkCount != 0)
                            linkWidget(widget.userUid, _mediaQueryRepo,
                                snapshot.data.linkCount),
                          if (snapshot.hasData &&
                              snapshot.data.documentsCount != 0)
                            DocumentAndFileUi(
                              userUid: widget.userUid,
                              documentCount: snapshot.data.documentsCount,
                              type: FetchMediasReq_MediaType.DOCUMENTS,
                            ),
                          if (snapshot.hasData &&
                              snapshot.data.musicsCount != 0)
                            MusicAndAudioUi(
                                userUid: widget.userUid,
                                type: FetchMediasReq_MediaType.MUSICS,
                                mediaCount: snapshot.data.musicsCount),
                          if (snapshot.hasData &&
                              snapshot.data.audiosCount != 0)
                            MusicAndAudioUi(
                                userUid: widget.userUid,
                                type: FetchMediasReq_MediaType.AUDIOS,
                                mediaCount: snapshot.data.audiosCount),
                        ],
                        controller: _tabController,
                      )))));
        });
  }
}

Widget linkWidget(Uid userUid, MediaQueryRepo mediaQueryRepo, int linksCount) {
  //TODO i just implemented and not tested because server problem
  return FutureBuilder<List<Media>>(
      future: mediaQueryRepo.getMedia(
          userUid, FetchMediasReq_MediaType.LINKS, linksCount),
      builder: (BuildContext context, AsyncSnapshot<List<Media>> snapshot) {
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          return Container(width: 0.0, height: 0.0);
        } else {
          return ListView.builder(
            itemCount: linksCount,
            itemBuilder: (BuildContext ctx, int index) {
              return Column(
                children: [
                  ListTile(
                    title: FlutterLinkPreview(
                      url: jsonDecode(snapshot.data[index].json)["url"],
                      bodyStyle: TextStyle(
                        fontSize: 10.0,
                      ),
                      titleStyle: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(),
                ],
              );
            },
          );
        }
      });
}

Widget _showUsername(String username, Uid currentUid) {
  var routingServices = GetIt.I.get<RoutingService>();
  return Padding(
    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          username != null ? "@$username" : '',
          style: TextStyle(fontSize: 18.0, color: Colors.blue),
        ),
        // SizedBox(
        //   width: 150,
        // ),
        IconButton(
            icon: Icon(
              Icons.share,
              size: 22,
              color: Colors.white,
            ),
            onPressed: () {
              routingServices.openSelectForwardMessage(
                  sharedUid: proto.ShareUid()
                    ..name = username
                    ..uid = currentUid);
            })
      ],
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
