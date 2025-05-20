import 'package:flutter/material.dart';

// Helper methods for category colors and icons
class Helpers {
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Comida':
 case 'Food':
        return Colors.orange;
      case 'Transporte':
 case 'Transport':
        return Colors.blueAccent;
      case 'Compras':
 case 'Shopping':
        return Colors.purple;
      case 'Servicios':
        return Colors.redAccent;
      case 'Entretenimiento':
 case 'Entertainment':
        return Colors.greenAccent;
      case 'Salud':
 case 'Health':
        return Colors.pinkAccent;
      case 'Educación':
        return Colors.teal; // Added a color for Education
      case 'Otros':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Comida':
        return Icons.fastfood;
      case 'Transporte':
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
 case 'Transporte':
        return Icons.directions_car;
      default:
        return Icons.category;
    }
  }

  // List of predefined expense categories
  static List<String> get expenseCategories => ['Comida', 'Transporte', 'Compras', 'Servicios', 'Entretenimiento', 'Salud', 'Educación', 'Otros',];
}