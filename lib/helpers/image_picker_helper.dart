import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/image_upload_service.dart';

/// Utility widget for picking and uploading images
class ImagePickerHelper {
  /// Pick image from local machine and upload to ImgBB
  /// Supports both Web and Mobile by using bytes instead of File path
  static Future<String?> pickAndUploadImage(BuildContext context) async {
    try {
      // Pick image file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowCompression: true,
        withData: true, // Crucial for Web
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final Uint8List? fileBytes = result.files.first.bytes;
      
      if (fileBytes == null) {
        throw Exception("Không thể đọc dữ liệu ảnh. Vui lòng thử lại.");
      }

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return PopScope(
              canPop: false,
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      'Đang tải ảnh lên...',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

      try {
        // Upload image using bytes
        final uploadedUrl = await ImageUploadService.uploadImage(fileBytes);

        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Tải ảnh thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        return uploadedUrl;
      } catch (e) {
        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        return null;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi hệ thống: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Pick multiple images and upload all of them
  static Future<List<String>> pickAndUploadMultipleImages(
    BuildContext context,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowCompression: true,
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      final List<Uint8List> imagesBytes = result.files
          .where((f) => f.bytes != null)
          .map((f) => f.bytes!)
          .toList();

      if (imagesBytes.isEmpty) {
        throw Exception("Không thể đọc dữ liệu ảnh.");
      }

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return const PopScope(
              canPop: false,
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'Đang tải các ảnh lên...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

      try {
        final uploadedUrls = await ImageUploadService.uploadMultipleImages(
          imagesBytes,
        );

        if (context.mounted) {
          Navigator.of(context).pop();
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Tải ${uploadedUrls.length} ảnh thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        return uploadedUrls;
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
