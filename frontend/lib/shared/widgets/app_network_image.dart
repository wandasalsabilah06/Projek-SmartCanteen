import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widget gambar dari network yang handle:
/// - Web: pakai Image.network (tidak ada masalah CORS/cache di browser)
/// - Mobile: pakai CachedNetworkImage (efisien dengan disk cache)
/// - .jfif: otomatis diganti ke placeholder jika gagal load
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  Widget _placeholder() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E0D8),
      highlightColor: const Color(0xFFF5F0EB),
      child: Container(width: width, height: height, color: Colors.white),
    );
  }

  Widget _errorWidget() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF3EFEA),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.restaurant_rounded, color: Color(0xFFB0A79D), size: 28),
          SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(fontSize: 10, color: Color(0xFFB0A79D)),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Untuk Flutter Web, gunakan Image.network karena CachedNetworkImage
    // bisa bermasalah dengan CORS di beberapa konfigurasi browser
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _placeholder();
        },
        errorBuilder: (context, error, stackTrace) => _errorWidget(),
      );
    }

    // Mobile: gunakan CachedNetworkImage untuk efisiensi cache
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _placeholder(),
      errorWidget: (context, url, error) => _errorWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: _buildImage());
    }
    return _buildImage();
  }
}
