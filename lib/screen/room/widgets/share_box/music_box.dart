import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as file_model;
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'helper_classes.dart';

class MusicBox extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(int, file_model.File) onClick;
  final Map<int, bool> selectedAudio;
  final Map<int, bool> isPlaying;
  final void Function(int, String) playMusic;

  const MusicBox({
    super.key,
    required this.scrollController,
    required this.onClick,
    required this.playMusic,
    required this.isPlaying,
    required this.selectedAudio,
  });

  @override
  MusicBoxState createState() => MusicBoxState();
}

class MusicBoxState extends State<MusicBox> {
  static final _i18n = GetIt.I.get<I18N>();
  static final _checkPermissionServices =
      GetIt.I.get<CheckPermissionsService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<bool>(
      initialData: false,
      future: _checkPermissionServices.checkMediaLibraryPermission(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!) {
          return FutureBuilder<List<File>?>(
            future: AudioItem.getAudios(),
            builder: (context, audios) {
              if (audios.hasData) {
                return ListView.separated(
                  controller: widget.scrollController,
                  itemCount: audios.data!.length,
                  itemBuilder: (ctx, index) {
                    final fileItem = audios.data![index];

                    final fileModel = fileToFileModel(fileItem);

                    final isItemSelected = widget.selectedAudio[index] ?? false;

                    return InkWell(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          top: index == 0 ? 16 : 8,
                        ),
                        color: isItemSelected
                            ? theme.colorScheme.primaryContainer
                                .withOpacity(0.4)
                            : null,
                        child: Row(
                          children: <Widget>[
                            const SizedBox(width: 4),
                            IconButton(
                              iconSize: 32,
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.onTertiaryContainer,
                                foregroundColor: theme.colorScheme.onTertiary,
                              ),
                              icon: Icon(
                                (widget.isPlaying[index] ?? false)
                                    ? CupertinoIcons.pause
                                    : CupertinoIcons.play,
                              ),
                              onPressed: () =>
                                  widget.playMusic(index, fileItem.path),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileModel.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                  ),
                                  Text(
                                    byteFormat(fileModel.size ?? 0),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () async {
                        final file = fileToFileModel(fileItem);

                        final notAcceptableFile = getNotAcceptableFiles([file]);

                        if (notAcceptableFile.isNotEmpty) {
                          final naf = notAcceptableFile.first;

                          final errorText = naf.hasNotAcceptableExtension
                              ? _i18n.get("cant_sent")
                              : naf.isEmpty
                                  ? _i18n.get("file_size_zero")
                                  : _i18n.get("file_size_error");

                          ToastDisplay.showToast(
                            toastText: errorText,
                            toastContext: context,
                          );
                        } else {
                          widget.onClick(index, file);
                        }
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Divider(),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
