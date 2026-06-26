part of 'package:expense_repository/expense_repository.dart';

class Expense extends Equatable {
  final String expenseId;
  final double amount;
  final Category category;
  final DateTime date;

  const Expense({
    required this.expenseId,
    required this.amount,
    required this.category,
    required this.date,
  });

  static final Expense empty = Expense(
    expenseId: '',
    amount: 0,
    category: Category.empty,
    date: DateTime.now(),
  );

  Expense copyWith({
    String? expenseId,
    double? amount,
    Category? category,
    DateTime? date,
  }) {
    return Expense(
      expenseId: expenseId ?? this.expenseId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  @override
  List<Object> get props => [expenseId, amount, category, date];
}
