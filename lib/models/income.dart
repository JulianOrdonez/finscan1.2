class Income {
  int? id;
  final int userId;
  final String title;
  final String description;
  final double amount;
  final String date;

  Income({
    this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.amount,
    required this.date,
  });

  // Convertir un objeto Income a un Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'amount': amount, // Store as double
      'date': date,
    };
  }

  // Crear un objeto Income a partir de un Map
  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'] ?? '',
      amount: map['amount'],
      date: map['date'],
    );
  }
}