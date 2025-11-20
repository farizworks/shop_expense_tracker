import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String title;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _saveToGallery(context),
            tooltip: 'Save to Gallery',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareImage(context),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      print('DEBUG: Starting share image...');
      print('DEBUG: Image path: $imagePath');
      final file = File(imagePath);
      final exists = await file.exists();
      print('DEBUG: File exists: $exists');

      if (exists) {
        print('DEBUG: Creating XFile for sharing...');

        // Get the screen size for iOS share positioning
        final box = context.findRenderObject() as RenderBox?;
        final sharePositionOrigin = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null;

        await Share.shareXFiles(
          [XFile(imagePath)],
          text: title,
          sharePositionOrigin: sharePositionOrigin,
        );
        print('DEBUG: Share completed successfully');
      } else {
        print('DEBUG: Image file not found at path: $imagePath');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image file not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('DEBUG: Share Image Error: $e');
      print('DEBUG: Stack Trace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveToGallery(BuildContext context) async {
    try {
      print('DEBUG: Starting save to gallery...');
      print('DEBUG: Image path: $imagePath');
      print('DEBUG: Platform: ${Platform.isAndroid ? "Android" : Platform.isIOS ? "iOS" : "Other"}');

      // Request storage permission
      PermissionStatus status;

      if (Platform.isAndroid) {
        print('DEBUG: Requesting Android permissions...');
        // For Android 13+ (API 33+), use photos permission
        status = await Permission.photos.status;
        if (!status.isGranted) {
          print('DEBUG: Requesting photos permission...');
          status = await Permission.photos.request();
          print('DEBUG: Photos permission status: $status');

          // Fallback to storage for older Android versions
          if (status.isDenied || status.isPermanentlyDenied) {
            print('DEBUG: Requesting storage permission as fallback...');
            status = await Permission.storage.request();
            print('DEBUG: Storage permission status: $status');
          }
        } else {
          print('DEBUG: Photos permission already granted');
        }
      } else if (Platform.isIOS) {
        print('DEBUG: Checking iOS photos permission...');
        status = await Permission.photos.status;

        if (status.isDenied || status.isRestricted) {
          print('DEBUG: Requesting iOS photos permission...');
          status = await Permission.photos.request();
          print('DEBUG: iOS photos permission status: $status');
        } else {
          print('DEBUG: iOS photos permission already granted or limited');
        }
      } else {
        status = PermissionStatus.granted;
      }

      if (status.isGranted || status.isLimited) {
        print('DEBUG: Permission granted, checking image file...');
        // Check if the image file exists
        final file = File(imagePath);
        if (!await file.exists()) {
          throw Exception('Image file not found');
        }

        print('DEBUG: Image file exists, saving to gallery...');

        // Save to gallery using Gal package
        await Gal.putImage(imagePath);
        print('DEBUG: Image saved successfully!');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved to gallery successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (status.isPermanentlyDenied) {
        print('DEBUG: Permission permanently denied');
        if (context.mounted) {
          _showPermissionDialog(context);
        }
      } else {
        print('DEBUG: Permission denied, status: $status');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Photo library access is required to save images'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: openAppSettings,
              ),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('DEBUG: Save to Gallery Error: $e');
      print('DEBUG: Stack Trace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Storage permission is required to save images. Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
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
