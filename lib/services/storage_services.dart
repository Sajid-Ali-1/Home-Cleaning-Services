import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServices {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  /// Upload a service image to Firebase Storage
  /// Returns the download URL
  static Future<String> uploadServiceImage({
    required File imageFile,
    required String cleanerId,
    String? serviceId,
  }) async {
    try {
      // Generate unique filename
      String fileName = _uuid.v4();
      String extension = imageFile.path.split('.').last;
      String fullFileName = '$fileName.$extension';

      // Create storage path: services/{cleanerId}/{serviceId}/{fileName}
      String path = serviceId != null
          ? 'services/$cleanerId/$serviceId/$fullFileName'
          : 'services/$cleanerId/$fullFileName';

      // Upload file
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload service image: $e');
    }
  }

  static Future<String> uploadChatImage({
    required File imageFile,
    required String chatId,
    required String senderId,
  }) async {
    try {
      final fileName = '${senderId}_${_uuid.v4()}.jpg';
      final path = 'chats/$chatId/$fileName';
      final ref = _storage.ref().child(path);
      final snapshot = await ref.putFile(imageFile);
      return snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload chat image: $e');
    }
  }

  /// Upload multiple service images
  /// Returns list of download URLs
  static Future<List<String>> uploadMultipleServiceImages({
    required List<File> imageFiles,
    required String cleanerId,
    String? serviceId,
  }) async {
    try {
      List<String> downloadUrls = [];

      for (File imageFile in imageFiles) {
        String url = await uploadServiceImage(
          imageFile: imageFile,
          cleanerId: cleanerId,
          serviceId: serviceId,
        );
        downloadUrls.add(url);
      }

      return downloadUrls;
    } catch (e) {
      throw Exception('Failed to upload multiple service images: $e');
    }
  }

  /// Upload verification document for provider verification
  /// Returns download URL
  static Future<String> uploadVerificationDocument({
    required File file,
    required String providerId,
  }) async {
    try {
      final fileName = _uuid.v4();
      final extension = file.path.split('.').last;
      final fullName = '$fileName.$extension';
      final path = 'provider_verifications/$providerId/$fullName';
      final ref = _storage.ref().child(path);
      final snapshot = await ref.putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload verification document: $e');
    }
  }

  /// Delete a service image from Firebase Storage
  static Future<void> deleteServiceImage(String imageUrl) async {
    try {
      // Extract the path from the URL
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete service image: $e');
    }
  }

  /// Delete multiple service images
  static Future<void> deleteMultipleServiceImages(
    List<String> imageUrls,
  ) async {
    try {
      for (String url in imageUrls) {
        await deleteServiceImage(url);
      }
    } catch (e) {
      throw Exception('Failed to delete multiple service images: $e');
    }
  }

  /// Get download URL for a file (if already uploaded)
  static Future<String> getImageUrl(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get image URL: $e');
    }
  }

  /// Delete all images for a specific service
  static Future<void> deleteServiceImages({
    required String cleanerId,
    required String serviceId,
  }) async {
    try {
      Reference serviceRef = _storage
          .ref()
          .child('services')
          .child(cleanerId)
          .child(serviceId);

      // List all files in the service folder
      ListResult result = await serviceRef.listAll();

      // Delete all files
      for (Reference ref in result.items) {
        await ref.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete service images: $e');
    }
  }
}
