import 'dart:convert';
import 'dart:io';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:we/box/media.dart';
import 'package:we/box/media_meta_data.dart';
import 'package:we/box/media_type.dart';
import 'package:we/box/message.dart';
import 'package:we/repository/fileRepo.dart';
import 'package:we/repository/mediaQueryRepo.dart';
import 'package:we/repository/messageRepo.dart';

import 'package:we/services/routing_service.dart';
import 'package:we/shared/extensions/uid_extension.dart';
import 'package:we/shared/extensions/json_extension.dart';
import 'package:we/theme/extra_theme.dart';

class ImageSwiper extends StatefulWidget {
  final Uid roomId;
  final int messageId;
  final File image;

  ImageSwiper({Key key, this.roomId, this.messageId, this.image})
      : super(key: key);

  @override
  _ImageSwiperState createState() => _ImageSwiperState();
}

class _ImageSwiperState extends State<ImageSwiper> {
  var _mediaRepo = GetIt.I.get<MediaQueryRepo>();
  var _routingServices = GetIt.I.get<RoutingService>();
  var _messageRepo = GetIt.I.get<MessageRepo>();
  var _fileRepo = GetIt.I.get<FileRepo>();
  BehaviorSubject<int> _imageIndex = BehaviorSubject.seeded(-1);
  BehaviorSubject<int> imageCount = BehaviorSubject.seeded(1);

  @override
  void initState() {
    getMediaCount();
  }

  Future getMediaCount() async {
    await _mediaRepo.getMediaMetaDataReq(widget.roomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget defaultWidget =
        buildImageUi(context, widget.image, widget.messageId);
    return Scaffold(
        appBar: AppBar(
          leading: _routingServices.backButtonLeading(),
          title: title(),
        ),
        body: StreamBuilder<MediaMetaData>(
            stream: _mediaRepo.getMediasMetaDataCountFromDB(widget.roomId),
            builder: (c, s) {
              if (s.hasData && s.data != null && s.data.imagesCount > 0) {
                imageCount.add(s.data.imagesCount);
                return FutureBuilder<List<Media>>(
                    future: _mediaRepo.getMedia(
                        widget.roomId, MediaType.IMAGE, s.data.imagesCount),
                    builder: (c, medias) {
                      if (medias.hasData &&
                          medias.data != null &&
                          medias.data.length > 0 ) {
                        var initIndex = medias.data.indexWhere(
                            (element) => element.messageId == widget.messageId);
                        if (initIndex != -1) _imageIndex.add(initIndex);
                        return Swiper(
                          itemCount: s.data.imagesCount,
                          onIndexChanged: (index) {
                            _imageIndex.add(index);
                          },
                          index: initIndex,
                          itemBuilder: (c, i) {
                            return FutureBuilder<File>(
                              future: _fileRepo.getFile(
                                  jsonDecode(medias.data[i].json)["uuid"],
                                  jsonDecode(medias.data[i].json)["name"]),
                              builder: (c, fileSnapshot) {
                                if (fileSnapshot.hasData &&
                                    fileSnapshot.data != null) {
                                  return buildImageUi(
                                      context,
                                      fileSnapshot.data,
                                      medias.data[i].messageId);
                                } else
                                  return defaultWidget;
                              },
                            );
                          },
                        );
                      } else
                        return defaultWidget;
                    });
              } else
                return defaultWidget;
            }));
  }

  Widget buildImageUi(BuildContext context, File file, int messageId) {
    return Center(
        child: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height - 200,
            child: Image.file(
              file,
            ),
          ),
          imageCaptionWidget(messageId)
        ],
      ),
    ));
  }

  Widget imageCaptionWidget(int messageId) {
    return FutureBuilder<Message>(
        future: _messageRepo.getMessage(widget.roomId.asString(), messageId),
        builder: (c, mes) {
          if (mes.hasData &&
              mes.data != null &&
              mes.data.json.toFile().caption.isNotEmpty) {
            return Expanded(
                child: Text(
              mes.data.json.toFile().caption,
              overflow: TextOverflow.fade,
              style: TextStyle(color: ExtraTheme.of(context).textField),
            ));
          } else
            return SizedBox.shrink();
        });
  }

  Widget title() {
    return StreamBuilder(
        stream: _imageIndex.stream,
        builder: (c, s) {
          if (s.hasData && s.data > -1) {
            return Text("${s.data + 1} of ${imageCount.valueWrapper.value}");
          } else
            return SizedBox.shrink();
        });
  }
}
