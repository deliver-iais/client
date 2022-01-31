import 'dart:convert';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaQueryRepo.dart';
import 'package:deliver/screen/profile/widgets/thumbnail_video_ui.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class VideoTabUi extends StatefulWidget {
  final Uid userUid;
  final int videoCount;

  const VideoTabUi({Key? key, required this.userUid, required this.videoCount})
      : super(key: key);

  @override
  _VideoTabUiState createState() => _VideoTabUiState();
}

class _VideoTabUiState extends State<VideoTabUi> {
  final mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  final fileRepo = GetIt.I.get<FileRepo>();
  late Duration duration;
  late String videoLength;
  Map<int, String> totalDuration = {};

  @override
  Widget build(BuildContext context) {
    var extraThemeData = ExtraTheme.of(context);
    return FutureBuilder<List<Media>>(
        future: mediaQueryRepo.getMedia(
            widget.userUid, MediaType.VIDEO, widget.videoCount),
        builder: (BuildContext c, snaps) {
          if (!snaps.hasData ||
              snaps.data == null ||
              snaps.connectionState == ConnectionState.waiting) {
            return const SizedBox(width: 0.0, height: 0.0);
          } else {
            return GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: snaps.data!.length,
                scrollDirection: Axis.vertical,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, position) {
                  var fileId = jsonDecode(snaps.data![position].json)["uuid"];
                  var fileName = jsonDecode(snaps.data![position].json)["name"];
                  var videoDuration =
                      jsonDecode(snaps.data![position].json)["duration"];
                  duration = Duration(seconds: videoDuration.round());
                  if (duration.inHours == 0) {
                    videoLength = duration.inMinutes > 9
                        ? duration.toString().substring(2, 7)
                        : duration.toString().substring(3, 7);
                    totalDuration[position] = videoLength;
                  } else {
                    videoLength =
                        duration.toString().split('.').first.padLeft(8, "0");
                    totalDuration[position] = videoLength;
                  }

                  return FutureBuilder<String?>(
                      future: fileRepo.getFileIfExist(fileId, fileName),
                      builder: (BuildContext c, isExit) {
                        if (isExit.hasData &&
                            isExit.connectionState == ConnectionState.done) {
                          return VideoWidget(
                            userUid: widget.userUid,
                            thumbnail: isExit.data!,
                            videoCount: widget.videoCount,
                            isExist: isExit.data != null,
                            mediaPosition: position,
                            videoLength: totalDuration[position]!,
                          );
                        } else {
                          return LoadFileStatus(
                            fileId: fileId,
                            fileName: fileName,
                            onPressed: (fId, fName) async {
                              await fileRepo.getFile(fileId, fileName);
                              setState(() {});
                            },
                            background:
                                extraThemeData.colorScheme.primaryContainer,
                            foreground:
                                extraThemeData.colorScheme.onPrimaryContainer,
                          );
                        }
                      });
                });
          }
        });
  }
}
