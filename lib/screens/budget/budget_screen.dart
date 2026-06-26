import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  final List<Expense> expenses;
  const BudgetScreen({super.key, required this.expenses});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final Map<String, double> _budgets = {};

  Map<String, double> get _spendByCategory {
    final map = <String, double>{};
    final now = DateTime.now();
    for (final e in widget.expenses) {
      if (e.date.year == now.year && e.date.month == now.month) {
        map[e.category.categoryId] =
            (map[e.category.categoryId] ?? 0) + e.amount;
      }
    }
    return map;
  }

  Set<String> get _categories {
    return widget.expenses.map((e) => e.category.categoryId).toSet();
  }

  String _categoryName(String id) {
    return widget.expenses
        .firstWhere((e) => e.category.categoryId == id,
            orElse: () => widget.expenses.first)
        .category
        .name;
  }

  Color _categoryColor(String id) {
    return Color(widget.expenses
        .firstWhere((e) => e.category.categoryId == id,
            orElse: () => widget.expenses.first)
        .category
        .color);
  }

  void _showSetBudgetDialog(String categoryId, String categoryName) {
    final controller = TextEditingController(
      text: _budgets[categoryId]?.toStringAsFixed(0) ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set Budget — $categoryName'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monthly budget amount',
            prefixText: '\$ ',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                setState(() => _budgets[categoryId] = val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spend = _spendByCategory;
    final categories = _categories.toList();
    final over = categories
        .where((id) =>
            _budgets.containsKey(id) &&
            (spend[id] ?? 0) >= (_budgets[id] ?? 0))
        .length;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Budget Manager',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          if (over > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.danger),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$over ${over == 1 ? 'category' : 'categories'} over budget this month',
                      style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          const Text(
            'This Month',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          if (categories.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No transactions yet.\nAdd expenses to set budgets.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted)),
              ),
            )
          else
            ...categories.map((id) {
              final budget = _budgets[id];
              final spent = spend[id] ?? 0;
              final progress = budget != null && budget > 0
                  ? (spent / budget).clamp(0.0, 1.0)
                  : 0.0;
              final isOver = budget != null && spent >= budget;
              final isWarning = budget != null && spent >= budget * 0.8;
              final barColor = isOver
                  ? AppColors.danger
                  : isWarning
                      ? AppColors.accentAmber
                      : _categoryColor(id);

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOver
                        ? AppColors.danger.withValues(alpha: 0.3)
                        : const Color(0xFFE6EBF2),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A122033),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _categoryColor(id)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _categoryName(id)[0].toUpperCase(),
                              style: TextStyle(
                                color: _categoryColor(id),
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _categoryName(id),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                budget != null
                                    ? '\$${spent.toStringAsFixed(0)} / \$${budget.toStringAsFixed(0)}'
                                    : 'No budget set',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isOver
                                      ? AppColors.danger
                                      : AppColors.muted,
                                  fontWeight: isOver
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              _showSetBudgetDialog(id, _categoryName(id)),
                          icon: Icon(
                            budget != null
                                ? Icons.edit_rounded
                                : Icons.add_circle_outline_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (budget != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor:
                              barColor.withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(barColor),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% used',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOver ? AppColors.danger : AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
