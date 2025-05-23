import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String? id;
  String userId;
  String? title;
  String description;
  double amount;
  String category;
  String date;
  String? receiptPath;

  Expense({
    this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.amount,
    required this.category,
    required this.date,
    this.receiptPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date,
      'receiptPath': receiptPath,
    };
  }

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      userId: map['user_id'],
      title: map['title'],
      description: map['description'] ?? '',
      amount: map['amount'] is int ? (map['amount'] as int).toDouble() : map['amount'],
      category: map['category'],
      date: map['date'],
      // Firestore stores timestamp, convert to String if needed or handle as Timestamp
      // For simplicity here, assuming date is stored as String
      receiptPath: map['receiptPath'] as String?,
    );
  }
}