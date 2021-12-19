import 'package:deliver/screen/room/widgets/share_box/helper_classes.dart';
import 'package:flutter/material.dart';

class ShareBoxFile extends StatefulWidget {
  final ScrollController scrollController;
  final Function onClick;
  final Map<int, bool> selectedFiles;

  const ShareBoxFile(
      {Key? key,
      required this.scrollController,
      required this.onClick,
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: _future,
        builder: (context, files) {
          if (files.hasData) {
            return ListView.builder(
                controller: widget.scrollController,
                itemCount: files.data!.length,
                itemBuilder: (ctx, index) {
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
                    onTap: () =>
                        widget.onClick(index, fileItem),
                  );
                });
          }
          return const SizedBox.shrink();
        });
  }
}
