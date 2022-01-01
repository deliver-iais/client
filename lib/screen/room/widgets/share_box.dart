import 'package:android_intent/android_intent.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:deliver/box/message.dart';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/file.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery.dart';
import 'package:deliver/screen/room/widgets/share_box/music.dart';
import 'package:deliver/screen/room/widgets/show_caption_dialog.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ShareBox extends StatefulWidget {
  final Uid currentRoomId;
  final int? replyMessageId;
  final Function resetRoomPageDetails;
  final Function scrollToLastSentMessage;

  const ShareBox(
      {Key? key,
      required this.currentRoomId,
      this.replyMessageId,
      required this.resetRoomPageDetails,
      required this.scrollToLastSentMessage})
      : super(key: key);

  @override
  _ShareBoxState createState() => _ShareBoxState();
}

enum Page { gallery, files, location, music }

class _ShareBoxState extends State<ShareBox> {
  final messageRepo = GetIt.I.get<MessageRepo>();

  final selectedImages = <int, bool>{};

  final selectedAudio = <int, bool>{};

  final selectedFiles = <int, bool>{};

  final icons = <int, IconData>{};

  final finalSelected = <int, String>{};

  final CheckPermissionsService _checkPermissionsService =
      GetIt.I.get<CheckPermissionsService>();

  int playAudioIndex = -1;

  bool selected = false;
  TextEditingController captionTextController = TextEditingController();

  BehaviorSubject<double> initialChildSize = BehaviorSubject.seeded(0.5);

  var currentPage = Page.gallery;
  final AudioPlayer _audioPlayer = AudioPlayer();

  I18N i18n = GetIt.I.get<I18N>();

