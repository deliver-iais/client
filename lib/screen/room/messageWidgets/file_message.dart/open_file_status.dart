import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:universal_html/html.dart' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart';

class OpenFileStatus extends StatelessWidget {
  final file_pb.File file;

  const OpenFileStatus({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var fileRepo = GetIt.I.get<FileRepo>();

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ExtraTheme.of(context).circularFileStatus,
      ),
      child: FutureBuilder<String?>(
          future: fileRepo.getFile(file.uuid, file.name),
          builder: (context, snapshot) {
            return IconButton(
              padding: const EdgeInsets.all(0),
              alignment: Alignment.center,
              icon: Icon(
                Icons.insert_drive_file,
                color: ExtraTheme.of(context).fileMessageDetails,
                size: 33,
              ),
              onPressed: () {
                if (snapshot.hasData) {
                  if (kIsWeb) {

                    var blob = html.Blob(<Object>[snapshot.data!],
                        "application/${file.name.split(".").last}");
                    var url = html.Url.createObjectUrlFromBlob(blob);
                    print(url.substring(5).toString());
                    window.open(url.substring(5), "_blank");
                  } else {
                    OpenFile.open(snapshot.data!);
                  }
                }
              },
            );
          }),
    );
  }
}
