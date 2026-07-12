import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MenuCategory extends Equatable {
  final int id;
  final String name;
  final IconData icon;
  final int? targetJumlahMenu;

  const MenuCategory({
    required this.id,
    required this.name,
    this.icon = Icons.restaurant_rounded,
    this.targetJumlahMenu,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: json['nama_kategori'] as String? ?? '',
      targetJumlahMenu: json['target_jumlah_menu'] as int?,
    );
  }

  static MenuCategory get allCategory =>
      const MenuCategory(id: 0, name: 'Semua', icon: Icons.grid_view_rounded);

  static IconData iconForName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('minum') ||
        lower.contains('drink') ||
        lower.contains('juice')) {
      return Icons.local_drink_rounded;
    }
    if (lower.contains('snack') ||
        lower.contains('cemilan') ||
        lower.contains('gorengan')) {
      return Icons.fastfood_rounded;
    }
    if (lower.contains('dessert') ||
        lower.contains('kue') ||
        lower.contains('cake')) {
      return Icons.cake_rounded;
    }
    if (lower.contains('nasi') ||
        lower.contains('rice') ||
        lower.contains('bowl')) {
      return Icons.rice_bowl_rounded;
    }
    if (lower.contains('mie') ||
        lower.contains('noodle') ||
        lower.contains('ramen')) {
      return Icons.ramen_dining_rounded;
    }
    return Icons.restaurant_rounded;
  }

  @override
  List<Object?> get props => [id, name];
}
