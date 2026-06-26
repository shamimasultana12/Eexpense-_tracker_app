import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/app_colors.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/views/add_expense.dart';
import 'package:expenses_tracker/screens/budget/budget_screen.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/screens/home/views/main_screen.dart';
import 'package:expenses_tracker/screens/reports/reports_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import '../../stats/stats.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetExpensesBloc, GetExpensesState>(
      builder: (context, state) {
        if (state is GetExpensesFailure) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<GetExpensesBloc>().add(GetExpenses()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! GetExpensesSuccess) {
          return const Scaffold(
            backgroundColor: AppColors.bgLight,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final expenses = state.expenses;

        final screens = [
          MainScreen(expenses, onLogout: widget.onLogout),
          StatScreen(expenses: expenses),
          BudgetScreen(expenses: expenses),
          ReportsScreen(expenses: expenses),
        ];

        return Scaffold(
          backgroundColor: AppColors.bgLight,
          body: IndexedStack(
            index: _index,
            children: screens,
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE6EBF2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                currentIndex: _index,
                onTap: (v) => setState(() => _index = v),
                showSelectedLabels: true,
                showUnselectedLabels: false,
                selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 11),
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.muted,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.graph_square_fill),
                    label: 'Stats',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.chart_pie_fill),
                    label: 'Budget',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.doc_chart_fill),
                    label: 'Reports',
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 72),
            child: FloatingActionButton(
              onPressed: () async {
                final repo = context.read<ExpenseRepository>();
                final newExpense = await Navigator.push<Expense>(
                  context,
                  MaterialPageRoute<Expense>(
                    builder: (_) => _AddExpensePage(repo: repo),
                  ),
                );
                if (newExpense != null) {
                  setState(() => expenses.insert(0, newExpense));
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: const CircleBorder(),
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x446C63FF),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    transform: GradientRotation(pi / 4),
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddExpensePage extends StatelessWidget {
  final ExpenseRepository repo;
  const _AddExpensePage({required this.repo});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ExpenseRepository>.value(
      value: repo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CreateCategoryBloc(repo)),
          BlocProvider(
            create: (_) => GetCategoriesBloc(repo)..add(GetCategories()),
          ),
          BlocProvider(create: (_) => CreateExpenseBloc(repo)),
        ],
        child: const AddExpense(),
      ),
    );
  }
}
