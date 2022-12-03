import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
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
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/attach_location.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

const BOTTOM_BUTTONS_HEIGHT = 80.0;

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
  final _keyboardVisibilityController = KeyboardVisibilityController();

  // final TextEditingController _captionEditingController =
  //     TextEditingController();

  int playAudioIndex = -1;

  bool selected = false;
  TextEditingController captionTextController = TextEditingController();

  BehaviorSubject<double> initialChildSize = BehaviorSubject.seeded(0.6);

  Page currentPage = Page.gallery;
  final AudioPlayer _audioPlayer = AudioPlayer();

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
    return WillPopScope(
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
      child: StreamBuilder<double>(
        stream: initialChildSize,
        builder: (c, initialSize) {
          if (initialSize.hasData && initialSize.data != null) {
            return DraggableScrollableSheet(
              initialChildSize: initialSize.data!,
              minChildSize: initialSize.data!,
              builder: (co, scrollController) {
                Widget w = const SizedBox.shrink();
                if (currentPage == Page.music) {
                  w = ShareBoxMusic(
                    scrollController: scrollController,
                    onClick: (index, path) {
                      setState(() {
                        selectedAudio[index] = !(selectedAudio[index] ?? false);
                        selectedAudio[index]!
                            ? finalSelected[index] = path
                            : finalSelected.remove(index);
                      });
                    },
                    playMusic: (index, path) {
                      setState(() {
                        if (playAudioIndex == index) {
                          _audioPlayer.pause();
                          icons[index] = Icons.play_circle_filled_rounded;
                          playAudioIndex = -1;
                        } else {
                          _audioPlayer.play(DeviceFileSource(path));
                          icons.remove(playAudioIndex);
                          icons[index] = Icons.pause_circle_filled_rounded;
                          playAudioIndex = index;
                        }
                      });
                    },
                    selectedAudio: selectedAudio,
                    icons: icons,
                  );
                } else if (currentPage == Page.files) {
                  w = ShareBoxFile(
                    roomUid: widget.currentRoomId,
                    scrollController: scrollController,
                    onClick: (index, path) {
                      setState(() {
                        selectedFiles[index] = !(selectedFiles[index] ?? false);
                        selectedFiles[index]!
                            ? finalSelected[index] = path
                            : finalSelected.remove(index);
                      });
                    },
                    selectedFiles: selectedFiles,
                    resetRoomPageDetails: widget.resetRoomPageDetails,
                    replyMessageId: widget.replyMessageId,
                  );
                } else if (currentPage == Page.gallery) {
                  w = ShareBoxGallery(
                    replyMessageId: widget.replyMessageId,
                    scrollController: scrollController,
                    pop: () {
                      Navigator.pop(context);
                    },
                    roomUid: widget.currentRoomId,
                    resetRoomPageDetails: widget.resetRoomPageDetails,
                  );
                } else if (currentPage == Page.location) {
                  w = AttachLocation(
                    context,
                    widget.currentRoomId,
                  ).showLocation();
                }

                return Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: mainBorder.copyWith(
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.zero,
                    ),
                    color: theme.colorScheme.surfaceVariant,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                          bottom: BOTTOM_BUTTONS_HEIGHT,
                        ),
                        child: AnimatedSwitcher(
                          duration: SLOW_ANIMATION_DURATION,
                          child: w,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          NavigationBar(
                            onDestinationSelected: (index) async {
                              unawaited(_audioPlayer.stop());
                              switch (index) {
                                case 0:
                                  currentPage = Page.gallery;
                                  break;
                                case 1:
                                  currentPage = Page.files;
                                  break;
                                case 2:
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
                                      currentPage = Page.location;
                                      initialChildSize.add(0.6);
                                    }
                                  }
                                  break;
                                case 3:
                                  currentPage = Page.music;
                                  break;
                              }
                              setState(() {});
                            },
                            selectedIndex: selectedIndex(),
                            destinations: <Widget>[
                              NavigationDestination(
                                icon: const Icon(CupertinoIcons.photo),
                                label: i18n.get("gallery"),
                              ),
                              NavigationDestination(
                                icon: const Icon(CupertinoIcons.folder),
                                label: i18n.get("file"),
                              ),
                              NavigationDestination(
                                icon: const Icon(CupertinoIcons.location_solid),
                                label: i18n.get("location"),
                              ),
                              NavigationDestination(
                                icon: const Icon(CupertinoIcons.music_note),
                                label: i18n.get("music"),
                              ),
                            ],
                          ),
                          // if (isSelected())
                          //   Padding(
                          //     padding: EdgeInsets.only(
                          //       bottom:
                          //           MediaQuery.of(context).viewInsets.bottom,
                          //     ),
                          //     child: SizedBox(
                          //       height: BOTTOM_BUTTONS_HEIGHT,
                          //       child: BuildInputCaption(
                          //         insertCaption: _insertCaption,
                          //         count: finalSelected.length,
                          //         send: () {
                          //           _audioPlayer.stop();
                          //           Navigator.pop(co);
                          //           // messageRepo.sendMultipleFilesMessages(
                          //           //   widget.currentRoomId,
                          //           //   finalSelected.values
                          //           //       .toList()
                          //           //       .map(
                          //           //         (path) => model.File(
                          //           //           path,
                          //           //           path.split("/").last,
                          //           //         ),
                          //           //       )
                          //           //       .toList(),
                          //           //   replyToId: widget.replyMessageId,
                          //           //   caption: _captionEditingController.text,
                          //           // );
                          //           final files = finalSelected.values
                          //               .toList()
                          //               .map(
                          //                 (path) => model.File(
                          //                   path,
                          //                   path.split("/").last,
                          //                   size: File(path).lengthSync(),
                          //                 ),
                          //               )
                          //               .toList();
                          //           showCaptionDialog(files: files);
                          //           setState(() {
                          //             finalSelected.clear();
                          //             selectedAudio.clear();
                          //             selectedImages.clear();
                          //             selectedFiles.clear();
                          //           });
                          //         },
                          //         captionEditingController:
                          //             _captionEditingController,
                          //       ),
                          //     ),
                          //   ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  int selectedIndex() {
    return currentPage == Page.gallery
        ? 0
        : currentPage == Page.files
            ? 1
            : currentPage == Page.location
                ? 2
                : 3;
  }

  bool isSelected() => finalSelected.values.isNotEmpty;

  int get _replyMessageId => widget.replyMessageId;

  void showCaptionDialog({
    IconData? icons,
    String? type,
    required List<model.File> files,
  }) {
    if (files.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return ShowCaptionDialog(
          resetRoomPageDetails: widget.resetRoomPageDetails,
          replyMessageId: _replyMessageId,
          files: files,
          currentRoom: widget.currentRoomId,
        );
      },
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
