import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:we/box/media.dart';
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
  final Message message;

  ImageSwiper({Key key, this.message}) : super(key: key);

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
    getImageCount();
  }

  getImageCount() async {
    var res =
        await _mediaRepo.getImageMediaCount(widget.message.roomUid.asUid());
    if (res != null) imageCount.add(res);
  }

  @override
  Widget build(BuildContext context) {
    double defWidth = MediaQuery.of(context).size.width;
    double defHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          leading: _routingServices.backButtonLeading(),
          title: title(),
        ),
        body: InteractiveViewer(
            child: FutureBuilder(
          future: _mediaRepo.getImageMediaCount(widget.message.roomUid.asUid()),
          builder: (c, imageCountData) {
            if (imageCountData.hasData &&
                imageCountData.data != null &&
                imageCountData.data > 0) {
              imageCount.add(imageCountData.data);
              return FutureBuilder<List<Media>>(
                  future: _mediaRepo.getMedia(widget.message.roomUid.asUid(),
                      MediaType.IMAGE, imageCountData.data,
                      messageId: widget.message.id),
                  builder: (c, medias) {
                    if (medias.hasData &&
                        medias.data != null &&
                        medias.data.length > 0) {
                      var initIndex = medias.data.indexWhere(
                          (element) => element.messageId == widget.message.id);
                      if (initIndex != -1) _imageIndex.add(initIndex);
                      return Swiper(
                        itemCount: imageCountData.data,
                        onIndexChanged: (index) {
                          _imageIndex.add(index);
                        },
                        index: initIndex,
                        itemBuilder: (c, i) {
                          if (medias.data.length>= i && medias.data[i] != null) {
                            double width = double.parse(
                                    jsonDecode(medias.data[i].json)["width"]
                                        .toString()) ??
                                defWidth;
                            double height = double.parse(
                                    jsonDecode(medias.data[i].json)["height"]
                                        .toString()) ??
                                defHeight;

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
                                      medias.data[i].messageId,
                                      min(width, defWidth),
                                      min(height, defHeight));
                                } else
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ),
                                  );
                              },
                            );
                          } else {
                            return Center(
                                child: CircularProgressIndicator(
                              color: Colors.blue,
                            ));
                          }
                        },
                      );
                    } else
                      return defaultWidget();
                  });
            } else
              return defaultWidget();
          },
        )));
  }

  Widget defaultWidget() {
    return FutureBuilder<File>(
        future: _fileRepo.getFile(widget.message.json.toFile().uuid,
            widget.message.json.toFile().name),
        builder: (c, file) {
          if (file.hasData && file.data != null)
            return buildImageUi(
                context,
                file.data,
                widget.message.id,
                widget.message.json.toFile().width.toDouble(),
                widget.message.json.toFile().height.toDouble());
          else
            return SizedBox.shrink();
        });
  }

  Widget buildImageUi(BuildContext context, File file, int messageId,
      double width, double height) {
    return Stack(
      children: [
        Positioned(
          child: Center(
            child: Container(
              width: width,
              height: height,
              child: Image.file(
                file,
              ),
            ),
          ),
          bottom: 50,
          left: 10,
          right: 10,
          top: 5,
        ),
        Positioned(child: imageCaptionWidget(messageId), bottom: 40)
      ],
    );
  }

  Widget imageCaptionWidget(int messageId) {
    return FutureBuilder<Message>(
        future: _messageRepo.getMessage(widget.message.roomUid, messageId),
        builder: (c, mes) {
          if (mes.hasData &&
              mes.data != null &&
              mes.data.json.toFile().caption.isNotEmpty) {
            return Text(
              mes.data.json.toFile().caption,
              overflow: TextOverflow.fade,
              style: TextStyle(
                  color: ExtraTheme.of(context).textField, fontSize: 20),
            );
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
            return Text("");
        });
  }
}
