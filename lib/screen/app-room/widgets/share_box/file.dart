import 'package:flutter/material.dart';

import 'helper_classes.dart';

class ShareBoxFile extends StatefulWidget {
  final ScrollController scrollController;
  final Function onClick;
  final Map<int, bool> selectedFiles;

  const ShareBoxFile(
      {Key key,
      @required this.scrollController,
      @required this.onClick,
      @required this.selectedFiles})
      : super(key: key);

  @override
  _ShareBoxFileState createState() => _ShareBoxFileState();
}

class _ShareBoxFileState extends State<ShareBoxFile> {
  var _future;

  @override
  void initState() {
    _future = FileItem.getFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileItem>>(
        future: _future,
        builder: (context, files) {
          if (files.hasData) {
            return ListView.builder(
                controller: widget.scrollController,
                itemCount: files.data.length,
                itemBuilder: (ctx, index) {
                  var fileItem = files.data[index];
                  var onTap = () => widget.onClick(index, fileItem.path);
                  var selected = widget.selectedFiles[index] ?? false;
                  return GestureDetector(
                    child: Container(
                      color: selected ? Colors.black12 : Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.insert_drive_file,
                              color: Colors.deepOrange,
                              size: 33,
                            ),
                            onPressed: onTap,
                          ),
                          SizedBox(
                            width: 22,
                          ),
                          Flexible(
                            child: Text(
                              fileItem.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: onTap,
                  );
                });
          }
          return SizedBox.shrink();
        });
  }
}
