import 'dart:io';

import 'package:clock/clock.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/widgets/edit_image/paint_on_image/_paint_over_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final _imageKey = GlobalKey<ImagePainterState>();

class PaintOnImagePage extends StatefulWidget {
  final File file;
  final Function(String) onDone;

  const PaintOnImagePage({Key? key, required this.file, required this.onDone})
      : super(key: key);

  @override
  State<PaintOnImagePage> createState() => _PaintOnImagePageState();
}

class _PaintOnImagePageState extends State<PaintOnImagePage> {
  final _fileServices = GetIt.I.get<FileService>();
  bool _showLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paint on Image"),
        actions: [
          if (!_showLoading)
            IconButton(
              icon: const Icon(Icons.done_rounded),
              onPressed: () async {
                await saveImage(context);
              },
            )
        ],
      ),
      body: _showLoading
          ? const Center(child: CircularProgressIndicator())
          : ImagePainter.file(
              widget.file,
              key: _imageKey,
              scalable: true,
              onDone: () async {
                await saveImage(context);
              },
              initialColor: Colors.red,
              initialPaintMode: PaintMode.freeStyle,
            ),
    );
  }

  Future<void> saveImage(BuildContext context) async {
    setState(() {
      _showLoading = true;
    });
    final image = await _imageKey.currentState!.exportImage();
    final outPutFile = await _fileServices.localFile(
      "_draw-${clock.now().millisecondsSinceEpoch}",
      widget.file.path.split(".").last,
    );
    outPutFile.writeAsBytesSync(image!);
    widget.onDone(outPutFile.path);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    setState(() {
      _showLoading = false;
    });
  }
}
