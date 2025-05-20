import 'package:flutter/material.dart';

// Helper methods for category colors and icons
class Helpers {
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blueAccent;
      case 'Shopping':
        return Colors.purple;
      case 'Utilities':
        return Colors.redAccent;
      case 'Entertainment':
        return Colors.greenAccent;
      case 'Health':
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_cart;
      case 'Utilities':
        return Icons.lightbulb;
      case 'Entertainment':
        return Icons.movie;
      case 'Health':
        return Icons.favorite;
      default:
        return Icons.category;
    }
  }

  // List of predefined expense categories
  static List<String> get expenseCategories => [
        'Food',
        'Transport',
        'Shopping',
        'Utilities',
        'Entertainment',
        'Health',
        'Education',
        'Other',
      ];
}