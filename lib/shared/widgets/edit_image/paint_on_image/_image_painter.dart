// ignore_for_file: cascade_invocations

import 'dart:ui';

import 'package:flutter/material.dart' hide Image;

///Handles all the painting ongoing on the canvas.
class DrawImage extends CustomPainter {
  ///Converted image from [ImagePainter] constructor.
  final Image? image;

  ///Keeps track of all the units of [PaintHistory].
  final List<PaintInfo>? paintHistory;

  ///Keeps track of points on currently drawing state.
  final UpdatePoints? update;

  ///Keeps track of freestyle points on currently drawing state.
  final List<Offset?>? points;

  ///Keeps track whether the paint action is running or not.
  final bool isDragging;

  ///Flag for triggering signature mode.
  final bool isSignature;

  ///The background for signature painting.
  final Color? backgroundColor;

  ///Constructor for the canvas
  DrawImage({
    this.image,
    this.update,
    this.points,
    this.isDragging = false,
    this.isSignature = false,
    this.backgroundColor,
    this.paintHistory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isSignature) {
      ///Paints background for signature.
      canvas.drawRect(
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
        Paint()
          ..style = PaintingStyle.fill
          ..color = backgroundColor!,
      );
    } else {
      ///paints [ui.Image] on the canvas for reference to draw over it.
      paintImage(
        canvas: canvas,
        image: image!,
        filterQuality: FilterQuality.high,
        rect: Rect.fromPoints(
          const Offset(0, 0),
          Offset(size.width, size.height),
        ),
      );
    }

    for (final item in paintHistory!) {
      final offset = item.offset;
      final painter = item.painter;
      switch (item.mode) {
        case PaintMode.rect:
          canvas.drawRect(
            Rect.fromPoints(offset![0]!, offset[1]!),
            painter!,
          );
          break;
        case PaintMode.line:
          canvas.drawLine(offset![0]!, offset[1]!, painter!);
          break;
        case PaintMode.circle:
          final path = Path();
          path.addOval(
            Rect.fromCircle(
              center: offset![1]!,
              radius: (offset[0]! - offset[1]!).distance,
            ),
          );
          canvas.drawPath(path, painter!);
          break;
        case PaintMode.arrow:
          drawArrow(canvas, offset![0]!, offset[1]!, painter!);
          break;
        case PaintMode.dashLine:
          final path = Path()
            ..moveTo(offset![0]!.dx, offset[0]!.dy)
            ..lineTo(offset[1]!.dx, offset[1]!.dy);
          canvas.drawPath(_dashPath(path, painter!.strokeWidth), painter);
          break;
        case PaintMode.freeStyle:
          for (var i = 0; i < offset!.length - 1; i++) {
            if (offset[i] != null && offset[i + 1] != null) {
              final path = Path()
                ..moveTo(offset[i]!.dx, offset[i]!.dy)
                ..lineTo(offset[i + 1]!.dx, offset[i + 1]!.dy);
              canvas.drawPath(
                path,
                painter!
                  ..strokeCap = StrokeCap.round,
              );
            } else if (offset[i] != null && offset[i + 1] == null) {
              canvas.drawPoints(
                PointMode.points,
                [offset[i]!],
                painter!
                  ..strokeCap = StrokeCap.round,
              );
            }
          }
          break;
        case PaintMode.text:
          final textSpan = TextSpan(
            text: item.text,
            style: TextStyle(
              color: painter!.color,
              fontSize: 6 * painter.strokeWidth,
              fontWeight: FontWeight.bold,
            ),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(maxWidth: size.width);
          final textOffset = offset!.isEmpty
              ? Offset(
            size.width / 2 - textPainter.width / 2,
            size.height / 2 - textPainter.height / 2,
          )
              : Offset(
            offset[0]!.dx - textPainter.width / 2,
            offset[0]!.dy - textPainter.height / 2,
          );
          textPainter.paint(canvas, textOffset);
          break;

        case PaintMode.none:
          break;
        case null:
          break;
      }
    }

    if (isDragging) {
      final start = update!.start;
      final end = update!.end;
      final painter = update!.painter;
      switch (update!.mode) {
        case PaintMode.rect:
          canvas.drawRect(Rect.fromPoints(start!, end!), painter!);
          break;
        case PaintMode.line:
          canvas.drawLine(start!, end!, painter!);
          break;
        case PaintMode.circle:
          final path = Path();
          path.addOval(
            Rect.fromCircle(
              center: end!,
              radius: (end - start!).distance,
            ),
          );
          canvas.drawPath(path, painter!);
          break;
        case PaintMode.arrow:
          drawArrow(canvas, start!, end!, painter!);
          break;
        case PaintMode.dashLine:
          final path = Path()
            ..moveTo(start!.dx, start.dy)
            ..lineTo(end!.dx, end.dy);
          canvas.drawPath(_dashPath(path, painter!.strokeWidth), painter);
          break;
        case PaintMode.freeStyle:
          for (var i = 0; i < points!.length - 1; i++) {
            if (points![i] != null && points![i + 1] != null) {
              canvas.drawLine(
                Offset(points![i]!.dx, points![i]!.dy),
                Offset(points![i + 1]!.dx, points![i + 1]!.dy),
                painter!
                  ..strokeCap = StrokeCap.round,
              );
            } else if (points![i] != null && points![i + 1] == null) {
              canvas.drawPoints(
                PointMode.points,
                [Offset(points![i]!.dx, points![i]!.dy)],
                painter!,
              );
            }
          }
          break;
        case PaintMode.none:
          break;
        case PaintMode.text:
          break;
        case null:
          break;
      }
    }

    ///Draws all the completed actions of painting on the canvas.
  }

  ///Draws line as well as the arrowhead on top of it.
  ///Uses [strokeWidth] of the painter for sizing.
  void drawArrow(Canvas canvas, Offset start, Offset end, Paint painter) {
    final arrowPainter = Paint()
      ..color = painter.color
      ..strokeWidth = painter.strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, painter);
    final pathOffset = painter.strokeWidth / 15;
    final path = Path()
      ..lineTo(-15 * pathOffset, 10 * pathOffset)..lineTo(
        -15 * pathOffset,
        -10 * pathOffset,
      )
      ..close();
    canvas.save();
    canvas.translate(end.dx, end.dy);
    canvas.rotate((end - start).direction);
    canvas.drawPath(path, arrowPainter);
    canvas.restore();
  }

