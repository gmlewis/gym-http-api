// -*- compile-command: "cd ../.. && ./df.sh"; -*-

import 'dart:io' as io;
import 'package:image/image.dart';

// Iterable flatten(Iterable iterable) => iterable.expand((e) => e is List ? flatten(e) : [e]);

writePNG(dynamic observation, String filename) {
  var width = observation[0].length;
  var height = observation.length;
  var format = observation[0][0].length;
  List<int> bytes = [];
  if (format == 3) {
    var pixels = [];
    observation.forEach((row) => pixels.addAll(row));
    var withAlpha = List.generate(pixels.length,
        (i) => List<int>.from([pixels[i][0], pixels[i][1], pixels[i][2], 255]));
    bytes = withAlpha.expand((i) => i).toList();
  } else {
    bytes = observation.expand((i) => i).toList().expand((i) => i).toList();
  }

  var image =
      Image.fromBytes(width, height, bytes); // format=3 doesn't work correctly.
  var png = encodePng(image);

  // Save the image as a PNG.
  io.File(filename)..writeAsBytesSync(png);
}
