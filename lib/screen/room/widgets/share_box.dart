import 'dart:async';

import 'package:android_intent/android_intent.dart';

import 'package:we/localization/i18n.dart';
import 'package:we/repository/messageRepo.dart';
import 'package:we/repository/roomRepo.dart';
import 'package:we/screen/room/widgets/share_box/file.dart';
import 'package:we/screen/room/widgets/share_box/gallery.dart';
import 'package:we/screen/room/widgets/share_box/music.dart';
import 'package:we/screen/room/widgets/show_caption_dialog.dart';
import 'package:we/services/check_permissions_service.dart';
import 'package:we/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings_ui/settings_ui.dart';

import 'share_box/helper_classes.dart';

class ShareBox extends StatefulWidget {
  final Uid currentRoomId;
  final int replyMessageId;
  final Function resetRoomPageDetails;
  final Function scrollToLastSentMessage;

  const ShareBox(
      {Key key,
      this.currentRoomId,
      this.replyMessageId,
      this.resetRoomPageDetails,
      this.scrollToLastSentMessage})
      : super(key: key);

  @override
  _ShareBoxState createState() => _ShareBoxState();
}

enum Page { Gallery, Files, Location, Music }

class _ShareBoxState extends State<ShareBox> {
  final selectedImages = Map<int, bool>();

  final selectedAudio = Map<int, bool>();

  final selectedFiles = Map<int, bool>();

  final icons = Map<int, IconData>();

  final finalSelected = Map<int, String>();

  CheckPermissionsService _checkPermissionsService =
      GetIt.I.get<CheckPermissionsService>();

  int playAudioIndex;

  bool selected = false;
  TextEditingController captionTextController = TextEditingController();
  final _roomRepo = GetIt.I.get<RoomRepo>();

  var messageRepo = GetIt.I.get<MessageRepo>();

  BehaviorSubject<double> initialChildSize = BehaviorSubject.seeded(0.5);

