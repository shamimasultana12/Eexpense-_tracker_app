import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  final List<Expense> expenses;
  const ReportsScreen({super.key, required this.expenses});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  List<Expense> get _filtered => widget.expenses.where((e) {
        return !e.date.isBefore(_range.start) &&
            !e.date.isAfter(_range.end.add(const Duration(days: 1)));
      }).toList();

  double get _total =>
      _filtered.fold(0, (sum, e) => sum + e.amount);

  Map<String, double> get _byCategory {
    final map = <String, double>{};
    for (final e in _filtered) {
      map[e.category.name] = (map[e.category.name] ?? 0) + e.amount;
    }
    final sorted = Map.fromEntries(
        map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    return sorted;
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  void _exportCSV() {
    final lines = [
      'Date,Category,Amount',
      ..._filtered.map((e) =>
          '${DateFormat('yyyy-MM-dd').format(e.date)},${e.category.name},${e.amount.toStringAsFixed(2)}'),
    ];
    final csv = lines.join('\n');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV ready (${_filtered.length} rows). Share: $csv'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final byCategory = _byCategory;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Reports & Export',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonal(
              onPressed: _exportCSV,
              child: const Text('Export CSV'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          GestureDetector(
            onTap: _pickRange,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE6EBF2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded,
                      color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date Range',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('dd MMM yyyy').format(_range.start)}  →  ${DateFormat('dd MMM yyyy').format(_range.end)}',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Transactions',
                  value: '${_filtered.length}',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Total Spent',
                  value: '\$${_total.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('By Category',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: -0.2)),
          const SizedBox(height: 12),
          if (byCategory.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('No data in selected range.',
                    style: TextStyle(color: AppColors.muted)),
              ),
            )
          else
            ...byCategory.entries.map((entry) {
              final pct = _total > 0 ? entry.value / _total : 0.0;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE6EBF2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        Text(
                          '\$${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.danger),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(pct * 100).toStringAsFixed(1)}% of total',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 20),
          const Text('Transactions',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: -0.2)),
          const SizedBox(height: 12),
          if (_filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('No transactions in this range.',
                    style: TextStyle(color: AppColors.muted)),
              ),
            )
          else
            ..._filtered.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE6EBF2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.category.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          Text(
                            DateFormat('dd MMM yyyy').format(e.date),
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.muted),
                          ),
                        ],
                      ),
                      Text(
                        '-\$${e.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.danger,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
