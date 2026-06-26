part of 'package:expense_repository/expense_repository.dart';

class SupabaseExpenseRepo implements ExpenseRepository {
  final dynamic _client; // SupabaseClient — dynamic to avoid hard dep

  SupabaseExpenseRepo(this._client);

  // ── helpers ──────────────────────────────────────────────────────────────

  String get _uid {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return user.id as String;
  }

  Category _catFromRow(Map<String, dynamic> row) => Category(
        categoryId: row['id'] as String,
        name: row['name'] as String,
        icon: row['icon'] as String,
        color: int.parse((row['color'] as String).replaceFirst('#', 'FF'),
            radix: 16),
      );

  Expense _expFromRow(Map<String, dynamic> row) => Expense(
        expenseId: row['id'] as String,
        amount: (row['amount'] as num).toDouble(),
        category: _catFromRow(row['categories'] as Map<String, dynamic>),
        date: DateTime.parse(row['date'] as String),
      );

  String _colorHex(int color) =>
      '#${color.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  // ── categories ────────────────────────────────────────────────────────────

  @override
  Future<List<Category>> getCategories() async {
    final rows = await _client
        .from('categories')
        .select()
        .or('is_global.eq.true,created_by.eq.$_uid')
        .order('name') as List<dynamic>;
    return rows
        .map((r) => _catFromRow(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createCategory(Category category) async {
    await _client.from('categories').insert({
      'id': category.categoryId,
      'name': category.name,
      'icon': category.icon,
      'color': _colorHex(category.color),
      'is_global': false,
      'created_by': _uid,
    });
  }

  // ── expenses ──────────────────────────────────────────────────────────────

  @override
  Future<List<Expense>> getExpenses() async {
    final rows = await _client
        .from('transactions')
        .select('*, categories(*)')
        .eq('uid', _uid)
        .eq('type', 'expense')
        .order('date', ascending: false) as List<dynamic>;
    return rows
        .map((r) => _expFromRow(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createExpense(Expense expense) async {
    await _client.from('transactions').insert({
      'id': expense.expenseId,
      'uid': _uid,
      'type': 'expense',
      'amount': expense.amount,
      'category_id': expense.category.categoryId,
      'date': expense.date.toIso8601String(),
    });
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await _client.from('transactions').update({
      'amount': expense.amount,
      'category_id': expense.category.categoryId,
      'date': expense.date.toIso8601String(),
    }).eq('id', expense.expenseId);
  }

  @override
  Future<void> deleteExpense(Expense expense) async {
    await _client
        .from('transactions')
        .delete()
        .eq('id', expense.expenseId);
  }
}