  ///Draws dashed path.
  ///It depends on [strokeWidth] for space to line proportion.
  Path _dashPath(Path path, double width) {
    final dashPath = Path();
    final dashWidth = 10.0 * width / 5;
    final dashSpace = 10.0 * width / 5;
    var distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(DrawImage oldDelegate) {
    return (oldDelegate.update != update ||
        oldDelegate.paintHistory!.length == paintHistory!.length);
  }
}

///All the paint method available for use.

enum PaintMode {
  ///Prefer using [None] while doing scaling operations.
  none,

  ///Allows for drawing freehand shapes or text.
  freeStyle,

  ///Allows to draw line between two points.
  line,

  ///Allows to draw rectangle.
  rect,

  ///Allows to write texts over an image.
  text,

  ///Allows us to draw line with arrow at the end point.
  arrow,

  ///Allows to draw circle from a point.
  circle,

  ///Allows to draw dashed line between two point.
  dashLine
}

///[PaintInfo] keeps track of a single unit of shape, whichever selected.
class PaintInfo {
  ///Mode of the paint method.
  PaintMode? mode;

  ///Used to save specific paint utils used for the specific shape.
  Paint? painter;

  ///Used to save offsets.
  ///Two point in case of other shapes and list of points for [FreeStyle].
  List<Offset?>? offset;

  ///Used to save text in case of text type.
  String? text;

  ///In case of string, it is used to save string value entered.
  PaintInfo({this.offset, this.painter, this.text, this.mode});
}

@immutable

///Records realtime updates of ongoing [PaintInfo] when inDrag.
class UpdatePoints {
  ///Records the first tap offset,
  final Offset? start;

  ///Records all the offset after first one.
  final Offset? end;

  ///Records [Paint] method of the ongoing painting.
  final Paint? painter;

  ///Records [PaintMode] of the ongoing painting.
  final PaintMode? mode;


  const UpdatePoints({this.start, this.end, this.painter, this.mode});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is UpdatePoints &&
        other.start == start &&
        other.end == end &&
        other.painter == painter &&
        other.mode == mode;
  }

  @override
  int get hashCode {
    return start.hashCode ^ end.hashCode ^ painter.hashCode ^ mode.hashCode;
  }
}
