import 'dart:io';
import 'dart:ui';

import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ImageUi extends StatefulWidget {
  final file.File image;
  final double maxWidth;

  const ImageUi({Key key, this.image, this.maxWidth}) : super(key: key);

  @override
  _ImageUiState createState() => _ImageUiState();
}

class _ImageUiState extends State<ImageUi> {
  bool isDownloaded = false;

  @override
  Widget build(BuildContext context) {
    var fileRepo = GetIt.I.get<FileRepo>();

    return Container(
      child: FutureBuilder<File>(
          future: isDownloaded
              ? fileRepo.getFileThumbnail(
                  ThumbnailSize.medium,
                  'e824a70e-859d-4c73-92be-ccb1ead52fcc',
                  'Screen Shot 1399-03-01 at 05.10.05.png')
              : fileRepo.getFileThumbnail(
                  ThumbnailSize.small,
                  'e824a70e-859d-4c73-92be-ccb1ead52fcc',
                  'Screen Shot 1399-03-01 at 05.10.05.png'),
          builder: (context, file) {
            print(file.error);
            if (file.hasData) {
              return Stack(
                children: [
                  Image.file(
                    file.data,
                    width: 200,
                    height: 300,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: isDownloaded ? 0 : 5,
                        sigmaY: isDownloaded ? 0 : 5),
                    child: Container(
                      color: Colors.black.withOpacity(0),
                    ),
                  ),
                  !isDownloaded
                      ? Center(
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: IconButton(
                              icon: Icon(Icons.file_download),
                              onPressed: () {
                                setState(() {
                                  isDownloaded = true;
                                });
                              },
                            ),
                          ),
                        )
                      : Container()
                ],
              );
            }
            return CircularProgressIndicator();
          }),
    );

    // Container(
    //     constraints:
    //         BoxConstraints.loose(Size(widget.maxWidth, widget.maxWidth * 1.5)),
    //     decoration: BoxDecoration(
    //       image: DecorationImage(
    //         image: NetworkImage(this.widget.image.uuid),
    //         fit: BoxFit.fill,
    //       ),
    //     ),
    //     child: Container(
    //       width: 40,
    //       height: 40,
    //       child: Icon(Icons.arrow_downward),
    //       decoration: BoxDecoration(
    //         shape: BoxShape.circle,
    //         color: Theme.of(context).accentColor,
    //       ),
    //     ));
  }
}
