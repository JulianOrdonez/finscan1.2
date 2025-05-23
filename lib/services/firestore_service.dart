import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/models/expense.dart';
import 'package:flutter_application_2/models/income.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Expense CRUD operations
  Future<void> addExpense(String userId, Expense expense) async {
    await _firestore.collection('users').doc(userId).collection('expenses').add(expense.toJson());
  }
  Stream<List<Expense>> getExpenses(String userId) {
    return _firestore.collection('users').doc(userId).collection('expenses').snapshots().map((snapshot) => snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }
  Future<void> updateExpense(String userId, Expense expense) async {
    await _firestore.collection('users').doc(userId).collection('expenses').doc(expense.id!).set(expense.toJson());
  }
  Future<void> deleteExpense(String userId, String expenseId) async {
    await _firestore.collection('users').doc(userId).collection('expenses').doc(expenseId).delete();
  }

  // Income CRUD operations
  Future<void> addIncome(String userId, Income income) async {
    await _firestore.collection('users').doc(userId).collection('incomes').add(income.toJson());
  }
  Stream<List<Income>> getIncomes(String userId) {
    return _firestore.collection('users').doc(userId).collection('incomes').snapshots().map((snapshot) => snapshot.docs.map((doc) => Income.fromFirestore(doc)).toList());
  }
  Future<void> updateIncome(String userId, Income income) async {
    await _firestore.collection('users').doc(userId).collection('incomes').doc(income.id!).set(income.toJson());
  }
  Future<void> deleteIncome(String userId, String incomeId) async {
    await _firestore.collection('users').doc(userId).collection('incomes').doc(incomeId).delete();
  }
}