  @override
  void dispose() {
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
        stream: initialChildSize.stream,
        builder: (c, initialSize) {
          if (initialSize.hasData && initialSize.data != null) {
            return DraggableScrollableSheet(
              initialChildSize: initialSize.data!,
              minChildSize: initialSize.data!,
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
                          child: currentPage == Page.music
                              ? ShareBoxMusic(
                                  scrollController: scrollController,
                                  onClick: (index, path) {
                                    setState(() {
                                      selectedAudio[index] =
                                          !(selectedAudio[index] ?? false);
                                      selectedAudio[index]!
                                          ? finalSelected[index] = path
                                          : finalSelected.remove(index);
                                    });
                                  },
                                  playMusic: (index, path) {
                                    setState(() {
                                      if (playAudioIndex == index) {
                                        _audioPlayer.pause();
                                        icons[index] = Icons.play_arrow;
                                        playAudioIndex = -1;
                                      } else {
                                        _audioPlayer.play(path);
                                        icons.remove(playAudioIndex);
                                        icons[index] = Icons.pause;
                                        playAudioIndex = index;
                                      }
                                    });
                                  },
                                  selectedAudio: selectedAudio,
                                  icons: icons,
                                )
                              : currentPage == Page.files
                                  ? ShareBoxFile(
                                      roomUid: widget.currentRoomId,
                                      scrollController: scrollController,
                                      onClick: (index, path) {
                                        setState(() {
                                          selectedFiles[index] =
                                              !(selectedFiles[index] ?? false);
                                          selectedFiles[index]!
                                              ? finalSelected[index] = path
                                              : finalSelected.remove(index);
                                        });
                                      },
                                      selectedFiles: selectedFiles)
                                  : currentPage == Page.gallery
                                      ? ShareBoxGallery(
                                          scrollController: scrollController,
                                          selectAvatar: false,
                                          pop: () {
                                            Navigator.of(context);
                                          },
                                          roomUid: widget.currentRoomId,
                                        )
                                      : currentPage == Page.location
                                          ? showLocation(
                                              scrollController, i18n, co)
                                          : const SizedBox.shrink()),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          if (isSelected())
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Container(
                                      child: circleButton(() {
                                        _audioPlayer.stop();
                                        Navigator.pop(co);
                                        if (widget.replyMessageId! > 0) {
                                          messageRepo.sendMultipleFilesMessages(
                                              widget.currentRoomId,
                                              finalSelected.values
                                                  .toList()
                                                  .map((e) => model.File(e, e))
                                                  .toList(),
                                              replyToId: widget.replyMessageId);
                                        } else {
                                          showCaptionDialog(
                                              type: "file",
                                              files: finalSelected.values
                                                  .toList()
                                                  .map((e) => model.File(e, e))
                                                  .toList(),
                                              roomUid: widget.currentRoomId,
                                              context: context);
                                        }
                                        setState(() {
                                          finalSelected.clear();
                                          selectedAudio.clear();
                                          selectedImages.clear();
                                          selectedFiles.clear();
                                        });
                                      }, Icons.send, "", 50, context: co),
                                      decoration: const BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
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
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        width: 16.0,
                                        height: 16.0,
                                        decoration: BoxDecoration(
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
                                const SizedBox(
                                  width: 30,
                                )
                              ],
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
                                        setState(() {
                                          _audioPlayer.stop();
                                          currentPage = Page.gallery;
                                        });
                                      }, Icons.insert_drive_file,
                                          i18n.get("gallery"), 40,
                                          context: co),
                                      circleButton(() async {
                                        setState(() {
                                          _audioPlayer.stop();
                                          currentPage = Page.files;
                                        });
                                      }, Icons.file_upload, i18n.get("file"),
                                          40,
                                          context: co),
                                      circleButton(() async {
                                        if (await _checkPermissionsService
                                                .checkLocationPermission() ||
                                            isIOS()) {
                                          if (!await Geolocator
                                              .isLocationServiceEnabled()) {
                                            const AndroidIntent intent =
                                                AndroidIntent(
                                              action:
                                                  'android.settings.LOCATION_SOURCE_SETTINGS',
                                            );
                                            await intent.launch();
                                          } else {
                                            setState(() {
                                              _audioPlayer.stop();
                                              currentPage = Page.location;
                                              initialChildSize.add(0.5);
                                            });
                                          }
                                        }
                                      }, Icons.location_on,
                                          i18n.get("location"), 40,
                                          context: co),
                                      circleButton(() async {
                                        setState(() {
                                          currentPage = Page.music;
                                        });
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
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  FutureBuilder<Position> showLocation(
      ScrollController scrollController, I18N i18n, BuildContext context) {
    return FutureBuilder(
        future: Geolocator.getCurrentPosition(),
        builder: (c, position) {
          if (position.hasData && position.data != null) {
            return ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3 - 40,
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(
                          position.data!.latitude, position.data!.longitude),
                      zoom: 14.0,
                    ),
                    layers: [
                      TileLayerOptions(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c']),
                      MarkerLayerOptions(
                        markers: [
                          Marker(
                            width: 170.0,
                            height: 170.0,
                            point: LatLng(position.data!.latitude,
                                position.data!.longitude),
                            builder: (ctx) => const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: [
                      const SizedBox(
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
                        style: const TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    messageRepo.sendLocationMessage(
                        position.data!, widget.currentRoomId);
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(),
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
            );
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  isSelected() => finalSelected.values.isNotEmpty;

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
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.greenAccent,
                            size: 40,
                          ),
                        ),
                        Container(
                            color: Colors.white,
                            child: Text(
                              i18n.get("choose_livelocation_time"),
                              style: const TextStyle(fontSize: 20),
                            )),
                        Container(
                          color: Colors.white,
                          child: SizedBox(
                            height: 200,
                            child: ListView(
                              children: [
                                Section(
                                  children: [
                                    settingsTile(snapshot.data!, "10", () {
                                      time.add("10");
                                    }),
                                    settingsTile(snapshot.data!, "15", () {
                                      time.add("15");
                                    }),
                                    settingsTile(snapshot.data!, "30", () {
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
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.blue),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              GestureDetector(
                                  child: Text(
                                    i18n.get("share"),
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.red),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    messageRepo.sendLiveLocationMessage(
                                      widget.currentRoomId,
                                      int.parse(time.value),
                                      position,
                                    );
                                  }),
                            ],
                          ),
                        ),
                        const SizedBox(
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
      leading: const Icon(
        Icons.alarm,
        color: Colors.blueAccent,
      ),
      trailing: data == t
          ? const Icon(
              Icons.done,
              color: Colors.blueAccent,
            )
          : const SizedBox.shrink(),
      onPressed: (BuildContext context) {
        on();
      },
    );
  }
}

showCaptionDialog(
    {String? type,
    List<model.File>? files,
    required Uid roomUid,
    Message? editableMessage,
    required BuildContext context,
    bool showSelectedImage = false}) async {
  if (files!.isEmpty && editableMessage == null) return;
  showDialog(
      context: context,
      builder: (context) {
        return ShowCaptionDialog(
          type: type,
          showSelectedImage: showSelectedImage,
          editableMessage: editableMessage,
          currentRoom: roomUid,
          files: files,
        );
      });
}

Widget circleButton(Function() onTap, IconData icon, String text, double size,
    {required BuildContext context}) {
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
