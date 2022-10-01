import 'package:android_intent_plus/android_intent.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/build_input_caption.dart';
import 'package:deliver/screen/room/widgets/share_box/file.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery.dart';
import 'package:deliver/screen/room/widgets/share_box/music.dart';
import 'package:deliver/screen/room/widgets/show_caption_dialog.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/attach_location.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ShareBox extends StatefulWidget {
  final Uid currentRoomId;
  final int replyMessageId;
  final void Function() resetRoomPageDetails;
  final void Function() scrollToLastSentMessage;

  const ShareBox({
    super.key,
    required this.currentRoomId,
    this.replyMessageId = 0,
    required this.resetRoomPageDetails,
    required this.scrollToLastSentMessage,
  });

  @override
  ShareBoxState createState() => ShareBoxState();
}

enum Page { gallery, files, location, music }

class ShareBoxState extends State<ShareBox> {
  static final messageRepo = GetIt.I.get<MessageRepo>();

  final selectedImages = <int, bool>{};

  final selectedAudio = <int, bool>{};

  final selectedFiles = <int, bool>{};

  final icons = <int, IconData>{};

  final finalSelected = <int, String>{};

  final CheckPermissionsService _checkPermissionsService =
      GetIt.I.get<CheckPermissionsService>();
  final BehaviorSubject<bool> _insertCaption = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _draggableTitleVisibility =
      BehaviorSubject.seeded(false);
  final _keyboardVisibilityController = KeyboardVisibilityController();
  final TextEditingController _captionEditingController =
      TextEditingController();

  int playAudioIndex = -1;

  bool selected = false;
  TextEditingController captionTextController = TextEditingController();

  BehaviorSubject<double> initialChildSize = BehaviorSubject.seeded(0.5);

  Page currentPage = Page.gallery;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final _draggableScrollableController = DraggableScrollableController();

  I18N i18n = GetIt.I.get<I18N>();

