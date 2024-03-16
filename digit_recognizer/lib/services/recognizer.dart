// lib/services/recognizer.dart
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:digit_recognizer/utils/constants.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

final _canvasCullRect = Rect.fromPoints(
  Offset(0, 0),
  Offset(Constants.imageSize, Constants.imageSize),
);

final _whitePaint = Paint()
  ..strokeCap = StrokeCap.round
  ..color = Colors.white
  ..strokeWidth = Constants.strokeWidth;

final _bgPaint = Paint()..color = Colors.black;

class Recognizer {
  late tfl.Interpreter _interpreter;

  Future<void> loadModel() async {
    // Load the model
    _interpreter = await tfl.Interpreter.fromAsset('assets/mnist.tflite');
  }

  Recognizer() {
    _initInterpreter();
  }

  Future<void> _initInterpreter() async {
    _interpreter = await tfl.Interpreter.fromAsset('assets/mnist.tflite');
  }

  void dispose() {
    _interpreter.close();
  }

  Future<Uint8List> previewImage(List<Offset> points) async {
    final picture = _pointsToPicture(points);
    final image = await picture.toImage(
        Constants.mnistImageSize, Constants.mnistImageSize);
    var pngBytes = await image.toByteData(format: ImageByteFormat.png);

    return pngBytes?.buffer.asUint8List() ?? Uint8List(0);
  }

  Future<List> recognize(List<Offset> points) async {
    final picture = _pointsToPicture(points);
    Uint8List bytes =
        await _imageToByteListUint8(picture, Constants.mnistImageSize);
    return _predict(bytes);
  }

  Future<List> _predict(Uint8List bytes) async {
    final output = List.filled(1, null, growable: false);
    final inputs = [bytes];

    _interpreter.run(inputs, output); // Removed await

    return output;
  }

  Future<Uint8List> _imageToByteListUint8(Picture? pic, int size) async {
    if (pic == null) return Uint8List(0);

    final img = await pic.toImage(size, size);
    final imgBytes = await img.toByteData();
    final resultBytes = Float32List(size * size);
    final buffer = Float32List.view(resultBytes.buffer);

    int index = 0;

    for (int i = 0; i < imgBytes!.lengthInBytes; i += 4) {
      final r = imgBytes.getUint8(i);
      final g = imgBytes.getUint8(i + 1);
      final b = imgBytes.getUint8(i + 2);
      buffer[index++] = (r + g + b) / 3.0 / 255.0;
    }

    return resultBytes.buffer.asUint8List();
  }

  Picture _pointsToPicture(List<Offset> points) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _canvasCullRect)
      ..scale(Constants.mnistImageSize / Constants.canvasSize);

    canvas.drawRect(
        Rect.fromLTWH(0, 0, Constants.imageSize, Constants.imageSize),
        _bgPaint);

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], _whitePaint);
    }

    return recorder.endRecording();
  }
}
