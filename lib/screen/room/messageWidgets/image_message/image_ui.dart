import 'dart:html' as html;
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as filePb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:rxdart/rxdart.dart';

class ImageUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;
  final bool isSeen;

  const ImageUi(
      {Key key, this.message, this.maxWidth, this.isSender, this.isSeen})
      : super(key: key);

  @override
  _ImageUiState createState() => _ImageUiState();
}

class _ImageUiState extends State<ImageUi> {
  var _fileRepo = GetIt.I.get<FileRepo>();
  var _routingServices = GetIt.I.get<RoutingService>();
  var _i18n = GetIt.I.get<I18N>();
  filePb.File _image;
  BehaviorSubject<bool> _startDownload = BehaviorSubject.seeded(false);
  String _path = "";

  @override
  Widget build(BuildContext context) {
    double width = widget.maxWidth;
    double height = widget.maxWidth;

    const radius = const Radius.circular(12);
    const border = const BorderRadius.all(radius);

    try {
      _image = widget.message.json.toFile();

      var dimensions =
          getImageDimensions(_image.width.toDouble(), _image.height.toDouble());
      width = dimensions.width;
      height = dimensions.height;

      return ClipRRect(
        borderRadius: border,
        child: FutureBuilder<String>(
            future: _fileRepo.getFileIfExist(_image.uuid, _image.name),
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                getImage(_image.uuid);
                _path = s.data;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _routingServices.showImageInRoom(
                            message: widget.message);
                      },
                      child: kIsWeb
                          ? Image.network(
                              s.data,
                              width: width,
                              height: height,
                            )
                          : Image.file(
                              File(s.data),
                              width: width,
                              height: height,
                              fit: BoxFit.fill,
                            ),
                    ),
                    if (_image.caption.isEmpty)
                      TimeAndSeenStatus(
                          widget.message, widget.isSender, widget.isSeen,
                          needsBackground: true),
                    if (kIsWeb)
                      Positioned(
                          right: 5,
                          top: 2,
                          child: Container(
                              child: PopupMenuButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  onSelected: selectItem,
                                  itemBuilder: (context) => [
                                        PopupMenuItem<String>(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.download_rounded,
                                                size: 16,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                _i18n.get("save_in_downloads"),
                                                style: TextStyle(
                                                    color:
                                                        ExtraTheme.of(context)
                                                            .textField,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          value: "download",
                                        ),
                                      ])))
                  ],
                );
              } else
                return GestureDetector(
                  onTap: () async {
                    _startDownload.add(true);
                    await _fileRepo.getFile(
                      _image.uuid,
                      _image.name,
                    );
                    _startDownload.add(false);
                    setState(() {});
                  },
                  child: Container(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        Container(
                            width: width,
                            height: height,
                            child: BlurHash(hash: _image.blurHash)),
                        Center(
                          child: StreamBuilder(
                            stream: _startDownload.stream,
                            builder: (c, s) {
                              if (s.hasData && s.data) {
                                return CircularProgressIndicator(
                                  strokeWidth: 4,
                                );
                              } else
                                return MaterialButton(
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () async {
                                    _startDownload.add(true);
                                    await _fileRepo.getFile(
                                        _image.uuid, _image.name);
                                    setState(() {
                                      _startDownload.add(false);
                                    });
                                  },
                                  shape: CircleBorder(),
                                  child: Icon(Icons.arrow_downward),
                                  padding: const EdgeInsets.all(20),
                                );
                            },
                          ),
                        ),
                        if (_image.caption.isEmpty)
                          TimeAndSeenStatus(
                              widget.message, widget.isSender, widget.isSeen,
                              needsBackground: true)
                      ],
                    ),
                  ),
                );
            }),
      );
    } catch (e) {
      return Container(
        width: width,
        height: height,
      );
    }
  }

  selectItem(String str) {
    switch (str) {
      case "download":
        _fileRepo.saveDownloadedFile(_path, widget.message.json.toFile().name);
    }
  }

  Size getImageDimensions(double width, double height) {
    double maxWidth = widget.maxWidth;
    if (width == null || width == 0 || height == null || height == 0) {
      width = maxWidth;
      height = maxWidth;
    }
    double aspect = width / height;
    double w = 0;
    double h = 0;
    if (aspect > 1) {
      w = min(width, maxWidth);
      h = w / aspect;
    } else {
      h = min(height, maxWidth);
      w = h * aspect;
    }

    return Size(w, h);
  }

  void getImage(String uuid) async {
    print(html.document.body.children.length);

    var res = html.document.body.children
        .toList()
        .where((element) => element.title == uuid);
  //  var result = html.Url.createObjectUrlFromBlob(res.first.slot as html.Blob);
  //  print(result.toString());
    print(res.first.slot.length);

  }
}
