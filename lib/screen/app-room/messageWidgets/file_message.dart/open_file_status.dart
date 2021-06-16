import 'dart:io';

import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as filePb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';

class OpenFileStatus extends StatelessWidget {
  final filePb.File file;
  final int dbId;

  const OpenFileStatus({Key key, this.file, this.dbId}) : super(key: key);

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
      child: FutureBuilder<File>(
          future: fileRepo.getFile(file.uuid, file.name),
          builder: (context, snapshot) {
            return IconButton(
              padding: EdgeInsets.all(0),
              alignment: Alignment.center,
              icon: Icon(
                Icons.insert_drive_file,
                color: ExtraTheme.of(context).fileMessageDetails,
                size: 33,
              ),
              onPressed: () {
                if (snapshot.hasData) {
                  OpenFile.open(snapshot.data.path);
                }
              },
            );
          }),
    );
  }
}
