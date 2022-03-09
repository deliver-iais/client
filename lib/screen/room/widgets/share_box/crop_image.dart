import 'dart:io';
import 'dart:ui';

import 'package:crop/crop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CropImage extends StatefulWidget {
  String imagePath;
  final Function res;

  CropImage(this.imagePath, this.res, {Key? key}) : super(key: key);

  @override
  State<CropImage> createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  final controller = CropController(aspectRatio: 1000 / 667.0);
  double _rotation = 0;
  BoxShape shape = BoxShape.rectangle;

  @override
  void initState() {
    super.initState();
  }

  void _cropImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cropped = await controller.crop(pixelRatio: pixelRatio);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Crop Result'),
            centerTitle: true,
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    var byteData =
                        await cropped.toByteData(format: ImageByteFormat.png);
                    var buffer = byteData!.buffer.asUint8List();
                    print(buffer.length.toString());
                  },
                ),
              ),
            ],
          ),
          body: Center(
            child: RawImage(
              image: cropped,
            ),
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: _cropImage,
            tooltip: 'Crop',
            icon: const Icon(Icons.crop),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(8),
              child: Crop(
                onChanged: (decomposition) {
                  if (_rotation != decomposition.rotation) {
                    setState(() {
                      _rotation = ((decomposition.rotation + 180) % 360) - 180;
                    });
                  }
                },
                controller: controller,
                shape: shape,
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                ),


                helper: shape == BoxShape.rectangle
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
                onPressed: () {
                  controller.rotation = 0;
                  controller.scale = 1;
                  controller.offset = Offset.zero;
                  setState(() {
                    _rotation = 0;
                  });
                },
              ),
              Expanded(
                child: SliderTheme(
                  data: theme.sliderTheme.copyWith(),
                  child: Slider(
                    divisions: 360,
                    value: _rotation,
                    min: -180,
                    max: 180,
                    label: '$_rotation°',
                    onChanged: (n) {
                      setState(() {
                        _rotation = n.roundToDouble();
                        controller.rotation = _rotation;
                      });
                    },
                  ),
                ),
              ),
              PopupMenuButton<BoxShape>(
                icon: const Icon(Icons.crop_free),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    child: Text("Box"),
                    value: BoxShape.rectangle,
                  ),
                  const PopupMenuItem(
                    child: Text("Oval"),
                    value: BoxShape.circle,
                  ),
                ],
                tooltip: 'Crop Shape',
                onSelected: (x) {
                  setState(() {
                    shape = x;
                  });
                },
              ),
              PopupMenuButton<double>(
                icon: const Icon(Icons.aspect_ratio),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    child: Text("Original"),
                    value: 1000 / 667.0,
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    child: Text("16:9"),
                    value: 16.0 / 9.0,
                  ),
                  const PopupMenuItem(
                    child: Text("4:3"),
                    value: 4.0 / 3.0,
                  ),
                  const PopupMenuItem(
                    child: Text("1:1"),
                    value: 1,
                  ),
                  const PopupMenuItem(
                    child: Text("3:4"),
                    value: 3.0 / 4.0,
                  ),
                  const PopupMenuItem(
                    child: Text("9:16"),
                    value: 9.0 / 16.0,
                  ),
                ],
                tooltip: 'Aspect Ratio',
                onSelected: (x) {
                  controller.aspectRatio = x;
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
