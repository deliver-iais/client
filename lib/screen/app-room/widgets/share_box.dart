import 'package:audioplayers/audioplayers.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/file.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/gallery.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/music.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';

class ShareBox extends StatefulWidget {
  final Uid currentRoomId;

  const ShareBox({Key key, this.currentRoomId}) : super(key: key);
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

  int playAudioIndex;

  bool selected = false;

  var fileRepo = GetIt.I.get<FileRepo>();
  var messageRepo = GetIt.I.get<MessageRepo>();

  var currentPage = Page.Gallery;

  AudioPlayer audioPlayer = AudioPlayer();

  Widget CircleButton(Function onTap, IconData icon, String text, double size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipOval(
          child: Material(
            color: Colors.blue, // button color
            child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: SizedBox(width: size, height: size, child: Icon(icon)),
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

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
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
                                audioPlayer.pause();
                                icons[index] = Icons.play_circle_filled;
                                playAudioIndex = -1;
                              } else {
                                audioPlayer.play(path);
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
                                )
                              : SizedBox.shrink()),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  isSelected()
                      ? Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  Container(
                                    child: CircleButton(
                                      () {
                                        finalSelected.forEach((key, value) {
                                          messageRepo.sendFileMessage(
                                              widget.currentRoomId, value);
                                        });
                                        setState(() {
                                          finalSelected.clear();
                                          selectedAudio.clear();
                                          selectedImages.clear();
                                          selectedFiles.clear();
                                        });
                                      },
                                      Icons.send,
                                      "",
                                      50,
                                    ),
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
                                        color: Colors.blue,
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
                      : Container(
                          padding: const EdgeInsetsDirectional.only(bottom: 10),
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  CircleButton(() {
                                    setState(() {
                                      audioPlayer.stop();

                                      currentPage = Page.Gallery;
                                    });
                                  },
                                      Icons.insert_drive_file,
                                      appLocalization
                                          .getTraslateValue("gallery"),
                                      40),
                                  CircleButton(() {
                                    setState(() {
                                      audioPlayer.stop();
                                      currentPage = Page.Files;
                                    });
                                  },
                                      Icons.file_upload,
                                      appLocalization.getTraslateValue("file"),
                                      40),
                                  CircleButton(() async {
                                    audioPlayer.stop();
                                  },
                                      Icons.location_on,
                                      appLocalization
                                          .getTraslateValue("location"),
                                      40),
                                  CircleButton(() {
                                    setState(() {
                                      currentPage = Page.Music;
                                    });
                                  },
                                      Icons.music_note,
                                      appLocalization.getTraslateValue("music"),
                                      40),
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
