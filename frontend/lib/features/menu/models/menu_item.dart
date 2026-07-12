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

  // ── Helpers ──────────────────────────────────────────────────────────────

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

  /// Bangun URL gambar yang bisa dibuka oleh Flutter Web maupun Mobile.
  ///
  /// Backend mengembalikan [gambarUrl] = full URL via /api/image/
  /// Fallback ke [rawGambar] (path relatif) jika gambar_url tidak ada.
  static String _resolveImageUrl(dynamic gambarUrl, dynamic rawGambar) {
    // Prioritas 1: gambar_url dari backend (sudah full URL via /api/image/)
    final url1 = gambarUrl?.toString() ?? '';
    if (url1.isNotEmpty) return url1;

    // Prioritas 2: gambar (path relatif) → buat URL via /api/image/
    final raw = rawGambar?.toString() ?? '';
    if (raw.isEmpty) return AppConstants.placeholderFood;

    if (raw.startsWith('http')) return raw;

    // Relative path "uploads/menus/xxx.jpg" → /api/image/uploads/menus/xxx.jpg
    final cleaned = raw.startsWith('/') ? raw.substring(1) : raw;
    return '${AppConstants.baseUrl}/image/$cleaned';
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
