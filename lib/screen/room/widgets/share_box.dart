import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as file_model;
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/file_box.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery_box.dart';
import 'package:deliver/screen/room/widgets/share_box/music_box.dart';
import 'package:deliver/screen/room/widgets/share_box/share_box_input_caption.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:deliver/shared/widgets/attach_contact.dart';
import 'package:deliver/shared/widgets/attach_location.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ShareBox extends StatefulWidget {
  final Uid currentRoomUid;
  final int replyMessageId;
  final void Function() resetRoomPageDetails;
  final void Function() scrollToLastSentMessage;

  const ShareBox({
    super.key,
    required this.currentRoomUid,
    this.replyMessageId = 0,
    required this.resetRoomPageDetails,
    required this.scrollToLastSentMessage,
  });

  @override
  ShareBoxState createState() => ShareBoxState();
}

enum ShareBoxPage {
  GALLERY(0, "gallery"),
  FILES(1, "file"),
  LOCATION(2, "location"),
  MUSIC(3, "music"),
  CONTACT(4, "contact");

  final int number;
  final String i18nKey;

  const ShareBoxPage(this.number, this.i18nKey);
}

const BOTTOM_BUTTONS_HEIGHT = 80.0;

class ShareBoxState extends State<ShareBox> {
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _audioPlayer = AudioPlayer();
  final _remainingPixelsStream = BehaviorSubject.seeded(APPBAR_HEIGHT * 2);
  final _draggableScrollableController = DraggableScrollableController();

  final selectedImagesMap = <int, bool>{};

  final selectedAudioMap = <int, bool>{};

  final selectedFilesMap = <int, bool>{};

  final isAudioPlayingMap = <int, bool>{};

  final finalSelected = <int, file_model.File>{};

  var _currentPage = ShareBoxPage.GALLERY;

  int _playAudioIndex = -1;

