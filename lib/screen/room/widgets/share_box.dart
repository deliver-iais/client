import 'dart:async';

import 'package:android_intent/android_intent.dart';

import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/room/widgets/share_box/file.dart';
import 'package:deliver_flutter/screen/room/widgets/share_box/gallery.dart';
import 'package:deliver_flutter/screen/room/widgets/share_box/music.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';

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

  Geolocator _geolocator = new Geolocator();

  Position _locationData;

  CheckPermissionsService _checkPermissionsService =
      GetIt.I.get<CheckPermissionsService>();

  int playAudioIndex;

  bool selected = false;

  var messageRepo = GetIt.I.get<MessageRepo>();

  var _routingServices = GetIt.I.get<RoutingService>();

  var currentPage = Page.Gallery;

  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 1,
      expand: false,
      builder: (context, scrollController) {
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
                                          !(selectedImages[index - 1] ?? false);

                                      selectedImages[index - 1]
                                          ? finalSelected[index - 1] = path
                                          : finalSelected.remove(index - 1);
                                    });
                                  },
                                  selectedImages: selectedImages,
                                  selectGallery: true,
                                  roomUid: widget.currentRoomId,
                                )
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
                                    messageRepo.sendMultipleFilesMessages(
                                        widget.currentRoomId,
                                        finalSelected.values.toList(),
                                        replyToId: widget.replyMessageId);
                                  } else {
                                    messageRepo.sendMultipleFilesMessages(
                                      widget.currentRoomId,
                                      finalSelected.values.toList(),
                                    );
                                  }

                                  Navigator.pop(context);
                                  Timer(Duration(seconds: 2), () {
                                    widget.scrollToLastSentMessage();
                                  });
                                  setState(() {
                                    finalSelected.clear();
                                    selectedAudio.clear();
                                    selectedImages.clear();
                                    selectedFiles.clear();
                                  });
                                }, Icons.send, "", 50, context: context),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    new BoxShadow(
                                        blurRadius: 20.0, spreadRadius: 0.0)
                                  ],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Positioned(
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        finalSelected.values.length.toString(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).primaryColor,
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
                      padding: const EdgeInsetsDirectional.only(bottom: 10),
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              circleButton(() async {
                                var res = await ImageItem.getImages();
                                if(res == null  || res.length<1){
                                  FilePickerResult result =
                                  await FilePicker.platform.pickFiles(
                                      allowMultiple: true,
                                      type: FileType.custom,);
                                  if (result != null) {
                                    Navigator.pop(context);
                                    for (var path in result.paths) {
                                      messageRepo.sendFileMessage(
                                          widget.currentRoomId, path);
                                    }
                                  }
                                }else
                                setState(() {
                                  _audioPlayer.stopPlayer();
                                  currentPage = Page.Gallery;
                                });
                              },
                                  Icons.insert_drive_file,
                                  i18n.get("gallery"),
                                  40,
                                  context: context),
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
                                      'gif','rar'
                                    ]);
                                if (result != null) {
                                  Navigator.pop(context);
                                  for (var path in result.paths) {
                                    messageRepo.sendFileMessage(
                                        widget.currentRoomId, path);
                                  }
                                }
                              }, Icons.file_upload,
                                  i18n.get("file"), 40,
                                  context: context),
                              circleButton(() async {
                                if (await _checkPermissionsService
                                        .checkLocationPermission() ||
                                    isIOS()) {
                                  if (!await _geolocator
                                      .isLocationServiceEnabled()) {
                                    final AndroidIntent intent =
                                        new AndroidIntent(
                                      action:
                                          'android.settings.LOCATION_SOURCE_SETTINGS',
                                    );
                                    await intent.launch();
                                  } else {
                                    _locationData =
                                        await _geolocator.getCurrentPosition();

                                    if (_locationData != null) {
                                      Navigator.pop(context);
                                      _routingServices.openLocation(
                                          roomUid: widget.currentRoomId,
                                          locationData: _locationData,
                                          scrollToLast:
                                              widget.scrollToLastSentMessage);
                                    }
                                  }
                                }
                              },
                                  Icons.location_on,
                                  i18n.get("location"),
                                  40,
                                  context: context),
                              circleButton(() async {
                                FilePickerResult result =
                                    await FilePicker.platform.pickFiles(
                                        allowMultiple: true,
                                        type: FileType.custom,
                                        allowedExtensions: ["mp3"]);
                                if (result != null) {
                                  Navigator.pop(context);
                                  for (var path in result.paths) {
                                    messageRepo.sendFileMessage(
                                        widget.currentRoomId, path);
                                  }
                                }
                              }, Icons.music_note,
                                  i18n.get("music"), 40,
                                  context: context),
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
  }

  isSelected() => finalSelected.values.length > 0;
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
