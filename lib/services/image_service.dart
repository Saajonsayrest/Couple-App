import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndCropImage({
    required BuildContext context,
    required Color color,
  }) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 70,
    );

    if (image == null) return null;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ), // Square for profile
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Picture',
          toolbarColor: color,
          toolbarWidgetColor: Colors.white,
          statusBarColor: color, // Match toolbar color
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          activeControlsWidgetColor: color,
        ),
        IOSUiSettings(
          title: 'Crop Profile Picture',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile == null) return null;

    // Copy to app documents directory for persistence
    final directory = await getApplicationDocumentsDirectory();
    final String fileName =
        'avatar_${DateTime.now().millisecondsSinceEpoch}${p.extension(croppedFile.path)}';
    final String localPath = p.join(directory.path, fileName);

    await File(croppedFile.path).copy(localPath);

    return localPath;
  }
}
