import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/image_upload_config.dart';

class ImageUploadService {
  /// Upload image file qua proxy backend
  /// Returns the uploaded image URL on success
  /// Throws an exception on failure
  static Future<String> uploadImage(File imageFile) async {
    if (!imageFile.existsSync()) {
      throw Exception("Tệp ảnh không tồn tại: ${imageFile.path}");
    }

    final proxyUrl = ImageUploadConfig.proxyUrl;
    if (proxyUrl.isEmpty) {
      throw Exception(
        "Proxy URL chưa được cấu hình. "
        "Vui lòng deploy proxy_server/ và cập nhật lib/config/image_upload_config.dart",
      );
    }

    try {
      // Read image file and convert to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Send POST request to proxy backend
      final response = await http
          .post(
            Uri.parse(proxyUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'imageBase64': base64Image}),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () =>
                throw Exception("Tải ảnh lên timeout sau 60 giây"),
          );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['url'] != null) {
          return responseData['url'];
        } else {
          throw Exception(
            "Lỗi từ proxy: ${responseData['error'] ?? response.body}",
          );
        }
      } else {
        String errorMsg = "Tải ảnh lên thất bại (HTTP ${response.statusCode})";
        try {
          final errorData = jsonDecode(response.body);
          errorMsg = errorData['error'] ?? errorMsg;
        } catch (_) {
          // Ignore parse error
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Upload multiple images concurrently
  /// Returns list of uploaded image URLs
  static Future<List<String>> uploadMultipleImages(
    List<File> imageFiles,
  ) async {
    if (imageFiles.isEmpty) {
      throw Exception("No images provided for upload");
    }

    try {
      final uploadFutures = imageFiles.map((file) => uploadImage(file));
      final results = await Future.wait(uploadFutures);
      return results;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload image from base64 string qua proxy backend
  static Future<String> uploadImageFromBase64(String base64Image) async {
    if (base64Image.isEmpty) {
      throw Exception("Base64 image string là rỗng");
    }

    final proxyUrl = ImageUploadConfig.proxyUrl;
    if (proxyUrl.isEmpty) {
      throw Exception(
        "Proxy URL chưa được cấu hình. "
        "Vui lòng deploy proxy_server/ và cập nhật lib/config/image_upload_config.dart",
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse(proxyUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'imageBase64': base64Image}),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () =>
                throw Exception("Tải ảnh lên timeout sau 60 giây"),
          );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['url'] != null) {
          return responseData['url'];
        } else {
          throw Exception(
            "Lỗi từ proxy: ${responseData['error'] ?? response.body}",
          );
        }
      } else {
        String errorMsg = "Tải ảnh lên thất bại (HTTP ${response.statusCode})";
        try {
          final errorData = jsonDecode(response.body);
          errorMsg = errorData['error'] ?? errorMsg;
        } catch (_) {
          // Ignore parse error
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }
}
