import '../config/env_config.dart';

class CloudinaryConfig {
  CloudinaryConfig._();

  static String get cloudName => EnvConfig.cloudinaryCloudName;
  static String get uploadPreset => EnvConfig.cloudinaryUploadPreset;

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  static String buildImageUrl({
    required String publicId,
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
    String? transformation,
  }) {
    final base = 'https://res.cloudinary.com/$cloudName/image/upload';
    final transforms = <String>[
      if (width != null) 'w_$width',
      if (height != null) 'h_$height',
      'q_$quality',
      'f_$format',
      if (transformation != null) transformation,
    ].join(',');

    return '$base/$transforms/$publicId';
  }

  static String buildAvatarUrl(String publicId, {int size = 200}) {
    return buildImageUrl(
      publicId: publicId,
      width: size,
      height: size,
      transformation: 'c_fill,g_face,r_max',
    );
  }

  static String buildThumbnailUrl(String publicId, {int width = 400}) {
    return buildImageUrl(
      publicId: publicId,
      width: width,
      transformation: 'c_limit',
    );
  }
}
