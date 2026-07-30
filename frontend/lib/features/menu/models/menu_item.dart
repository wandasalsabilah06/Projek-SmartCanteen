import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';

class MenuItem extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryName;
  final int categoryId;
  final int stock;
  final double rating;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryName,
    required this.categoryId,
    this.stock = 0,
    this.rating = 4.5,
  });

  bool get isAvailable => stock > 0;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return MenuItem(
      id: _toInt(json['id']),
      name: (json['nama_menu'] as String?) ?? '',
      description: (json['deskripsi'] as String?) ?? '',
      price: _toDouble(json['harga']),
      imageUrl: _resolveImageUrl(json['gambar_url'], json['gambar']),
      categoryName: (category?['nama_kategori'] as String?) ?? '',
      categoryId: _toInt(json['category_id']),
      stock: _toInt(json['stok']),
      rating: 4.5,
    );
  }

  // ── Parse helpers ───────────────────────────────────────────────────────────

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  /// Resolusi URL gambar:
  ///
  /// Backend mungkin return gambar_url dengan host `localhost` (karena APP_URL
  /// belum tentu cocok saat dijalankan via HP fisik). Flutter harus replace
  /// host tersebut dengan `_deviceIp` agar bisa diakses dari HP.
  static String _resolveImageUrl(dynamic gambarUrl, dynamic gambar) {
    // 1. Prioritas: gambar_url (full URL dari backend)
    String raw = (gambarUrl?.toString() ?? '').trim();

    // 2. Fallback: field gambar (relative path)
    if (raw.isEmpty) {
      raw = (gambar?.toString() ?? '').trim();
    }

    if (raw.isEmpty) return AppConstants.placeholderFood;

    // Jika relative path → jadikan full URL via /api/image/
    if (!raw.startsWith('http')) {
      final cleaned = raw.startsWith('/') ? raw.substring(1) : raw;
      return '${AppConstants.baseUrl}/image/$cleaned';
    }

    // Jika full URL tapi host-nya localhost/127.0.0.1 → replace ke IP yang benar
    // agar bisa diakses dari HP fisik
    raw = _fixHost(raw);
    return raw;
  }

  /// Ganti host localhost/127.0.0.1 ke baseUrl yang benar untuk platform ini.
  static String _fixHost(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    final needsFix =
        uri.host == 'localhost' ||
        uri.host == '127.0.0.1' ||
        uri.host == '10.0.2.2';

    if (!needsFix) return url;

    final correctBase =
        AppConstants.imageBaseUrl; // e.g. http://192.168.100.163:8000/
    final correctUri = Uri.parse(correctBase);

    return uri
        .replace(
          scheme: correctUri.scheme,
          host: correctUri.host,
          port: correctUri.hasPort ? correctUri.port : null,
        )
        .toString();
  }

  MenuItem copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryName,
    int? categoryId,
    int? stock,
    double? rating,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryName: categoryName ?? this.categoryName,
      categoryId: categoryId ?? this.categoryId,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
    );
  }

  @override
  List<Object?> get props => [id, name, price, imageUrl, categoryId, stock];
}
