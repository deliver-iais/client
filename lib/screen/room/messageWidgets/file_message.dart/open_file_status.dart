import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';


class OpenFileStatus extends StatelessWidget {
  final file_pb.File file;
  final String filePath;
  final Color backgroundColor;
  final Color foregroundColor;
  static final _fileRepo = GetIt.I.get<FileRepo>();

  const OpenFileStatus({
    super.key,
    required this.file,
    required this.filePath,
    required this.backgroundColor,
    required this.foregroundColor,
  });

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
        icon: Icon(
          CupertinoIcons.folder_open,
          color: foregroundColor,
          size: 27,
        ),
        onPressed: ()=>
          _fileRepo.openFile(filePath,),
      ),
    );
  }
}
