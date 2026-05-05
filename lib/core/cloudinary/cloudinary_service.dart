import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'cloudinary_config.dart';

class CloudinaryUploadResult {
  final String secureUrl;
  final String publicId;
  final int width;
  final int height;
  final int bytes;
  final String format;

  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
    required this.width,
    required this.height,
    required this.bytes,
    required this.format,
  });

  factory CloudinaryUploadResult.fromJson(Map<String, dynamic> json) {
    return CloudinaryUploadResult(
      secureUrl: json['secure_url'] as String,
      publicId: json['public_id'] as String,
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      bytes: json['bytes'] as int? ?? 0,
      format: json['format'] as String? ?? '',
    );
  }
}

class CloudinaryService {
  CloudinaryService._() : _dio = Dio();

  static final CloudinaryService instance = CloudinaryService._();

  final Dio _dio;

  Future<CloudinaryUploadResult> uploadImage({
    required File imageFile,
    required String folder,
    String? publicId,
    bool compress = true,
  }) async {
    final fileToUpload = compress
        ? await _compressImage(imageFile)
        : imageFile;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        fileToUpload.path,
        filename: path.basename(fileToUpload.path),
      ),
      'upload_preset': CloudinaryConfig.uploadPreset,
      'folder': folder,
      if (publicId != null) 'public_id': publicId,
    });

    final response = await _dio.post(
      CloudinaryConfig.uploadUrl,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    if (response.statusCode == 200) {
      return CloudinaryUploadResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    throw Exception('Cloudinary upload failed: ${response.statusCode}');
  }

  Future<File> _compressImage(File file) async {
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 80,
      minWidth: 800,
      minHeight: 800,
    );

    if (compressedBytes == null) return file;

    final tempPath = '${file.parent.path}/compressed_${path.basename(file.path)}';
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(compressedBytes);
    return tempFile;
  }

  // Para cargas que requieren firma (documentos sensibles),
  // la firma se genera en Supabase Edge Function y se pasa aquí.
  Future<CloudinaryUploadResult> uploadSigned({
    required File imageFile,
    required String folder,
    required String signature,
    required String apiKey,
    required int timestamp,
    String? publicId,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
      'api_key': apiKey,
      'timestamp': timestamp,
      'signature': signature,
      'folder': folder,
      if (publicId != null) 'public_id': publicId,
    });

    final response = await _dio.post(
      CloudinaryConfig.uploadUrl,
      data: formData,
    );

    if (response.statusCode == 200) {
      return CloudinaryUploadResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    throw Exception('Cloudinary signed upload failed: ${response.statusCode}');
  }
}
