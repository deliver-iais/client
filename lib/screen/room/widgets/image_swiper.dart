import 'dart:io';

import 'package:deliver/shared/widgets/bot_appbar_title.dart';
import 'package:deliver/shared/widgets/muc_appbar_title.dart';
import 'package:deliver/shared/widgets/user_appbar_title.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaQueryRepo.dart';
import 'package:deliver/repository/messageRepo.dart';

import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/extra_theme.dart';

class ImageSwiper extends StatefulWidget {
  final Message message;

  const ImageSwiper({Key? key, required this.message}) : super(key: key);

  @override
  _ImageSwiperState createState() => _ImageSwiperState();
}

class _ImageSwiperState extends State<ImageSwiper> {
  static final _mediaRepo = GetIt.I.get<MediaQueryRepo>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _fileRepo = GetIt.I.get<FileRepo>();

  final BehaviorSubject<int> _imageIndex = BehaviorSubject.seeded(-1);
  final BehaviorSubject<int> imageCount = BehaviorSubject.seeded(1);

  @override
  void initState() {
    getImageCount();
    super.initState();
  }

  getImageCount() async {
    var res =
        await _mediaRepo.getImageMediaCount(widget.message.roomUid.asUid());
    if (res != null) imageCount.add(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: title(),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            Navigator.pop(context);
          },
          child: InteractiveViewer(child: defaultWidget()),
        ));
  }

  Widget defaultWidget() {
    return Hero(
      tag: "${widget.message.id}-${widget.message.json!.toFile().uuid}",
      child: FutureBuilder<String?>(
          future: _fileRepo.getFile(widget.message.json!.toFile().uuid,
              widget.message.json!.toFile().name),
          builder: (c, path) {
            if (path.hasData && path.data != null) {
              return buildImageUi(
                  context,
                  path.data,
                  widget.message.id,
                  widget.message.json!.toFile().width.toDouble(),
                  widget.message.json!.toFile().height.toDouble());
            } else {
              return const SizedBox.shrink();
            }
          }),
    );
  }

  Widget buildImageUi(BuildContext context, String? path, int? messageId,
      double width, double height) {
    return Stack(
      children: [
        Positioned(
          child: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: kIsWeb
                  ? Image.network(
                      path!,
                      width: width,
                      height: height,
                    )
                  : Image.file(
                      File(path!),
                    ),
            ),
          ),
          bottom: 50,
          left: 10,
          right: 10,
          top: 5,
        ),
        // Flexible(
        //     flex: 3,
        //     child: Positioned(child: imageCaptionWidget(messageId), bottom: 40))
      ],
    );
  }

  Widget imageCaptionWidget(int messageId) {
    return FutureBuilder<Message?>(
        future: _messageRepo.getMessage(widget.message.roomUid, messageId),
        builder: (c, mes) {
          if (mes.hasData &&
              mes.data != null &&
              mes.data!.json!.toFile().caption.isNotEmpty) {
            return Text(
              mes.data!.json!.toFile().caption,
              overflow: TextOverflow.fade,
              style: TextStyle(
                  color: ExtraTheme.of(context).textField, fontSize: 20),
            );
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  Widget title() {
    return StreamBuilder<int>(
        stream: _imageIndex.stream,
        builder: (c, s) {
          if (s.hasData && s.data! > -1) {
            return Text("${s.data! + 1} of ${imageCount.value}");
          } else {
            var roomUid = widget.message.roomUid.asUid();
            if (roomUid.isMuc()) {
              return MucAppbarTitle(mucUid: roomUid.asString());
            } else if (roomUid.category == Categories.BOT) {
              return BotAppbarTitle(botUid: roomUid);
            } else {
              return UserAppbarTitle(
                userUid: roomUid,
              );
            }
          }
        });
  }
}
