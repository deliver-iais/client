import 'package:deliver/shared/widgets/edit_image/paint_on_image/_paint_over_image.dart';
import 'package:flutter/material.dart';

class _SliderIndicatorPainter extends CustomPainter {
  final double position;
  final Controller controller;

  _SliderIndicatorPainter(this.position, this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(position, size.height / 2), 12, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(position, size.height / 2), 3,
        Paint()..color = controller.color);
  }

  @override
  bool shouldRepaint(_SliderIndicatorPainter old) {
    return true;
  }
}

class ColorPicker extends StatefulWidget {
  final double width;
  final ValueNotifier<Controller> valueController;
  final Controller controller;

  const ColorPicker(this.width,
      {Key? key, required this.controller, required this.valueController})
      : super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  final List<Color> _colors = [
    const Color.fromARGB(255, 255, 0, 0),
    const Color.fromARGB(255, 255, 128, 0),
    const Color.fromARGB(255, 255, 255, 0),
    const Color.fromARGB(255, 128, 255, 0),
    const Color.fromARGB(255, 0, 255, 0),
    const Color.fromARGB(255, 0, 255, 128),
    const Color.fromARGB(255, 0, 255, 255),
    const Color.fromARGB(255, 0, 128, 255),
    const Color.fromARGB(255, 0, 0, 255),
    const Color.fromARGB(255, 127, 0, 255),
    const Color.fromARGB(255, 255, 0, 255),
    const Color.fromARGB(255, 255, 0, 127),
    const Color.fromARGB(255, 128, 128, 128),
  ];
  double _colorSliderPosition = 160;
  late Color _currentColor;

  @override
  initState() {
    super.initState();
    _currentColor = _calculateSelectedColor(
        _colorSliderPosition); //center the shader selector
  }

  Color get currentColor => _currentColor;

  _colorChangeHandler(double position) {
    //handle out of bounds positions
    if (position > widget.width) {
      position = widget.width;
    }
    if (position < 0) {
      position = 0;
    }
    setState(() {
      _colorSliderPosition = position;
      _currentColor = _calculateSelectedColor(_colorSliderPosition);
    });
  }

  Color _calculateSelectedColor(double position) {
    //determine color
    double positionInColorArray =
        (position / widget.width * (_colors.length - 1));

    int index = positionInColorArray.truncate();

    double remainder = positionInColorArray - index;
    if (remainder == 0.0) {
      _currentColor = _colors[index];
    } else {
      //calculate new color
      int redValue = _colors[index].red == _colors[index + 1].red
          ? _colors[index].red
          : (_colors[index].red +
                  (_colors[index + 1].red - _colors[index].red) * remainder)
              .round();
      int greenValue = _colors[index].green == _colors[index + 1].green
          ? _colors[index].green
          : (_colors[index].green +
                  (_colors[index + 1].green - _colors[index].green) * remainder)
              .round();
      int blueValue = _colors[index].blue == _colors[index + 1].blue
          ? _colors[index].blue
          : (_colors[index].blue +
                  (_colors[index + 1].blue - _colors[index].blue) * remainder)
              .round();
      _currentColor = Color.fromARGB(255, redValue, greenValue, blueValue);
    }
    return _currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (DragStartDetails details) {
              _colorChangeHandler(details.localPosition.dx);
              widget.valueController.value =
                  widget.controller.copyWith(color: _currentColor);
            },
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              _colorChangeHandler(details.localPosition.dx);
              widget.valueController.value =
                  widget.controller.copyWith(color: _currentColor);
            },
            onTapDown: (TapDownDetails details) {
              _colorChangeHandler(details.localPosition.dx);
              widget.valueController.value =
                  widget.controller.copyWith(color: _currentColor);
            },
            //This outside padding makes it much easier to grab the   slider because the gesture detector has
            // the extra padding to recognize gestures inside of
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                width: widget.width,
                height: 15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(colors: _colors),
                ),
                child: CustomPaint(
                  painter: _SliderIndicatorPainter(
                      _colorSliderPosition, widget.controller),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
