import 'dart:io';

import 'package:clock/clock.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/widgets/edit_image/paint_on_image/_paint_over_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class PaintOnImagePage extends StatefulWidget {
  final File file;
  final Function(String) onDone;

  const PaintOnImagePage({super.key, required this.file, required this.onDone});

  @override
  State<PaintOnImagePage> createState() => _PaintOnImagePageState();
}

class _PaintOnImagePageState extends State<PaintOnImagePage> {
  final _fileServices = GetIt.I.get<FileService>();
  final _i18n = GetIt.I.get<I18N>();
  final _imageKey = GlobalKey<ImagePainterState>();

  bool _showLoading = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white, //change your color here
          ),
          backgroundColor: Colors.black.withAlpha(120),
          title: Text(
            _i18n.get("paint_on_image"),
            style: const TextStyle(color: Colors.white),
          ),
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
        body: Container(
          color: Colors.black,
          child: _showLoading
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
        ),
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
