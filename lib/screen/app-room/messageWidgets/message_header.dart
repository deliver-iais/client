import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/circular_file_status_indicator.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/header_details.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as filePb;
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:deliver_flutter/shared/methods/isPersian.dart';
import 'package:get_it/get_it.dart';

class MessageHeader extends StatefulWidget {
  final Message message;
  final double maxWidth;

  MessageHeader({Key key, this.message, this.maxWidth}) : super(key: key);

  @override
  _MessageHeaderState createState() => _MessageHeaderState();
}

class _MessageHeaderState extends State<MessageHeader> {
  filePb.File file;
  bool isDownloaded = false;
  double loadProgress = 0.0;
  PendingMessageDao pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  var fileRepo = GetIt.I.get<FileRepo>();
  var _accountRpo = GetIt.I.get<AccountRepo>();

  download(String uuid, String name) async {
    await GetIt.I.get<FileRepo>().getFile(uuid, name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    file = widget.message.json.toFile();
    return StreamBuilder<List<PendingMessage>>(
      stream: pendingMessageDao.getByMessageDbId(widget.message.dbId),
      builder: (context, pendingMessage) {
        return FutureBuilder<bool>(
            future: fileRepo.isExist(file.uuid, file.name),
            builder: (context, isExist) {
              if (isExist.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: file.name.isPersian()
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      CircularFileStatusIndicator(
                        isExist: widget.message.from != _accountRpo.currentUserUid && isExist.data | isDownloaded == true,
                        sendingStatus: pendingMessage.data != null
                            ? (pendingMessage.data).status
                            : null,
                        file: file,
                        messageDbId: widget.message.packetId,
                        onPressed: download,
                      ),
                      //TODO width
                      Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Container(
                              width: 175,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 155,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: Text(
                                        file.name,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.more_vert,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //TODO handle download progress
                          HeaderDetails(
                              loadStatus: 'loaded',
                              loadProgress: loadProgress,
                              file: file),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return CircularProgressIndicator(
                    backgroundColor: Colors.purple);
              }
            });
      },
    );
  }
}
