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
  final Function onClick;
  final Map<int, bool> selectedFiles;
  final Uid roomUid;

  const ShareBoxFile(
      {Key? key,
      required this.scrollController,
      required this.onClick,
      required this.roomUid,
      required this.selectedFiles})
      : super(key: key);

  @override
  _ShareBoxFileState createState() => _ShareBoxFileState();
}

class _ShareBoxFileState extends State<ShareBoxFile> {
  // ignore: prefer_typing_uninitialized_variables
  late var _future;

  @override
  void initState() {
    _future = FileItem.getFiles();
    super.initState();
  }

  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: _future,
        builder: (context, files) {
          if (files.hasData) {
            return ListView.builder(
                controller: widget.scrollController,
                itemCount: files.data!.length + 1,
                itemBuilder: (ctx, index) {
                  if (index == 0) {
                    return GestureDetector(
                      child: Text(_i18n.get("choose_other_files")),
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(allowMultiple: true);
                        if (result != null && result.files.isNotEmpty) {
                          showCaptionDialog(
                              roomUid: widget.roomUid,
                              context: context,
                              files: result.files
                                  .map((e) => File(e.path!, e.name))
                                  .toList());
                        }
                      },
                    );
                  } else {
                    var fileItem = files.data![index];
                    var selected = widget.selectedFiles[index] ?? false;

                    return GestureDetector(
                      child: Container(
                        color: selected ? Colors.black12 : Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(
                                Icons.insert_drive_file,
                                color: Colors.deepOrange,
                                size: 33,
                              ),
                              onPressed: () => widget.onClick(index, fileItem),
                            ),
                            const SizedBox(
                              width: 22,
                            ),
                            Flexible(
                              child: Text(
                                fileItem.split("/").last,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () => widget.onClick(index, fileItem),
                    );
                  }
                });
          }
          return const SizedBox.shrink();
        });
  }
}
