import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/views/add_expense.dart';
import 'package:expenses_tracker/screens/settings/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatelessWidget {
  final List<Expense> expenses;
  final VoidCallback onLogout;

  const MainScreen(this.expenses, {super.key, required this.onLogout});

  double get totalExpenses {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  String get totalExpensesFormatted {
    return '\$ ${totalExpenses.toStringAsFixed(2)}';
  }

  String get expensesFormatted {
    return '\$ ${totalExpenses.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE6EBF2)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A122033),
                      blurRadius: 22,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary.withValues(alpha: 0.16),
                                colorScheme.secondary.withValues(alpha: 0.12),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            CupertinoIcons.person_fill,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'John Doe',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                                letterSpacing: -0.2,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    IconButton.filledTonal(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SettingsScreen(
                              onLogout: onLogout,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(CupertinoIcons.settings),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                      colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x220B63F6),
                      blurRadius: 28,
                      offset: Offset(0, 16),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Live',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      totalExpensesFormatted,
                      style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: _BalanceStatCard(
                            label: 'Income',
                            value: '\$ 0.00',
                            icon: CupertinoIcons.arrow_down,
                            iconColor: Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BalanceStatCard(
                            label: 'Expenses',
                            value: expensesFormatted,
                            icon: CupertinoIcons.arrow_up,
                            iconColor: Colors.redAccent,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transactions',
                    style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => _TransactionsSheet(
                          expenses: expenses,
                        ),
                      );
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.outline,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return ListView.builder(
                    itemCount: expenses.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, int i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE6EBF2)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A122033),
                                blurRadius: 18,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Color(
                                                expenses[i].category.color),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/${expenses[i].category.icon}.png',
                                          scale: 2,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expenses[i].category.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('dd/MM/yyyy')
                                              .format(expenses[i].date),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colorScheme.outline,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton.filledTonal(
                                      tooltip: 'Edit',
                                      onPressed: () async {
                                        final updatedExpense =
                                            await Navigator.push<Expense>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                  create: (context) =>
                                                      CreateCategoryBloc(
                                                    context.read<
                                                        ExpenseRepository>(),
                                                  ),
                                                ),
                                                BlocProvider(
                                                  create: (context) =>
                                                      GetCategoriesBloc(
                                                    context.read<
                                                        ExpenseRepository>(),
                                                  )..add(GetCategories()),
                                                ),
                                                BlocProvider(
                                                  create: (context) =>
                                                      CreateExpenseBloc(
                                                    context.read<
                                                        ExpenseRepository>(),
                                                  ),
                                                ),
                                              ],
                                              child: AddExpense(
                                                expenseToEdit: expenses[i],
                                              ),
                                            ),
                                          ),
                                        );

                                        if (updatedExpense != null) {
                                          setState(() {
                                            final index = expenses.indexWhere(
                                              (item) =>
                                                  item.expenseId ==
                                                  updatedExpense.expenseId,
                                            );
                                            if (index != -1) {
                                              expenses[index] = updatedExpense;
                                            }
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.edit_rounded),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton.filled(
                                      tooltip: 'Delete',
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFE8505B),
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () async {
                                        final expenseRepository =
                                            context.read<ExpenseRepository>();
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        final confirmDelete =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (dialogContext) =>
                                              AlertDialog(
                                            title:
                                                const Text('Delete expense?'),
                                            content: const Text(
                                              'This will remove the transaction from your list.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    dialogContext, false),
                                                child: const Text('Cancel'),
                                              ),
                                              FilledButton(
                                                onPressed: () => Navigator.pop(
                                                    dialogContext, true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmDelete == true) {
                                          final removedExpense = expenses[i];
                                          await expenseRepository
                                              .deleteExpense(removedExpense);

                                          setState(() {
                                            expenses.removeAt(i);
                                          });

                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Transaction deleted'),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.delete_rounded),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _BalanceStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsSheet extends StatelessWidget {
  final List<Expense> expenses;

  const _TransactionsSheet({required this.expenses});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${expenses.length} items',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: expenses.isEmpty
                        ? const Center(
                            child: Text('No transactions yet.'),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: expenses.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final expense = expenses[index];

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Color(expense.category.color),
                                    child: Image.asset(
                                      'assets/${expense.category.icon}.png',
                                      scale: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(expense.category.name),
                                  subtitle: Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(expense.date),
                                  ),
                                  trailing: Text(
                                    '\$${expense.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
