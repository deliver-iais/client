import 'dart:io';
import 'package:deliver/screen/room/widgets/share_box/edit_image/paint_on_image/_paint_over_image.dart';
import 'package:deliver/services/file_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final _imageKey = GlobalKey<ImagePainterState>();

class PaintOnImage extends StatefulWidget {
  final File file;
  final Function onDone;

  const PaintOnImage({Key? key, required this.file, required this.onDone})
      : super(key: key);

  @override
  State<PaintOnImage> createState() => _PaintOnImageState();
}

class _PaintOnImageState extends State<PaintOnImage> {
  final _fileServices = GetIt.I.get<FileService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ImagePainter.file(
          widget.file,
          key: _imageKey,
          scalable: true,
          initialStrokeWidth: 10,
          onDone: () async {
            await saveImage(context);
          },
          initialColor: Colors.blue,
          initialPaintMode: PaintMode.freeStyle,
        ),
      ),
    );
  }

  Future<void> saveImage(BuildContext context) async {
    final image = await _imageKey.currentState!.exportImage();
    final outPutFile = await _fileServices.localFile(
        "_draw-${DateTime.now().millisecondsSinceEpoch}",
        widget.file.path.split(".").last);
    outPutFile.writeAsBytesSync(image!);
    widget.onDone(outPutFile.path);
    Navigator.pop(context);
  }
}