  var currentPage = Page.Gallery;

  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return StreamBuilder<double>(
        stream: initialChildSize.stream,
        builder: (c, initialSize) {
          if (initialSize.hasData && initialSize.data != null)
            return DraggableScrollableSheet(
              initialChildSize: initialSize.data,
              minChildSize: initialSize.data,
              maxChildSize: 1,
              expand: true,
              builder: (co, scrollController) {
                return Container(
                  color: Colors.white,
                  child: Stack(
                    children: <Widget>[
                      Container(
                          padding: !isSelected()
                              ? const EdgeInsetsDirectional.only(bottom: 80)
                              : const EdgeInsets.all(0),
                          child: currentPage == Page.Music
                              ? ShareBoxMusic(
                                  scrollController: scrollController,
                                  onClick: (index, path) {
                                    setState(() {
                                      selectedAudio[index] =
                                          !(selectedAudio[index] ?? false);
                                      selectedAudio[index]
                                          ? finalSelected[index] = path
                                          : finalSelected.remove(index);
                                    });
                                  },
                                  playMusic: (index, path) {
                                    setState(() {
                                      if (playAudioIndex == index) {
                                        _audioPlayer.pausePlayer();
                                        icons[index] = Icons.play_arrow;
                                        playAudioIndex = -1;
                                      } else {
                                        _audioPlayer.startPlayer(fromURI: path);
                                        icons.remove(playAudioIndex);
                                        icons[index] = Icons.pause;
                                        playAudioIndex = index;
                                      }
                                    });
                                  },
                                  selectedAudio: selectedAudio,
                                  icons: icons,
                                )
                              : currentPage == Page.Files
                                  ? ShareBoxFile(
                                      scrollController: scrollController,
                                      onClick: (index, path) {
                                        setState(() {
                                          selectedFiles[index] =
                                              !(selectedFiles[index] ?? false);
                                          selectedFiles[index]
                                              ? finalSelected[index] = path
                                              : finalSelected.remove(index);
                                        });
                                      },
                                      selectedFiles: selectedFiles)
                                  : currentPage == Page.Gallery
                                      ? ShareBoxGallery(
                                          scrollController: scrollController,
                                          onClick: (index, path) async {
                                            setState(() {
                                              selectedImages[index - 1] =
                                                  !(selectedImages[index - 1] ??
                                                      false);

                                              selectedImages[index - 1]
                                                  ? finalSelected[index - 1] =
                                                      path
                                                  : finalSelected
                                                      .remove(index - 1);
                                            });
                                          },
                                          selectedImages: selectedImages,
                                          selectGallery: true,
                                          roomUid: widget.currentRoomId,
                                        )
                                      : currentPage == Page.Location
                                          ? showLocation(
                                              scrollController, i18n, co)
                                          : SizedBox.shrink()),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          if (isSelected())
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Stack(
                                    children: <Widget>[
                                      Container(
                                        child: circleButton(() {
                                          if (widget.replyMessageId != null) {
                                            messageRepo
                                                .sendMultipleFilesMessages(
                                                    widget.currentRoomId,
                                                    finalSelected.values
                                                        .toList(),
                                                    replyToId:
                                                        widget.replyMessageId);
                                          } else {
                                            messageRepo
                                                .sendMultipleFilesMessages(
                                              widget.currentRoomId,
                                              finalSelected.values.toList(),
                                            );
                                          }

                                          Navigator.pop(co);
                                          Timer(Duration(seconds: 2), () {
                                            widget.scrollToLastSentMessage();
                                          });
                                          setState(() {
                                            finalSelected.clear();
                                            selectedAudio.clear();
                                            selectedImages.clear();
                                            selectedFiles.clear();
                                          });
                                        }, Icons.send, "", 50, context: co),
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            new BoxShadow(
                                                blurRadius: 20.0,
                                                spreadRadius: 0.0)
                                          ],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Positioned(
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                finalSelected.values.length
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          width: 16.0,
                                          height: 16.0,
                                          decoration: new BoxDecoration(
                                            color: Theme.of(co)
                                                .dialogBackgroundColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        top: 35.0,
                                        right: 0.0,
                                        left: 31,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 30,
                                  )
                                ],
                              ),
                            )
                          else
                            Container(
                              padding:
                                  const EdgeInsetsDirectional.only(bottom: 10),
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      circleButton(() async {
                                        var res = await ImageItem.getImages();
                                        if (res == null || res.length < 1) {
                                          FilePickerResult result =
                                              await FilePicker.platform
                                                  .pickFiles(
                                            allowMultiple: true,
                                            type: FileType.custom,
                                          );
                                          if (result != null) {
                                            Navigator.pop(co);
                                            showCaptionDialog(
                                                type: "image",
                                                paths: result.paths,
                                                roomUid: widget.currentRoomId,
                                                context: context);
                                          }
                                        } else
                                          setState(() {
                                            _audioPlayer.stopPlayer();
                                            currentPage = Page.Gallery;
                                          });
                                      }, Icons.insert_drive_file,
                                          i18n.get("gallery"), 40,
                                          context: co),
                                      circleButton(() async {
                                        FilePickerResult result =
                                            await FilePicker.platform.pickFiles(
                                                allowMultiple: true,
                                                type: FileType.custom,
                                                allowedExtensions: [
                                              "pdf",
                                              "mp4",
                                              "pptx",
                                              "docx",
                                              "xlsx",
                                              'png',
                                              'jpg',
                                              'jpeg',
                                              'gif',
                                              'rar'
                                            ]);
                                        if (result != null) {
                                          Navigator.pop(co);
                                          showCaptionDialog(
                                              type: "file",
                                              paths: result.paths,
                                              roomUid: widget.currentRoomId,
                                              context: context);
                                        }
                                      }, Icons.file_upload, i18n.get("file"),
                                          40,
                                          context: co),
                                      circleButton(() async {
                                        if (await _checkPermissionsService
                                                .checkLocationPermission() ||
                                            isIOS()) {
                                          if (!await Geolocator
                                              .isLocationServiceEnabled()) {
                                            final AndroidIntent intent =
                                                new AndroidIntent(
                                              action:
                                                  'android.settings.LOCATION_SOURCE_SETTINGS',
                                            );
                                            await intent.launch();
                                          } else {
                                            setState(() {
                                              currentPage = Page.Location;
                                              initialChildSize.add(0.5);
                                            });
                                          }
                                        }
                                      }, Icons.location_on,
                                          i18n.get("location"), 40,
                                          context: co),
                                      circleButton(() async {
                                        FilePickerResult result =
                                            await FilePicker.platform.pickFiles(
                                                allowMultiple: true,
                                                type: FileType.custom,
                                                allowedExtensions: ["mp3"]);
                                        if (result != null) {
                                          Navigator.pop(co);
                                          showCaptionDialog(
                                              type: "music",
                                              context: context,
                                              paths: result.paths);
                                        }
                                      }, Icons.music_note, i18n.get("music"),
                                          40,
                                          context: co),
                                    ],
                                  ),
                                ],
                              ),
                            )
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          else
            return SizedBox.shrink();
        });
  }

