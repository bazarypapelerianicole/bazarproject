import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bazarnicole/Presentation/Services/image_optimizer_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('optimiza una imagen PNG a WebP y deja un archivo temporal', () async {
    final tempDir = await Directory.systemTemp.createTemp('image_optimizer_test');
    final sourcePath = '${tempDir.path}/sample.png';
    final bytes = Uint8List.fromList(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAAIAAGfQf7QAAAABJRU5ErkJggg==',
      ),
    );
    await File(sourcePath).writeAsBytes(bytes, flush: true);

    final optimized = await ImageOptimizerService.optimize(sourcePath);

    expect(optimized.file.existsSync(), isTrue);
    expect(optimized.mimeType, 'image/webp');
    expect(optimized.extension, 'webp');
    expect(optimized.optimizedSize, greaterThan(0));
    expect(optimized.optimizedSize, lessThan(optimized.originalSize));

    await optimized.file.delete();
    await tempDir.delete(recursive: true);
  });
}
