import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/image_upload_service.dart';

/// Utility widget for picking and uploading images
/// Usage:
/// ImagePickerHelper.pickAndUploadImage(context).then((url) {
///   if (url != null) print('Uploaded: $url');
/// });
class ImagePickerHelper {
  /// Pick image from local machine and upload to ImgBB
  /// Returns the uploaded image URL on success, null if cancelled or error
  static Future<String?> pickAndUploadImage(BuildContext context) async {
    try {
      // Pick image file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowCompression: true,
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled
        return null;
      }

      final pickedFile = File(result.files.first.path!);

      // Show loading dialog during upload
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return WillPopScope(
              onWillPop: () async => false,
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
        // Upload image
        final uploadedUrl = await ImageUploadService.uploadImage(pickedFile);

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
            content: Text('❌ Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Pick multiple images and upload all of them
  /// Returns list of uploaded image URLs
  static Future<List<String>> pickAndUploadMultipleImages(
    BuildContext context,
  ) async {
    try {
      // Pick multiple image files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowCompression: true,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      final pickedFiles = result.files.map((f) => File(f.path!)).toList();

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return WillPopScope(
              onWillPop: () async => false,
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
        // Upload all images
        final uploadedUrls = await ImageUploadService.uploadMultipleImages(
          pickedFiles,
        );

        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Tải ${uploadedUrls.length} ảnh thành công!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        return uploadedUrls;
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

        return [];
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }
}
