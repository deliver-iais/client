import 'dart:async';

import 'package:android_intent/android_intent.dart';
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

  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();

  I18N i18n = GetIt.I.get<I18N>();

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
                              : currentPage == Page.files
                                  ? ShareBoxFile(
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
                                          onClick: (index, path) async {
                                            setState(() {
                                              selectedImages[index - 1] =
                                                  !(selectedImages[index - 1] ??
                                                      false);

                                              selectedImages[index - 1]!
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
                                        List<model.File> res = [];
                                        finalSelected.forEach((key, value) {
                                          res.add(model.File(
                                              value, value.split(".").last));
                                        });
                                        if (widget.replyMessageId != null) {
                                          messageRepo.sendMultipleFilesMessages(
                                              widget.currentRoomId, res,
                                              replyToId: widget.replyMessageId);
                                        } else {
                                          messageRepo.sendMultipleFilesMessages(
                                            widget.currentRoomId,
                                            res,
                                          );
                                        }

                                        Navigator.pop(co);
                                        Timer(const Duration(seconds: 2), () {
                                          widget.scrollToLastSentMessage();
                                        });
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
                                        var res = await ImageItem.getImages();
                                        if (res.isEmpty) {
                                          FilePickerResult? result =
                                              await FilePicker.platform
                                                  .pickFiles(
                                            allowMultiple: true,
                                            type: FileType.custom,
                                          );
                                          if (result != null) {
                                            Map<String, String> res = {};
                                            for (var element in result.files) {
                                              res[element.name] = element.path!;
                                            }
                                            Navigator.pop(co);
                                            //todo merge by get media
                                            // showCaptionDialog(
                                            //     type: "image",
                                            //     files: res,
                                            //     roomUid: widget.currentRoomId,
                                            //     context: context);
                                          }
                                        } else {
                                          setState(() {
                                            _audioPlayer.stopPlayer();
                                            currentPage = Page.gallery;
                                          });
                                        }
                                      }, Icons.insert_drive_file,
                                          i18n.get("gallery"), 40,
                                          context: co),
                                      circleButton(() async {
                                        FilePickerResult? result =
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
                                          List<model.File> res = [];
                                          for (var element in result.files) {
                                            res.add(model.File(
                                                element.path!, element.name));
                                          }
                                          Navigator.pop(co);
                                          showCaptionDialog(
                                              type: "file",
                                              files: res,
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
                                            const AndroidIntent intent =
                                                AndroidIntent(
                                              action:
                                                  'android.settings.LOCATION_SOURCE_SETTINGS',
                                            );
                                            await intent.launch();
                                          } else {
                                            setState(() {
                                              currentPage = Page.location;
                                              initialChildSize.add(0.5);
                                            });
                                          }
                                        }
                                      }, Icons.location_on,
                                          i18n.get("location"), 40,
                                          context: co),
                                      circleButton(() async {
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                                allowMultiple: true,
                                                type: FileType.custom,
                                                allowedExtensions: ["mp3"]);
                                        if (result != null) {
                                          List<model.File> res = [];
                                          result.files.forEach((element) {
                                            res.add(model.File(
                                                element.path!, element.name,
                                                extention: element.extension,
                                                size: element.size));
                                          });
                                          Navigator.pop(co);
                                          showCaptionDialog(
                                              roomUid: widget.currentRoomId,
                                              type: "music",
                                              context: context,
                                              files: res);
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
                            child: SettingsList(
                              backgroundColor: Colors.white,
                              sections: [
                                SettingsSection(
                                  tiles: [
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
    required BuildContext context}) async {
  if (files!.isEmpty && editableMessage == null) return;
  showDialog(
      context: context,
      builder: (context) {
        return ShowCaptionDialog(
          type: type,
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
