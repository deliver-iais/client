import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/mediaType.dart';
//import 'package:deliver_flutter/models/memberType.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/audio_play_progress.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/audio_progress_indicator.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/load-file-status.dart';
import 'package:deliver_flutter/screen/app_profile/pages/media_details_page.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/group_Ui_widget.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/memberWidget.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/music_play_progress.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
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
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as filePb;

class ProfilePage extends StatefulWidget {
  final Uid userUid;

  ProfilePage(this.userUid, {Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  List<String> mediaUrls = [];
  var mediasLength;
  Room currentRoomId;
  List<Media> _fetchedMedia;
  var _routingService = GetIt.I.get<RoutingService>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _contactRepo = GetIt.I.get<ContactRepo>();
  var _fileRepo = GetIt.I.get<FileRepo>();

  int tabsCount;
  var _fileCache = LruCache<String, File>(storage: SimpleStorage(size: 30));
  @override
  void initState() {
    super.initState();
    _mediaQueryRepo.getMediaMetaDataReq(widget.userUid);
  }

  download(String uuid, String name) async {
    await GetIt.I.get<FileRepo>().getFile(uuid, name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);

    return StreamBuilder(
      stream: _mediaQueryRepo.getMediasMetaDataCountFromDB(widget.userUid),
      builder: (context, snapshot) {
        tabsCount = 0;
        if (snapshot.hasData) {
          if (snapshot.data.imagesCount != 0) {
            tabsCount = tabsCount + 1;
            print(snapshot.data);
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
            print(
                "mediaaaaaaaaaaaaaaaaaaaaCounttttttttttttttttt${snapshot.data.musicsCount}");
            tabsCount = tabsCount + 1;
          }
          if (snapshot.data.audiosCount != 0) {
            tabsCount = tabsCount + 1;
          }
          return Scaffold(
              body: DefaultTabController(
                  length: widget.userUid.category == Categories.USER
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
                                              padding: EdgeInsets.fromLTRB(
                                                  20, 0, 0, 0),
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
                                                  AsyncSnapshot<Contact>
                                                      snapshot) {
                                                if (snapshot.data != null) {
                                                  return _showUsername(
                                                      snapshot.data.username);
                                                } else {
                                                  return FutureBuilder<
                                                      UserAsContact>(
                                                    future: _contactRepo
                                                        .searchUserByUid(
                                                            widget.userUid),
                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<
                                                                UserAsContact>
                                                            snapshot) {
                                                      if (snapshot.data !=
                                                          null) {
                                                        return _showUsername(
                                                            snapshot
                                                                .data.username);
                                                      } else {
                                                        return SizedBox
                                                            .shrink();
                                                      }
                                                    },
                                                  );
                                                }
                                              },
                                            ),
                                          ]),
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
                                          Text(appLocalization
                                              .getTraslateValue("sendMessage")),
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
                                                    Text(snapshot
                                                        .data.phoneNumber),
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
                                  child: TabBar(tabs: [
                                    if (widget.userUid.category !=
                                        Categories.USER)
                                      Tab(
                                        text: appLocalization
                                            .getTraslateValue("members"),
                                      ),
                                    if (snapshot.data.imagesCount != 0)
                                      Tab(
                                        text: appLocalization
                                            .getTraslateValue("images"),
                                      ),
                                    if (snapshot.data.videosCount != 0)
                                      Tab(
                                        text: appLocalization
                                            .getTraslateValue("videos"),
                                      ),
                                    if (snapshot.data.filesCount != 0)
                                      Tab(
                                        text: appLocalization
                                            .getTraslateValue("file"),
                                      ),
                                    if (snapshot.data.linkCount != 0)
                                      Tab(
                                          text: appLocalization
                                              .getTraslateValue("links")),
                                    if (snapshot.data.documentsCount != 0)
                                      Tab(
                                          text: appLocalization
                                              .getTraslateValue("documents")),
                                    if (snapshot.data.musicsCount != 0)
                                      Tab(
                                          text: appLocalization
                                              .getTraslateValue("musics")),
                                    if (snapshot.data.audiosCount != 0)
                                      Tab(
                                          text: appLocalization
                                              .getTraslateValue("audios")),
                                  ]),
                                )),
                          ),
                        ];
                      },
                      body: Container(
                          child: TabBarView(children: [
                        if (widget.userUid.category != Categories.USER)
                          SingleChildScrollView(
                            child: Column(children: [
                              MucMemberWidget(
                                mucUid: widget.userUid,
                              ),
                            ]),
                          ),
                        if (snapshot.data.imagesCount != 0)
                          imageWidget(widget.userUid, _mediaQueryRepo, _fileRepo, _fileCache,snapshot.data.imagesCount),

                        if (snapshot.data.videosCount != 0)
                          Text("videooooooooooooooo"),
                        if (snapshot.data.filesCount != 0)
                          Text("fileeeeeeeeeee"),
                        if (snapshot.data.linkCount != 0)
                          linkWidget(widget.userUid, _mediaQueryRepo, snapshot.data.linkCount),

                        if (snapshot.data.documentsCount != 0)
                          Text("dooooooooccccccccc"),
                        if (snapshot.data.musicsCount != 0)
                          musicWidget(
                              widget.userUid,
                              _fileRepo,
                              _mediaQueryRepo,
                              snapshot.data.musicsCount,
                              download),
                        if (snapshot.data.audiosCount != 0)
                          Text("audioooooooo"),
                      ])))));
        } else {
          return Container(
            width: 100,
            height: 100,
          );
        }
      },
    );
  }
}

