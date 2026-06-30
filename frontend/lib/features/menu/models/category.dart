import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MenuCategory extends Equatable {
  final String id;
  final String name;
  final IconData icon;

  const MenuCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  static List<MenuCategory> get defaults => const [
    MenuCategory(id: 'all', name: 'All', icon: Icons.grid_view_rounded),
    MenuCategory(
      id: 'main_course',
      name: 'Main Course',
      icon: Icons.restaurant_rounded,
    ),
    MenuCategory(id: 'drinks', name: 'Drinks', icon: Icons.local_drink_rounded),
    MenuCategory(id: 'snacks', name: 'Snacks', icon: Icons.fastfood_rounded),
    MenuCategory(id: 'desserts', name: 'Desserts', icon: Icons.cake_rounded),
  ];

  @override
  List<Object?> get props => [id, name];
}