  @override
  void initState() {
    _draggableScrollableController.addListener(() {
      if (!_draggableScrollableController.isAttached) {
        return;
      }
      final remainingPixels = (_draggableScrollableController.pixels /
              _draggableScrollableController.size) -
          _draggableScrollableController.pixels;

      if (_remainingPixelsStream.valueOrNull != remainingPixels) {
        _remainingPixelsStream.add(remainingPixels);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _draggableScrollableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    final percent =
        min((mq.size.height - (APPBAR_HEIGHT * 2)) / mq.size.height, 0.85);

    final bottomOffset = mq.viewInsets.bottom + mq.padding.bottom;
    return PopScope(
      canPop: !isAnyFileSelected,
      onPopInvoked: (_) {
        if (isAnyFileSelected) {
          setState(() {
            finalSelected.clear();
            selectedAudioMap.clear();
            selectedImagesMap.clear();
            selectedFilesMap.clear();
          });
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: percent,
        controller: _draggableScrollableController,
        builder: (co, scrollController) {
          Widget w = const SizedBox.shrink();
          if (_currentPage == ShareBoxPage.MUSIC) {
            w = MusicBox(
              scrollController: scrollController,
              onClick: (index, fileModel) {
                setState(() {
                  selectedAudioMap[index] = !(selectedAudioMap[index] ?? false);
                  selectedAudioMap[index]!
                      ? finalSelected[index] = fileModel
                      : finalSelected.remove(index);
                });
              },
              playMusic: (index, path) {
                setState(() {
                  if (_playAudioIndex == index) {
                    _audioPlayer.pause();
                    isAudioPlayingMap[index] = false;
                    _playAudioIndex = -1;
                  } else {
                    _audioPlayer.play(DeviceFileSource(path));
                    isAudioPlayingMap.remove(_playAudioIndex);
                    isAudioPlayingMap[index] = true;
                    _playAudioIndex = index;
                  }
                });
              },
              selectedAudio: selectedAudioMap,
              isPlaying: isAudioPlayingMap,
            );
          } else if (_currentPage == ShareBoxPage.FILES) {
            w = FilesBox(
              roomUid: widget.currentRoomUid,
              scrollController: scrollController,
              onClick: (index, fileModel) {
                setState(() {
                  selectedFilesMap[index] = !(selectedFilesMap[index] ?? false);
                  selectedFilesMap[index]!
                      ? finalSelected[index] = fileModel
                      : finalSelected.remove(index);
                });
              },
              selectedFiles: selectedFilesMap,
              resetRoomPageDetails: widget.resetRoomPageDetails,
              replyMessageId: widget.replyMessageId,
            );
          } else if (_currentPage == ShareBoxPage.GALLERY) {
            w = GalleryBox(
              replyMessageId: widget.replyMessageId,
              scrollController: scrollController,
              roomUid: widget.currentRoomUid,
              resetRoomPageDetails: widget.resetRoomPageDetails,
            );
          } else if (_currentPage == ShareBoxPage.LOCATION) {
            w = AttachLocation(
              context,
              widget.currentRoomUid,
            ).showLocation();
          } else if (_currentPage == ShareBoxPage.CONTACT) {
            w = AttachContact(
              roomUid: widget.currentRoomUid,
              scrollController: scrollController,
              pop: () {
                Navigator.pop(context);
              },
            );
          }

          return StreamBuilder<double>(
            stream: _remainingPixelsStream,
            builder: (context, snapshot) {
              final remainingPixels = snapshot.data ?? (2 * APPBAR_HEIGHT);

              final borderRadius = max(
                remainingPixels >= MAIN_BORDER_RADIUS_SIZE
                    ? MAIN_BORDER_RADIUS_SIZE
                    : remainingPixels,
                0.0,
              );

              final topPadding = max(
                (remainingPixels >= (1.8 * APPBAR_HEIGHT))
                    ? 0.0
                    : (APPBAR_HEIGHT - (remainingPixels / 1.8)),
                0.2,
              ).abs();

              final draggableOpacity =
                  minMax(remainingPixels / MAIN_BORDER_RADIUS_SIZE);

              return Container(
                padding: EdgeInsetsDirectional.only(
                  bottom: bottomOffset,
                ),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius),
                  ),
                  color: theme.colorScheme.surfaceVariant,
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: minMax(
                          (MAIN_BORDER_RADIUS_SIZE - borderRadius) /
                              MAIN_BORDER_RADIUS_SIZE,
                        ),
                        child: Container(
                          color: theme.appBarTheme.backgroundColor,
                          height: topPadding,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              end: 20.0,
                              start: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const BackButton(),
                                    if (finalSelected.isNotEmpty) ...[
                                      AnimatedSwitchWidget(
                                        child: Text(
                                          "${finalSelected.length}",
                                          key: ValueKey(finalSelected.length),
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                      Text(
                                        _i18n.get("files_selected"),
                                        style: theme.textTheme.titleMedium,
                                      )
                                    ],
                                  ],
                                ),
                                Text(
                                  _i18n.get(_currentPage.i18nKey).capitalCase,
                                  style: theme.textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsetsDirectional.only(
                        bottom: BOTTOM_BUTTONS_HEIGHT,
                        top: topPadding,
                      ),
                      child: AnimatedSwitcher(
                        duration: AnimationSettings.slow,
                        child: w,
                      ),
                    ),
                    NavigationBar(
                      onDestinationSelected: (index) async {
                        if (_currentPage.index == index) {
                          return;
                        }
                        unawaited(_audioPlayer.stop());
                        switch (index) {
                          case 0:
                            _currentPage = ShareBoxPage.GALLERY;
                            break;
                          case 1:
                            _currentPage = ShareBoxPage.FILES;
                            break;
                          case 2:
                            _currentPage = ShareBoxPage.LOCATION;
                            if (_draggableScrollableController.isAttached) {
                              unawaited(
                                _draggableScrollableController.animateTo(
                                  max(
                                    0.26,
                                    min(
                                      ((80 + BOTTOM_BUTTONS_HEIGHT) /
                                              mq.size.height) +
                                          0.25,
                                      1,
                                    ),
                                  ),
                                  duration: AnimationSettings.slow,
                                  curve: Curves.easeInOut,
                                ),
                              );
                            }
                            break;
                          case 3:
                            _currentPage = ShareBoxPage.MUSIC;
                            break;
                          case 4:
                            _currentPage = ShareBoxPage.CONTACT;
                            break;
                        }
                        setState(() {});
                      },
                      selectedIndex: _currentPage.index,
                      destinations: <Widget>[
                        NavigationDestination(
                          icon: const Icon(CupertinoIcons.photo),
                          label: _i18n.get(ShareBoxPage.GALLERY.i18nKey),
                        ),
                        NavigationDestination(
                          icon: const Icon(CupertinoIcons.folder),
                          label: _i18n.get(ShareBoxPage.FILES.i18nKey),
                        ),
                        NavigationDestination(
                          icon: const Icon(CupertinoIcons.location_solid),
                          label: _i18n.get(ShareBoxPage.LOCATION.i18nKey),
                        ),
                        NavigationDestination(
                          icon: const Icon(CupertinoIcons.music_note),
                          label: _i18n.get(ShareBoxPage.MUSIC.i18nKey),
                        ),
                        NavigationDestination(
                          icon: const Icon(CupertinoIcons.person),
                          label: _i18n.get(ShareBoxPage.CONTACT.i18nKey),
                        ),
                      ],
                    ),
                    AnimatedScale(
                      duration: AnimationSettings.verySlow,
                      curve: Curves.easeInOut,
                      scale: isAnyFileSelected ? 1 : 0,
                      child: AnimatedOpacity(
                        duration: AnimationSettings.slow,
                        curve: Curves.easeInOut,
                        opacity: isAnyFileSelected ? 1 : 0,
                        child: ShareBoxInputCaption(
                          count: finalSelected.length,
                          onSend: (caption) {
                            _audioPlayer.stop();
                            Navigator.pop(co);

                            _messageRepo.sendMultipleFilesMessages(
                              widget.currentRoomUid,
                              finalSelected.values.toList(),
                              replyToId: widget.replyMessageId,
                              caption: caption,
                            );

                            setState(() {
                              finalSelected.clear();
                              selectedAudioMap.clear();
                              selectedImagesMap.clear();
                              selectedFilesMap.clear();
                            });
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: draggableOpacity,
                        child: Container(
                          margin: const EdgeInsetsDirectional.only(top: 6),
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.5),
                            borderRadius: mainBorder,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool get isAnyFileSelected => finalSelected.values.isNotEmpty;

  double minMax(double value) => min(1.0, max(0.0, value));
}