Widget imageWidget(Uid userUid, MediaQueryRepo mediaQueryRepo,
    FileRepo fileRepo, LruCache mediaCache, int imagesCount) {
  var _routingService = GetIt.I.get<RoutingService>();

  return FutureBuilder<List<Media>>(
      future: mediaQueryRepo.getMedia(
          userUid, FetchMediasReq_MediaType.IMAGES, imagesCount),
      builder: (BuildContext c, AsyncSnapshot snaps) {
        if (!snaps.hasData ||
            snaps.data == null ||
            snaps.connectionState == ConnectionState.waiting) {
          return Container(width: 0.0, height: 0.0);
        } else {
          return GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: imagesCount,
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                //crossAxisSpacing: 2.0, mainAxisSpacing: 2.0,
              ),
              itemBuilder: (context, position) {
                var fileId = jsonDecode(snaps.data[position].json)["uuid"];
                var fileName = jsonDecode(snaps.data[position].json)["name"];
                var file = mediaCache.get(fileId);
                if (file == null)
                  return FutureBuilder(
                      future: fileRepo.getFile(fileId, fileName),
                      builder: (BuildContext c, AsyncSnapshot snaps) {
                        if (snaps.hasData &&
                            snaps.data != null &&
                            snaps.connectionState == ConnectionState.done) {
                          print(
                              "*******getfileeeeeeeeeeeeeeeeeee*************$position");
                          mediaCache.set(fileId, snaps.data);
                          return GestureDetector(
                            onTap: () {
                              _routingService.openShowAllMedia(
                                uid: userUid,
                                hasPermissionToDeletePic: true,
                                mediaPosition: position,
                                heroTag: "btn$position",
                                mediasLength: imagesCount,
                              );
                            },
                            child: Hero(
                              tag: "btn$position",
                              child: Container(
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
                              )),
                              transitionOnUserGestures: true,
                            ),
                          );
                        } else {
                          return Container(width: 0.0, height: 0.0);
                        }
                      });
                else {
                  return GestureDetector(
                    onTap: () {
                      _routingService.openShowAllMedia(
                        uid: userUid,
                        hasPermissionToDeletePic: true,
                        mediaPosition: position,
                        heroTag: "btn$position",
                        mediasLength: imagesCount,
                      );
                    },
                    child: Hero(
                      tag: "btn$position",
                      child: Container(
                          decoration: new BoxDecoration(
                        image: new DecorationImage(
                          image: Image.file(file).image,
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          width: 1,
                          color: ExtraTheme.of(context).secondColor,
                        ),
                      )),
                      transitionOnUserGestures: true,
                    ),
                  );
                }
              });
        }
      });
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

Widget musicWidget(Uid userUid, FileRepo fileRepo,
    MediaQueryRepo mediaQueryRepo, int musicCount, Function download) {
  return FutureBuilder<List<Media>>(
      future: mediaQueryRepo.getMedia(
          userUid, FetchMediasReq_MediaType.MUSICS, musicCount),
      builder: (BuildContext context, AsyncSnapshot<List<Media>> media) {
        if (!media.hasData ||
            media.data == null ||
            media.connectionState == ConnectionState.waiting) {
          return Container(width: 0.0, height: 0.0);
        } else {
          return Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: ListView.builder(
                itemCount: musicCount,
                itemBuilder: (BuildContext ctx, int index) {
                  var fileId = jsonDecode(media.data[index].json)["uuid"];
                  var fileName = jsonDecode(media.data[index].json)["name"];
                  var messageId = media.data[index].messageId;
                  return FutureBuilder<bool>(
                      future: fileRepo.isExist(fileId, fileName),
                      builder: (context, isExist) {
                        if (isExist.hasData && isExist.data) {
                          return Column(
                            children: [
                              ListTile(
                                title: Row(children: <Widget>[
                                  PlayAudioStatus(
                                    fileId: fileId,
                                    fileName: fileName,
                                  ),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15.0, top: 10),
                                          child: Text(fileName,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        MusicPlayProgress(
                                          audioUuid: fileId,
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                              Divider(
                                color: Colors.grey,
                              ),
                            ],
                          );
                        } else if (isExist.hasData && !isExist.data) {
                          return Column(
                            children: [
                              ListTile(
                                title: Row(
                                  children: [
                                    LoadFileStatus(
                                      fileId: fileId,
                                      fileName: fileName,
                                      dbId: messageId,
                                      onPressed: download,
                                    ),
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15.0, top: 10),
                                            child: Text(fileName,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          MusicPlayProgress(
                                            audioUuid: fileId,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                color: Colors.grey,
                              ),
                            ],
                          );
                        } else {
                          return Container(
                            width: 0,
                            height: 0,
                          );
                        }
                      });
                },
              ),
            ),
          );
        }
      });
}

Widget _showUsername(String username) {
  return Padding(
    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
    child: Text(
      username != null ? "@$username" : '',
      style: TextStyle(fontSize: 18.0, color: Colors.blue),
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
