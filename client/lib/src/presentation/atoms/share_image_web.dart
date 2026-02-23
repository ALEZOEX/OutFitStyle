import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

/// ShareImage для Web
/// Использует html canvas для захвата изображения
class ShareImage {
  /// Поделиться изображением из RenderRepaintBoundary
  /// Web-версия использует canvas.toBlob() и Web Share API
  static Future<void> sharePngFromBoundary({
    required GlobalKey boundaryKey,
    required String fileName,
    String? text,
  }) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      debugPrint('ShareImage: boundary не найден');
      return;
    }

    try {
      // Получаем изображение из boundary
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null) {
        debugPrint('ShareImage: не удалось получить байты изображения');
        return;
      }

      // Создаем blob из байтов
      final blob = html.Blob([bytes], 'image/png');
      
      // Создаем URL для blob
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Для Web пробуем использовать Web Share API
      try {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(url, name: fileName)],
            text: text,
          ),
        );
      } catch (e) {
        // Fallback: скачиваем файл
        debugPrint('ShareImage: Web Share API не поддерживается, скачиваем файл');
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
      }
      
      // Очищаем URL
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      debugPrint('ShareImage: ошибка при шеринге: $e');
      rethrow;
    }
  }
}
