import 'package:flutter/material.dart';

class Helpers {
  static Color getCategoryColor(String category) {
    final Map<String, Color> categoryColors = {
      'Alimentación': Colors.orange,
      'Transporte': Colors.blue,
      'Entretenimiento': Colors.purple,
      'Salud': Colors.red,
      'Educación': Colors.green,
      'Hogar': Colors.brown,
      'Ropa': Colors.pink,
      'Otros': Colors.grey,
    };

    return categoryColors[category] ?? Colors.grey;
  }

  static IconData getCategoryIcon(String category) {
    final Map<String, IconData> categoryIcons = {
      'Alimentación': Icons.restaurant,
      'Transporte': Icons.directions_car,
      'Entretenimiento': Icons.movie,
      'Salud': Icons.favorite,
      'Educación': Icons.school,
      'Hogar': Icons.home,
      'Ropa': Icons.shopping_bag,
      'Otros': Icons.category,
    };

    return categoryIcons[category] ?? Icons.category;
  }
}