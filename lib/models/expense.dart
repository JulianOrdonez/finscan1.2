class Expense {
  int id;
  int userId;
  String title;
  String description;
  double amount;
  String category;
  String date;
  String receiptPath;

  Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.receiptPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date,
      'receiptPath': receiptPath,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'],
      receiptPath: map['receiptPath'],
    );
  }
}