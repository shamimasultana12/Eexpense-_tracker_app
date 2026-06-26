part of 'package:expense_repository/expense_repository.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();
  Future<List<Category>> getCategories();
  Future<void> createExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(Expense expense);
  Future<void> createCategory(Category category);
}
