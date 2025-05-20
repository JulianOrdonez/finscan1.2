import 'package:flutter/material.dart';

// Helper methods for category colors and icons
class Helpers {
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Comida':
        return Colors.orange;
      case 'Transporte':
        return Colors.blueAccent;
      case 'Compras':
        return Colors.purple;
      case 'Servicios':
        return Colors.redAccent;
      case 'Entretenimiento':
        return Colors.greenAccent;
      case 'Salud':
        return Colors.pinkAccent;
 case 'Educación':
 return Colors.teal; // Added a color for Education
      default:
        return Colors.grey;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
 case 'Comida':
        return Icons.fastfood;
      case 'Transport':
 case 'Transporte':
        return Icons.directions_car;
      case 'Shopping':
 case 'Compras':
        return Icons.shopping_cart;
 case 'Servicios':
        return Icons.lightbulb;
 case 'Entretenimiento':
        return Icons.movie;
      case 'Health':
 case 'Salud':
        return Icons.favorite;
 case 'Educación':
 return Icons.school; // Added an icon for Education
      default:
        return Icons.category;
    }
  }

  // List of predefined expense categories
  static List<String> get expenseCategories => [
        'Food',
        'Transporte',
        'Compras',
        'Servicios',
        'Entretenimiento',
        'Salud',
        'Education',
        'Otros',
      ];
}