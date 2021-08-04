import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/circular_file_status_indicator.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/header_details.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/methods/isPersian.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';
import 'package:get_it/get_it.dart';

class UnknownFileUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;
  final bool isSeen;

  UnknownFileUi(
      {Key key, this.message, this.maxWidth, this.isSender, this.isSeen})
      : super(key: key);

  @override
  _UnknownFileUiState createState() => _UnknownFileUiState();
}

class _UnknownFileUiState extends State<UnknownFileUi> {
  var fileRepo = GetIt.I.get<FileRepo>();

  download(String uuid, String name) async {
    await GetIt.I.get<FileRepo>().getFile(uuid, name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var file = widget.message.json.toFile();
    return FutureBuilder<bool>(
        future: fileRepo.isExist(file.uuid, file.name),
        builder: (context, isExist) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: file.name.isPersian()
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                CircularFileStatusIndicator(
                  isExist: isExist.data,
                  file: file,
                  msg: widget.message,
                  onPressed: download,
                ),
                Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Container(
                        width: 175,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 155,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  file.name,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          ExtraTheme.of(context).textMessage),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    HeaderDetails(file: file),
                    file.caption.isEmpty
                        ? TimeAndSeenStatus(widget.message, widget.isSender,
                            false, widget.isSeen)
                        : Container(),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
