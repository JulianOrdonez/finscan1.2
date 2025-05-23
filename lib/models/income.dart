import 'package:cloud_firestore/cloud_firestore.dart';

class Income {
  String? id; // Changed id type to String?
  // userId is no longer needed in the model if using Firebase Auth UID
  final String userId;
  final String title;
  final String description;
  final double amount;
  final String date;

  Income({
    this.id, // Changed id type to String?
    required this.userId,
    required this.title,
    this.description = '',
    required this.amount,
    required this.date,
  });

  // Convertir un objeto Income a un Map
  Map<String, dynamic> toJson() { // Renamed to toJson
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'amount': amount, // Store as double
      'date': date,
    };
  }

  // Crear un objeto Income a partir de un Map
  factory Income.fromFirestore(DocumentSnapshot doc) { // Renamed to fromFirestore and takes DocumentSnapshot
    final map = doc.data() as Map<String, dynamic>;
    return Income(
      id: doc.id, // Get id from DocumentSnapshot
      userId: map['user_id'],
      title: map['title'],
      description: map['description'] ?? '',
      amount: map['amount'] is int ? (map['amount'] as int).toDouble() : map['amount'], // Handle potential int amount from Firestore
      date: map['date'], // Assuming date is stored as String in Firestore
    );
  }
}