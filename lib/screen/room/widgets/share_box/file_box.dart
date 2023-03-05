import 'dart:io' as io;
import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as file_model;
import 'package:deliver/screen/room/widgets/share_box/file_box_item.dart';
import 'package:deliver/screen/room/widgets/show_caption_dialog.dart';
import 'package:deliver/services/ext_storage_services.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

class FilesBox extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(int, file_model.File) onClick;
  final Map<int, bool> selectedFiles;
  final Uid roomUid;
  final void Function() resetRoomPageDetails;
  final int replyMessageId;

  const FilesBox({
    super.key,
    required this.scrollController,
    required this.onClick,
    required this.roomUid,
    required this.selectedFiles,
    required this.resetRoomPageDetails,
    required this.replyMessageId,
  });

  @override
  FilesBoxState createState() => FilesBoxState();
}

class FilesBoxState extends State<FilesBox> {
  Future<List<io.FileSystemEntity>> getRecentFile() async {
    final files = <io.FileSystemEntity>[];
    final d = isIOSNative
        ? await getLibraryDirectory()
        : io.Directory(
            (await ExtStorage.getExternalStoragePublicDirectory(
              ExtStorage.download,
            ))!,
          );
    final l = d.listSync();
    for (final file in l) {
      if (io.FileSystemEntity.isFileSync(file.path)) {
        files.add(file);
      }
    }
    files.sort(
      (a, b) => io.File(a.path)
          .lastAccessedSync()
          .compareTo(io.File(b.path).lastAccessedSync()),
    );
    return files.reversed.toList();
  }

  static final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<io.FileSystemEntity>>(
      future: getRecentFile(),
      builder: (context, files) {
        if (files.hasData && files.data != null) {
          return ListView.builder(
            controller: widget.scrollController,
            itemCount: files.data!.length + 1,
            itemBuilder: (ctx, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.only(top: 16.0, right: 8, left: 8),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform
                              .pickFiles(allowMultiple: true);

                          final files = (result?.files ?? []).map(
                            filePickerPlatformFileToFileModel,
                          );
                          if (result != null && result.files.isNotEmpty) {
                            if (mounted) {
                              Navigator.pop(context);
                            }
                            if (context.mounted) {
                              showCaptionDialog(
                                resetRoomPageDetails:
                                    widget.resetRoomPageDetails,
                                replyMessageId: widget.replyMessageId,
                                roomUid: widget.roomUid,
                                context: context,
                                files: files.toList(),
                              );
                            }
                          }
                        },
                        icon: Icon(
                          CupertinoIcons.square_stack_3d_up_fill,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 28,
                        ),
                        label: Text(
                          _i18n.get("storage"),
                          style: TextStyle(
                            fontSize: 17,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    if (!isIOSNative)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _i18n.get("recent_files"),
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      )
                  ],
                );
              } else {
                final fileItem = File(files.data![index - 1].path);
                final selected = widget.selectedFiles[index - 1] ?? false;

                return GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    color:
                        selected ? theme.primaryColor.withOpacity(0.3) : null,
                    child: Column(
                      children: [
                        FileBoxItem(
                          file: fileItem,
                        ),
                        const Divider()
                      ],
                    ),
                  ),
                  onTap: () {
                    widget.onClick(index - 1, fileToFileModel(fileItem));
                  },
                );
              }
            },
          );
        }
        return Center(
          child: CircularProgressIndicator(
            color: theme.primaryColor,
          ),
        );
      },
    );
  }
}
