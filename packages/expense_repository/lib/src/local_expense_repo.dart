part of 'package:expense_repository/expense_repository.dart';

class LocalExpenseRepo implements ExpenseRepository {
  static final List<Category> _categories = [
    const Category(
      categoryId: 'cat_food',
      name: 'Food',
      icon: 'food',
      color: 0xFFFFC107,
    ),
    const Category(
      categoryId: 'cat_shopping',
      name: 'Shopping',
      icon: 'shopping',
      color: 0xFF9C27B0,
    ),
    const Category(
      categoryId: 'cat_health',
      name: 'Health',
      icon: 'pet',
      color: 0xFF4CAF50,
    ),
    const Category(
      categoryId: 'cat_travel',
      name: 'Travel',
      icon: 'travel',
      color: 0xFF2196F3,
    ),
    const Category(
      categoryId: 'cat_home',
      name: 'Home',
      icon: 'home',
      color: 0xFFFF7043,
    ),
    const Category(
      categoryId: 'cat_tech',
      name: 'Tech',
      icon: 'tech',
      color: 0xFF00BCD4,
    ),
    const Category(
      categoryId: 'cat_entertainment',
      name: 'Entertainment',
      icon: 'entertainment',
      color: 0xFF795548,
    ),
  ];

  static final List<Expense> _expenses = [
    Expense(
      expenseId: 'exp_food_1',
      amount: 45,
      category: _categories[0],
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Expense(
      expenseId: 'exp_travel_1',
      amount: 350,
      category: _categories[3],
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Expense(
      expenseId: 'exp_tech_1',
      amount: 220,
      category: _categories[5],
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  @override
  Future<List<Category>> getCategories() async {
    return _categories;
  }

  @override
  Future<List<Expense>> getExpenses() async {
    _expenses.sort((left, right) => right.date.compareTo(left.date));
    return _expenses;
  }

  @override
  Future<void> createCategory(Category category) async {
    _categories.insert(0, category);
  }

  @override
  Future<void> createExpense(Expense expense) async {
    _expenses.insert(0, expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final index = _expenses.indexWhere(
      (item) => item.expenseId == expense.expenseId,
    );

    if (index != -1) {
      _expenses[index] = expense;
    }
  }

  @override
  Future<void> deleteExpense(Expense expense) async {
    _expenses.removeWhere((item) => item.expenseId == expense.expenseId);
  }
}
