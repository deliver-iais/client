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
  final _keyboardVisibilityController = KeyboardVisibilityController();
  final TextEditingController _captionEditingController =
      TextEditingController();

  int playAudioIndex = -1;

  bool selected = false;
  TextEditingController captionTextController = TextEditingController();

  BehaviorSubject<double> initialChildSize = BehaviorSubject.seeded(0.5);

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
    return StreamBuilder<double>(
      stream: initialChildSize,
      builder: (c, initialSize) {
        if (initialSize.hasData && initialSize.data != null) {
          return DraggableScrollableSheet(
            initialChildSize: initialSize.data!,
            minChildSize: initialSize.data!,
            builder: (co, scrollController) {
              return Container(
                color: theme.colorScheme.background,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: !isSelected()
                          ? const EdgeInsetsDirectional.only(bottom: 70)
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
                              bottom: MediaQuery.of(context).viewInsets.bottom,
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  40,
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
                                  40,
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
                                  40,
                                  context: co,
                                ),
                                circleButton(
                                  () async {
                                    setState(() {
                                      currentPage = Page.music;
                                    });
                                  },
                                  Icons.music_note_rounded,
                                  i18n.get("music"),
                                  40,
                                  context: co,
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
      },
    );
  }

  bool isSelected() => finalSelected.values.isNotEmpty;
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

Widget circleButton(
  Function() onTap,
  IconData icon,
  String text,
  double size, {
  required BuildContext context,
}) {
  final theme = Theme.of(context);
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      ClipOval(
        child: Material(
          color: theme.primaryColor, // button color
          child: InkWell(
            splashColor: theme.shadowColor.withOpacity(0.3),
            onTap: onTap, // inkwell color
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      Text(
        text,
        style: const TextStyle(fontSize: 10),
      ),
    ],
  );
}
