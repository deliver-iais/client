import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/room/widgets/share_box/helper_classes.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShareBoxFile extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(int, String) onClick;
  final Map<int, bool> selectedFiles;
  final Uid roomUid;
  final void Function() resetRoomPageDetails;
  final int replyMessageId;

  const ShareBoxFile({
    super.key,
    required this.scrollController,
    required this.onClick,
    required this.roomUid,
    required this.selectedFiles,
    required this.resetRoomPageDetails,
    required this.replyMessageId,
  });

  @override
  ShareBoxFileState createState() => ShareBoxFileState();
}

class ShareBoxFileState extends State<ShareBoxFile> {
  // ignore: prefer_typing_uninitialized_variables
  late var _future;

  @override
  void initState() {
    _future = FileItem.getFiles();
    super.initState();
  }

  static final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<String>>(
      future: _future,
      builder: (context, files) {
        if (files.hasData && files.data != null) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: widget.selectedFiles.values.isNotEmpty ? 50 : 0,
            ),
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: files.data!.length + 1,
              itemBuilder: (ctx, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outlined,
                            color: theme.primaryColor,
                            size: 39,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            _i18n.get("choose_other_files"),
                            style: const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        final result = await FilePicker.platform
                            .pickFiles(allowMultiple: true);
                        if (result != null && result.files.isNotEmpty) {
                          if (mounted) {
                            Navigator.pop(context);
                          }
                          showCaptionDialog(
                            resetRoomPageDetails: widget.resetRoomPageDetails,
                            replyMessageId: widget.replyMessageId,
                            roomUid: widget.roomUid,
                            context: context,
                            files: result.files
                                .map(
                                  (e) => File(
                                    e.path!,
                                    e.name,
                                    size: e.size,
                                    extension: e.extension,
                                  ),
                                )
                                .toList(),
                          );
                        }
                      },
                    ),
                  );
                } else {
                  final fileItem = files.data![index - 1];
                  final selected = widget.selectedFiles[index - 1] ?? false;

                  return GestureDetector(
                    child: Container(
                      color: selected ? Colors.black12 : Colors.white,
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.insert_drive_file,
                              color: theme.primaryColor,
                              size: 33,
                            ),
                            onPressed: () =>
                                widget.onClick(index - 1, fileItem),
                          ),
                          const SizedBox(
                            width: 22,
                          ),
                          Flexible(
                            child: Text(
                              fileItem.split("/").last,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => widget.onClick(index - 1, fileItem),
                  );
                }
              },
            ),
          );
        }
        return CircularProgressIndicator(
          color: theme.primaryColor,
        );
      },
    );
  }
}
