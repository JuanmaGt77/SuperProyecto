import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? iconUrl;
  final String colorHex;
  final bool isActive;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconUrl,
    this.colorHex = '#1A56DB',
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      colorHex: json['color_hex'] as String? ?? '#1A56DB',
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Color get color {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get fallbackIcon {
    switch (slug) {
      case 'mecanico': return Icons.directions_car_rounded;
      case 'albanil': return Icons.construction_rounded;
      case 'electricista': return Icons.bolt_rounded;
      case 'soldador': return Icons.local_fire_department_rounded;
      case 'plomero': return Icons.plumbing_rounded;
      default: return Icons.handyman_rounded;
    }
  }

  Color get fallbackColor {
    switch (slug) {
      case 'mecanico': return AppColors.catMechanico;
      case 'albanil': return AppColors.catAlbanil;
      case 'electricista': return AppColors.catElectricista;
      case 'soldador': return AppColors.catSoldador;
      case 'plomero': return AppColors.catPlomero;
      default: return AppColors.primary;
    }
  }

  // Local fallback list (when DB is not yet seeded)
  static List<CategoryModel> get defaults => const [
        CategoryModel(
          id: 'mecanico',
          slug: 'mecanico',
          name: 'Mecánico',
          colorHex: '#EF4444',
          sortOrder: 1,
        ),
        CategoryModel(
          id: 'albanil',
          slug: 'albanil',
          name: 'Albañil',
          colorHex: '#F97316',
          sortOrder: 2,
        ),
        CategoryModel(
          id: 'electricista',
          slug: 'electricista',
          name: 'Electricista',
          colorHex: '#EAB308',
          sortOrder: 3,
        ),
        CategoryModel(
          id: 'soldador',
          slug: 'soldador',
          name: 'Soldador',
          colorHex: '#3B82F6',
          sortOrder: 4,
        ),
        CategoryModel(
          id: 'plomero',
          slug: 'plomero',
          name: 'Plomero',
          colorHex: '#22C55E',
          sortOrder: 5,
        ),
      ];

  @override
  List<Object?> get props => [id, slug];
}
