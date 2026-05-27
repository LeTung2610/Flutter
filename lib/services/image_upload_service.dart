import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/image_upload_config.dart';

class ImageUploadService {
  /// Upload image bytes - Tự động chọn giữa Proxy hoặc trực tiếp tới ImgBB
  static Future<String> uploadImage(Uint8List bytes) async {
    // 1. Nếu có Proxy URL hợp lệ, ưu tiên dùng Proxy (để tránh CORS trên Web)
    if (ImageUploadConfig.isProxyConfigured) {
      return _uploadViaProxy(bytes);
    } 
    
    // 2. Nếu không có Proxy, upload trực tiếp lên ImgBB
    return _uploadDirectToImgBB(bytes);
  }

  /// Upload trực tiếp lên ImgBB API
  static Future<String> _uploadDirectToImgBB(Uint8List bytes) async {
    if (!ImageUploadConfig.isConfigured) {
      throw Exception("ImgBB API Key chưa được cấu hình trong image_upload_config.dart");
    }

    try {
      final base64Image = base64Encode(bytes);
      
      final response = await http.post(
        Uri.parse(ImageUploadConfig.imgbbApiUrl),
        body: {
          'key': ImageUploadConfig.imgbbApiKey,
          'image': base64Image,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']['url'];
        }
      }
      
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error']?['message'] ?? "Lỗi upload trực tiếp lên ImgBB (HTTP ${response.statusCode})");
    } catch (e) {
      throw Exception("Không thể kết nối tới ImgBB: $e");
    }
  }

  /// Upload qua Proxy server
  static Future<String> _uploadViaProxy(Uint8List bytes) async {
    try {
      final base64Image = base64Encode(bytes);
      final response = await http.post(
        Uri.parse(ImageUploadConfig.proxyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imageBase64': base64Image}),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['url'] != null) {
          return responseData['url'];
        }
        throw Exception(responseData['error'] ?? "Proxy không trả về URL");
      }
      throw Exception("Lỗi Proxy: HTTP ${response.statusCode}");
    } catch (e) {
      rethrow;
    }
  }

  /// Upload multiple images concurrently
  static Future<List<String>> uploadMultipleImages(List<Uint8List> imagesBytes) async {
    if (imagesBytes.isEmpty) return [];
    try {
      final uploadFutures = imagesBytes.map((bytes) => uploadImage(bytes));
      return await Future.wait(uploadFutures);
    } catch (e) {
      rethrow;
    }
  }

  /// Tương thích ngược với Base64 string
  static Future<String> uploadImageFromBase64(String base64Image) async {
    final bytes = base64Decode(base64Image);
    return uploadImage(bytes);
  }
}
