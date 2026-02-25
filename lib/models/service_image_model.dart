import 'dart:io';

/// Model to represent service images (either File for new uploads or URL for existing)
class ServiceImageModel {
  final File? file; // For new images
  final String? url; // For existing images
  final bool isExisting; // True if this is an existing image from server

  ServiceImageModel({
    this.file,
    this.url,
  }) : isExisting = url != null && file == null;

  // Create from File (new image)
  factory ServiceImageModel.fromFile(File file) {
    return ServiceImageModel(file: file);
  }

  // Create from URL (existing image)
  factory ServiceImageModel.fromUrl(String url) {
    return ServiceImageModel(url: url);
  }

  // Check if image is valid
  bool get isValid => file != null || (url != null && url!.isNotEmpty);
}

