import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:flutter/cupertino.dart';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart';

class OpenFileStatus extends StatelessWidget {
  final file_pb.File file;
  final String filePath;
  final Color backgroundColor;
  final Color foregroundColor;

  const OpenFileStatus(
      {Key? key,
      required this.file,
      required this.filePath,
      required this.backgroundColor,
      required this.foregroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          icon: Icon(
            CupertinoIcons.folder_open,
            color: foregroundColor,
            size: 27,
          ),
          onPressed: () async {
            if (isWeb) {
              final res = await http.get(Uri.parse(filePath));
              final blob = Blob([res.bodyBytes], file.type);
              final fileUrl = html.Url.createObjectUrl(blob);
              window.open(fileUrl, "_");
            } else {
              OpenFile.open(filePath);
            }
          },
        ));
  }
}
