import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ImageStore {
  static Future<String?> ensureLocalCopy(String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = _getFileNameFromUrl(url);
      final localPath = '${directory.path}/$fileName';

      // Check if file already exists
      final file = File(localPath);
      if (await file.exists()) {
        return localPath;
      }

      // Download and save the image
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return localPath;
      }
    } catch (e) {
      // Log error or handle as needed
      print('Error downloading image: $e');
    }
    return null;
  }

  static String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final lastSegment = segments.last;
      if (lastSegment.contains('.')) {
        return lastSegment;
      }
      // If no extension found, try to extract from query parameters or use default
      return '${DateTime.now().millisecondsSinceEpoch}_${segments.last}.jpg';
    } catch (e) {
      // If parsing fails, generate a unique filename
      return 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }
  }
}