import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Professional image picker helper with proper permission handling
/// Following iOS and Android best practices
class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery with proper permission handling
  /// iOS 14+ and Android 13+ use new photo pickers that don't require permissions
  static Future<File?> pickImageFromGallery(BuildContext context) async {
    try {
      print('DEBUG: ImagePickerHelper - Starting gallery picker...');

      // Modern image_picker plugin (1.0.0+) uses:
      // - iOS: PHPickerViewController (no permission needed)
      // - Android 13+: Photo Picker (no permission needed)
      // - Android <13: Traditional picker (needs storage permission)
      //
      // We let image_picker handle permissions automatically through its native implementation
      // This prevents unnecessary permission dialogs on modern OS versions

      print('DEBUG: ImagePickerHelper - Opening gallery...');

      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Balance between quality and file size
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) {
        print('DEBUG: ImagePickerHelper - No image selected');
        return null;
      }

      print('DEBUG: ImagePickerHelper - Image selected: ${image.path}');
      return File(image.path);
    } catch (e, stackTrace) {
      print('DEBUG: ImagePickerHelper - Error: $e');
      print('DEBUG: ImagePickerHelper - Stack trace: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Pick image from camera with proper permission handling
  static Future<File?> pickImageFromCamera(BuildContext context) async {
    try {
      print('DEBUG: ImagePickerHelper - Starting camera picker...');

      // Check and request camera permission
      final hasPermission = await _requestCameraPermission(context);

      if (!hasPermission) {
        print('DEBUG: ImagePickerHelper - Camera permission denied');
        return null;
      }

      print('DEBUG: ImagePickerHelper - Camera permission granted, opening camera...');

      // Take photo with camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) {
        print('DEBUG: ImagePickerHelper - No photo taken');
        return null;
      }

      print('DEBUG: ImagePickerHelper - Photo taken: ${image.path}');
      return File(image.path);
    } catch (e, stackTrace) {
      print('DEBUG: ImagePickerHelper - Error: $e');
      print('DEBUG: ImagePickerHelper - Stack trace: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Show dialog to choose between camera and gallery
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    return showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await pickImageFromGallery(context);
                  if (context.mounted && file != null) {
                    Navigator.pop(context, file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await pickImageFromCamera(context);
                  if (context.mounted && file != null) {
                    Navigator.pop(context, file);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Request photo library permission (iOS & Android)
  static Future<bool> _requestPhotoLibraryPermission(
      BuildContext context) async {
    print('DEBUG: ImagePickerHelper - Requesting photo library permission...');
    print('DEBUG: ImagePickerHelper - Platform: ${Platform.isAndroid ? "Android" : Platform.isIOS ? "iOS" : "Other"}');

    PermissionStatus status;

    if (Platform.isAndroid) {
      // Android 13+ uses photos permission, older versions use storage
      status = await Permission.photos.status;
      print('DEBUG: ImagePickerHelper - Initial status: $status');

      if (!status.isGranted) {
        print('DEBUG: ImagePickerHelper - Requesting permission...');
        status = await Permission.photos.request();
        print('DEBUG: ImagePickerHelper - After request: $status');

        // Fallback to storage for Android < 13
        if (!status.isGranted) {
          status = await Permission.storage.request();
          print('DEBUG: ImagePickerHelper - Storage fallback: $status');
        }
      }
    } else if (Platform.isIOS) {
      // iOS uses photos permission
      status = await Permission.photos.status;
      print('DEBUG: ImagePickerHelper - Initial status: $status');

      if (!status.isGranted && !status.isLimited) {
        print('DEBUG: ImagePickerHelper - Requesting permission...');
        status = await Permission.photos.request();
        print('DEBUG: ImagePickerHelper - After request: $status');
      }
    } else {
      return true;
    }

    print('DEBUG: ImagePickerHelper - Final permission status: $status');

    // Handle permission result
    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDeniedDialog(context, 'Photo Library');
      }
      return false;
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Photo library access is required'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: openAppSettings,
            ),
          ),
        );
      }
      return false;
    }
  }

  /// Request camera permission
  static Future<bool> _requestCameraPermission(BuildContext context) async {
    print('DEBUG: ImagePickerHelper - Requesting camera permission...');

    final status = await Permission.camera.request();
    print('DEBUG: ImagePickerHelper - Camera permission status: $status');

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDeniedDialog(context, 'Camera');
      }
      return false;
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Camera access is required'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: openAppSettings,
            ),
          ),
        );
      }
      return false;
    }
  }

  /// Show permission denied dialog
  static void _showPermissionDeniedDialog(
      BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
          '$permissionName access is required for this feature. Please enable it in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
