import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../../services/auth_storage.dart';
import 'api_config.dart';

/// Сервис для загрузки изображений на сервер
/// 
/// Использует multipart/form-data для загрузки файлов
/// Возвращает URL загруженного изображения
class UploadService {
  final AuthStorage _authStorage;
  late final Dio _dio;

  UploadService({required AuthStorage authStorage})
      : _authStorage = authStorage {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'multipart/form-data'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authStorage.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException err, handler) => handler.next(err),
    ));
  }

  /// Загружает изображение на сервер
  /// 
  /// [imageFile] - файл изображения для загрузки
  /// [onProgress] - callback для отслеживания прогресса (0.0 - 1.0)
  /// 
  /// Возвращает URL загруженного изображения
  /// 
  /// Endpoint: POST /api/v1/upload/image
  Future<String> uploadImage(
    File imageFile, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final fileName = path.basename(imageFile.path);
      final fileSize = await imageFile.length();
      
      // Создаем FormData для multipart запроса
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: _getContentType(fileName),
        ),
      });

      final response = await _dio.post(
        '/api/v1/upload/image',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final url = data['url'] as String?;
        if (url == null || url.isEmpty) {
          throw UploadException('Сервер не вернул URL изображения');
        }
        return url;
      } else {
        throw UploadException(
          'Ошибка загрузки: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is UploadException) rethrow;
      throw UploadException('Ошибка загрузки изображения: $e');
    }
  }

  /// Загружает несколько изображений
  /// 
  /// [imageFiles] - список файлов изображений
  /// [onProgress] - callback для отслеживания прогресса
  /// 
  /// Возвращает список URL загруженных изображений
  Future<List<String>> uploadImages(
    List<File> imageFiles, {
    void Function(double progress)? onProgress,
  }) async {
    final urls = <String>[];
    final totalFiles = imageFiles.length;
    
    for (var i = 0; i < totalFiles; i++) {
      final url = await uploadImage(
        imageFiles[i],
        onProgress: (fileProgress) {
          if (onProgress != null) {
            // Общий прогресс: (количество готовых файлов + прогресс текущего) / общее количество
            final overallProgress = (i + fileProgress) / totalFiles;
            onProgress(overallProgress);
          }
        },
      );
      urls.add(url);
    }
    
    return urls;
  }

  MediaType _getContentType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.gif':
        return MediaType('image', 'gif');
      case '.webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'octet-stream');
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw UploadException('Превышено время загрузки. Проверьте соединение.');
    }
    
    final statusCode = e.response?.statusCode;
    final errorMessage = _extractErrorMessage(e.response?.data);
    
    switch (statusCode) {
      case 401:
        throw UploadException('Требуется авторизация');
      case 403:
        throw UploadException('Нет доступа к загрузке файлов');
      case 413:
        throw UploadException('Файл слишком большой');
      case 415:
        throw UploadException('Неподдерживаемый формат файла');
      case 500:
        throw UploadException('Ошибка сервера при загрузке');
      default:
        throw UploadException(errorMessage ?? 'Ошибка загрузки: $statusCode');
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? 
             data['error'] as String?;
    }
    return null;
  }
}

/// Исключение при загрузке файла
class UploadException implements Exception {
  final String message;
  
  const UploadException(this.message);
  
  @override
  String toString() => 'UploadException: $message';
}