  FutureBuilder<Position> showLocation(
      ScrollController scrollController, I18N i18n, BuildContext context) {
    return FutureBuilder(
        future: Geolocator.getCurrentPosition(),
        builder: (c, position) {
          if (position.hasData && position.data != null) {
            return Container(
                child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3 - 40,
                  child: FlutterMap(
                    options: new MapOptions(
                      center: LatLng(
                          position.data.latitude, position.data.longitude),
                      zoom: 14.0,
                    ),
                    layers: [
                      new TileLayerOptions(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c']),
                      new MarkerLayerOptions(
                        markers: [
                          new Marker(
                            width: 170.0,
                            height: 170.0,
                            point: LatLng(position.data.latitude,
                                position.data.longitude),
                            builder: (ctx) => Container(
                              child: Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        child: Icon(
                          Icons.location_on_sharp,
                          color: Colors.blueAccent,
                          size: 28,
                        ),
                      ),
                      Text(
                        i18n.get(
                          "send_this_location",
                        ),
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    messageRepo.sendLocationMessage(
                        position.data, widget.currentRoomId);
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                Divider(),
                //todo  liveLocation
                // GestureDetector(
                //   behavior: HitTestBehavior.translucent,
                //   onTap: () {
                //     liveLocation(i18n, context,position.data);
                //   },
                //   child: Row(
                //     children: [
                //       Container(
                //           child: l.Lottie.asset(
                //             'assets/animations/liveLocation.json',
                //             width: 40,
                //             height: 40,
                //           )),
                //       Text(
                //         i18n.get(
                //           "send_live_location",
                //         ),
                //         style: TextStyle(fontSize: 18),
                //       )
                //     ],
                //   ),
                // )
              ],
            ));
          } else {
            return SizedBox.shrink();
          }
        });
  }

  isSelected() => finalSelected.values.length > 0;

  liveLocation(I18N i18n, BuildContext context, Position position) {
    BehaviorSubject<String> time = BehaviorSubject.seeded("10");
    showDialog(
        context: context,
        builder: (context) {
          return StreamBuilder<String>(
              stream: time.stream,
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.only(top: 300, left: 30, right: 30),
                  child: Center(
                    child: ListView(
                      children: [
                        Container(
                          height: 50,
                          color: Colors.blue,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.greenAccent,
                            size: 40,
                          ),
                        ),
                        Container(
                            color: Colors.white,
                            child: Text(
                              i18n.get("choose_livelocation_time"),
                              style: TextStyle(fontSize: 20),
                            )),
                        Container(
                          color: Colors.white,
                          child: SizedBox(
                            height: 200,
                            child: SettingsList(
                              backgroundColor: Colors.white,
                              sections: [
                                SettingsSection(
                                  tiles: [
                                    settingsTile(snapshot.data, "10", () {
                                      time.add("10");
                                    }),
                                    settingsTile(snapshot.data, "15", () {
                                      time.add("15");
                                    }),
                                    settingsTile(snapshot.data, "30", () {
                                      time.add("30");
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                child: Text(
                                  i18n.get("cancel"),
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.blue),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              GestureDetector(
                                  child: Text(
                                    i18n.get("share"),
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.red),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    messageRepo.sendLiveLocationMessage(
                                      widget.currentRoomId,
                                      int.parse(time.valueWrapper.value),
                                      position,
                                    );
                                  }),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                );
              });
        });
  }

  SettingsTile settingsTile(String data, String t, Function on) {
    return SettingsTile(
      title: t,
      leading: Icon(
        Icons.alarm,
        color: Colors.blueAccent,
      ),
      trailing: data == t
          ? Icon(
              Icons.done,
              color: Colors.blueAccent,
            )
          : SizedBox.shrink(),
      onPressed: (BuildContext context) {
        on();
      },
    );
  }
}

showCaptionDialog(
    {String type,
    List<String> paths,
    Uid roomUid,
    BuildContext context}) async {
  if (paths.length <= 0) return;
  showDialog(
      context: context,
      builder: (context) {
        return ShowCaptionDialog(
          type: type,
          currentRoom: roomUid,
          paths: paths,
        );
      });
}

Widget circleButton(Function onTap, IconData icon, String text, double size,
    {BuildContext context}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      ClipOval(
        child: Material(
          color: Theme.of(context).primaryColor, // button color
          child: InkWell(
              splashColor: Colors.red, // inkwell color
              child: SizedBox(
                  width: size,
                  height: size,
                  child: Icon(
                    icon,
                    color: Colors.white,
                  )),
              onTap: onTap),
        ),
      ),
      Text(
        text,
        style:
            TextStyle(fontSize: 10, color: Theme.of(context).backgroundColor),
      ),
    ],
  );
}
