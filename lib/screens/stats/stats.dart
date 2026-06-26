import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chart.dart';

class StatScreen extends StatefulWidget {
  final List<Expense> expenses;
  const StatScreen({super.key, required this.expenses});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analytics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Spending breakdown across all periods',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14122033),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.muted,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: 'Daily'),
                  Tab(text: 'Weekly'),
                  Tab(text: 'Monthly'),
                  Tab(text: 'Yearly'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _DailyView(expenses: widget.expenses),
                _WeeklyView(expenses: widget.expenses),
                _MonthlyView(expenses: widget.expenses),
                _YearlyView(expenses: widget.expenses),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily ────────────────────────────────────────────────────────────────────
class _DailyView extends StatelessWidget {
  final List<Expense> expenses;
  const _DailyView({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayExpenses = expenses.where((e) =>
        e.date.year == today.year &&
        e.date.month == today.month &&
        e.date.day == today.day).toList();
    final total =
        todayExpenses.fold<double>(0, (s, e) => s + e.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatSummaryCard(
            title: "Today's Spending",
            value: '\$${total.toStringAsFixed(2)}',
            subtitle:
                DateFormat('EEEE, dd MMM yyyy').format(today),
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Last 8 Days',
            child: MyChart(expenses: expenses),
          ),
          const SizedBox(height: 16),
          _CategoryBreakdown(expenses: todayExpenses, label: "Today's Categories"),
        ],
      ),
    );
  }
}

// ── Weekly ────────────────────────────────────────────────────────────────────
class _WeeklyView extends StatelessWidget {
  final List<Expense> expenses;
  const _WeeklyView({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - 1));
    final weekExpenses = expenses.where((e) {
      final d = e.date;
      return d.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          d.isBefore(startOfWeek.add(const Duration(days: 7)));
    }).toList();
    final total =
        weekExpenses.fold<double>(0, (s, e) => s + e.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatSummaryCard(
            title: 'This Week',
            value: '\$${total.toStringAsFixed(2)}',
            subtitle:
                '${DateFormat('dd MMM').format(startOfWeek)} – ${DateFormat('dd MMM').format(startOfWeek.add(const Duration(days: 6)))}',
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Daily Spend This Week',
            child: _WeekBarChart(expenses: expenses, startOfWeek: startOfWeek),
          ),
          const SizedBox(height: 16),
          _CategoryBreakdown(expenses: weekExpenses, label: 'Top Categories'),
        ],
      ),
    );
  }
}

class _WeekBarChart extends StatelessWidget {
  final List<Expense> expenses;
  final DateTime startOfWeek;
  const _WeekBarChart(
      {required this.expenses, required this.startOfWeek});

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final totals = days.map((d) {
      return expenses
          .where((e) =>
              e.date.year == d.year &&
              e.date.month == d.month &&
              e.date.day == d.day)
          .fold<double>(0, (s, e) => s + e.amount);
    }).toList();
    final maxY = totals.isEmpty
        ? 100.0
        : totals.reduce((a, b) => a > b ? a : b) * 1.3;
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final ratio = maxY > 0 ? totals[i] / maxY : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400 + i * 60),
                    height: 120 * ratio,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(labels[i],
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Monthly ───────────────────────────────────────────────────────────────────
class _MonthlyView extends StatelessWidget {
  final List<Expense> expenses;
  const _MonthlyView({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthExpenses = expenses.where((e) =>
        e.date.year == now.year && e.date.month == now.month).toList();
    final total =
        monthExpenses.fold<double>(0, (s, e) => s + e.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatSummaryCard(
            title: 'This Month',
            value: '\$${total.toStringAsFixed(2)}',
            subtitle: DateFormat('MMMM yyyy').format(now),
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Daily Spending',
            child: _MonthBarChart(
                expenses: monthExpenses, month: now),
          ),
          const SizedBox(height: 16),
          _CategoryBreakdown(
              expenses: monthExpenses, label: 'Category Breakdown'),
        ],
      ),
    );
  }
}

class _MonthBarChart extends StatelessWidget {
  final List<Expense> expenses;
  final DateTime month;
  const _MonthBarChart(
      {required this.expenses, required this.month});

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;
    final totals = List.generate(daysInMonth, (i) {
      final day = i + 1;
      return expenses
          .where((e) => e.date.day == day)
          .fold<double>(0, (s, e) => s + e.amount);
    });
    final maxY = totals.isEmpty
        ? 100.0
        : totals.reduce((a, b) => a > b ? a : b) * 1.3;

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(daysInMonth, (i) {
          final ratio = maxY > 0 ? totals[i] / maxY : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300 + i * 10),
                height: 100 * ratio,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Yearly ────────────────────────────────────────────────────────────────────
class _YearlyView extends StatelessWidget {
  final List<Expense> expenses;
  const _YearlyView({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final yearExpenses =
        expenses.where((e) => e.date.year == now.year).toList();
    final total =
        yearExpenses.fold<double>(0, (s, e) => s + e.amount);

    final monthly = List.generate(12, (m) {
      return yearExpenses
          .where((e) => e.date.month == m + 1)
          .fold<double>(0, (s, e) => s + e.amount);
    });
    final maxY = monthly.isEmpty
        ? 100.0
        : monthly.reduce((a, b) => a > b ? a : b) * 1.3;
    final labels = [
      'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatSummaryCard(
            title: '${now.year} Total',
            value: '\$${total.toStringAsFixed(2)}',
            subtitle: 'Jan – ${DateFormat('MMM').format(now)} ${now.year}',
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Month-by-Month',
            child: SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(12, (i) {
                  final ratio = maxY > 0 ? monthly[i] / maxY : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration:
                                Duration(milliseconds: 400 + i * 50),
                            height: 120 * ratio,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: i == now.month - 1
                                    ? [AppColors.secondary, AppColors.primary]
                                    : [
                                        AppColors.primary.withValues(alpha: 0.5),
                                        AppColors.primary,
                                      ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(labels[i],
                              style: TextStyle(
                                fontSize: 11,
                                color: i == now.month - 1
                                    ? AppColors.primary
                                    : AppColors.muted,
                                fontWeight: i == now.month - 1
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              )),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _CategoryBreakdown(
              expenses: yearExpenses, label: 'Category Breakdown'),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _StatSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  const _StatSummaryCard(
      {required this.title,
      required this.value,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
              color: Color(0x226C63FF),
              blurRadius: 20,
              offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EBF2)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A122033),
              blurRadius: 18,
              offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: -0.2)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<Expense> expenses;
  final String label;
  const _CategoryBreakdown(
      {required this.expenses, required this.label});

  @override
  Widget build(BuildContext context) {
    final map = <String, _CatData>{};
    for (final e in expenses) {
      if (map.containsKey(e.category.name)) {
        map[e.category.name] =
            map[e.category.name]!.add(e.amount);
      } else {
        map[e.category.name] = _CatData(
          name: e.category.name,
          total: e.amount,
          color: Color(e.category.color),
        );
      }
    }
    final sorted = map.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    final grandTotal =
        sorted.fold<double>(0, (s, c) => s + c.total);

    if (sorted.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: -0.2)),
        const SizedBox(height: 10),
        ...sorted.take(5).map((c) {
          final pct = grandTotal > 0 ? c.total / grandTotal : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: c.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(c.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text('\$${c.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 5,
                          backgroundColor:
                              c.color.withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(c.color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _CatData {
  final String name;
  final double total;
  final Color color;
  const _CatData(
      {required this.name, required this.total, required this.color});
  _CatData add(double amount) =>
      _CatData(name: name, total: total + amount, color: color);
}