  @override
  void dispose() {
    _audioPlayer.stop();
    captionTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _keyboardVisibilityController.onChange.listen((event) {
      _insertCaption.add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: theme.colorScheme.background,
      ),
      child: WillPopScope(
          onWillPop: () async {
            if (isSelected()) {
              setState(() {
                finalSelected.clear();
                selectedAudio.clear();
                selectedImages.clear();
                selectedFiles.clear();
              });
              return false;
            }
            return true;
          },
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if (notification.extent >= 0.98) {
                _draggableTitleVisibility.value = true;
              } else {
                _draggableTitleVisibility.value = false;
              }
              return true;
            },
            child: DraggableScrollableSheet(
              controller: _draggableScrollableController,
              minChildSize: 0.5,
              builder: (co, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(top: 15),
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
                                      icons[index] =
                                          Icons.play_circle_filled_rounded;
                                      playAudioIndex = -1;
                                    } else {
                                      _audioPlayer.play(DeviceFileSource(path));
                                      icons.remove(playAudioIndex);
                                      icons[index] =
                                          Icons.pause_circle_filled_rounded;
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
                                    selectedFiles: selectedFiles,
                                    resetRoomPageDetails:
                                        widget.resetRoomPageDetails,
                                    replyMessageId: widget.replyMessageId,
                                  )
                                : currentPage == Page.gallery
                                    ? ShareBoxGallery(
                                        replyMessageId: widget.replyMessageId,
                                        scrollController: scrollController,
                                        pop: () {
                                          Navigator.pop(context);
                                        },
                                        roomUid: widget.currentRoomId,
                                        resetRoomPageDetails:
                                            widget.resetRoomPageDetails,
                                      )
                                    : currentPage == Page.location
                                        ? AttachLocation(
                                            context,
                                            widget.currentRoomId,
                                          ).showLocation()
                                        : const SizedBox.shrink(),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          if (isSelected())
                            Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: SizedBox(
                                height: 80,
                                child: BuildInputCaption(
                                  insertCaption: _insertCaption,
                                  count: finalSelected.length,
                                  send: () {
                                    _audioPlayer.stop();
                                    Navigator.pop(co);
                                    messageRepo.sendMultipleFilesMessages(
                                      widget.currentRoomId,
                                      finalSelected.values
                                          .toList()
                                          .map(
                                            (path) => model.File(
                                              path,
                                              path.split("/").last,
                                            ),
                                          )
                                          .toList(),
                                      replyToId: widget.replyMessageId,
                                      caption: _captionEditingController.text,
                                    );

                                    setState(() {
                                      finalSelected.clear();
                                      selectedAudio.clear();
                                      selectedImages.clear();
                                      selectedFiles.clear();
                                    });
                                  },
                                  captionEditingController:
                                      _captionEditingController,
                                ),
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.background,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadowColor.withOpacity(0.3),
                                    blurRadius: 10.0,
                                  )
                                ],
                              ),
                              height: 70,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  circleButton(
                                    () async {
                                      setState(() {
                                        _audioPlayer.stop();
                                        currentPage = Page.gallery;
                                      });
                                    },
                                    Icons.insert_drive_file_rounded,
                                    i18n.get("gallery"),
                                    Page.gallery,
                                    context: co,
                                  ),
                                  circleButton(
                                    () async {
                                      setState(() {
                                        _audioPlayer.stop();
                                        currentPage = Page.files;
                                      });
                                    },
                                    Icons.file_upload_rounded,
                                    i18n.get("file"),
                                    Page.files,
                                    context: co,
                                  ),
                                  circleButton(
                                    () async {
                                      if (await _checkPermissionsService
                                              .checkLocationPermission() ||
                                          isIOS) {
                                        if (!await Geolocator
                                            .isLocationServiceEnabled()) {
                                          const intent = AndroidIntent(
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
                                    },
                                    Icons.location_on_rounded,
                                    i18n.get("location"),
                                    Page.location,
                                    context: co,
                                  ),
                                  circleButton(
                                    () async {
                                      await scrollController
                                          .animateTo(
                                        0.1,
                                        duration:
                                            const Duration(milliseconds: 100),
                                        curve: Curves.easeOutBack,
                                      );
                                      setState(() {
                                        currentPage = Page.music;
                                      });
                                    },
                                    Icons.music_note_rounded,
                                    i18n.get("music"),
                                    Page.music,
                                    context: co,
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                      IgnorePointer(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                top: 15,
                                bottom: 50,
                              ),
                              height: 5,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: theme.dividerColor,
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0.0,
                        top: 0.0,
                        right: 0.0,
                        child: StreamBuilder<bool>(
                          stream: _draggableTitleVisibility,
                          builder: (context, value) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: value.data ?? false ? 80 : 0,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: theme.dividerColor,
                                  ),
                                ),
                                color: theme.colorScheme.surface,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: AppBar(
                                  title: Text(_getDraggableTitle()),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )),
    );
  }

  bool isSelected() => finalSelected.values.isNotEmpty;

  String _getDraggableTitle() {
    switch (currentPage) {
      case Page.gallery:
        return i18n.get("gallery");
      case Page.files:
        return i18n.get("file");
      case Page.location:
        return i18n.get("location");
      case Page.music:
        return i18n.get("music");
    }
  }

  Widget circleButton(
    Function() onTap,
    IconData icon,
    String text,
    Page page, {
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          splashColor: theme.shadowColor.withOpacity(0.3),
          onTap: onTap, // inkwell color
          child: Container(
            width: 48,
            height: 48,
            decoration: currentPage == page
                ? BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: theme.primaryColor,
                    ),
                    shape: BoxShape.circle,
                  )
                : null,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor,
                ),
                width: 40,
                height: 40,
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 3,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: currentPage == page ? theme.primaryColor : null,
          ),
        ),
      ],
    );
  }
}

void showCaptionDialog({
  List<model.File>? files,
  required Uid roomUid,
  required BuildContext context,
  void Function()? resetRoomPageDetails,
  int replyMessageId = 0,
  Message? editableMessage,
  String? caption,
  bool showSelectedImage = false,
}) {
  if (editableMessage == null && (files?.isEmpty ?? false)) return;
  showDialog(
    context: context,
    builder: (context) {
      return ShowCaptionDialog(
        resetRoomPageDetails: resetRoomPageDetails,
        replyMessageId: replyMessageId,
        caption: caption,
        showSelectedImage: showSelectedImage,
        editableMessage: editableMessage,
        currentRoom: roomUid,
        files: files,
      );
    },
  );
}
