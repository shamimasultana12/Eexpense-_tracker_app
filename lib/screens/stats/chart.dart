import 'dart:math';
import 'package:expense_repository/expense_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyChart extends StatefulWidget {
  final List<Expense> expenses;
  const MyChart({super.key, required this.expenses});

  @override
  State<MyChart> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  late List<double> dailyExpenses;

  @override
  void initState() {
    super.initState();
    dailyExpenses = _calculateDailyExpenses();
  }

  List<double> _calculateDailyExpenses() {
    List<double> daily = List.filled(8, 0);
    final now = DateTime.now();

    for (var expense in widget.expenses) {
      final expenseDate = expense.date;
      final dayDifference = now.difference(expenseDate).inDays;

      if (dayDifference >= 0 && dayDifference < 8) {
        daily[7 - dayDifference] += expense.amount;
      }
    }

    return daily;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: BarChart(
        mainBarData(),
      ),
    );
  }

  double get _maxY {
    final maxExpense = dailyExpenses.isEmpty
        ? 0.0
        : dailyExpenses.reduce((a, b) => a > b ? a : b);
    return maxExpense <= 0 ? 100 : maxExpense * 1.35;
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
          toY: y == 0 ? 0.1 : y,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.tertiary,
            ],
            transform: const GradientRotation(pi / 40),
          ),
          width: 18,
          borderRadius: BorderRadius.circular(12),
          backDrawRodData: BackgroundBarChartRodData(
              show: true, toY: _maxY, color: const Color(0xFFEAEFF5)))
    ]);
  }

  List<BarChartGroupData> showingGroups() => List.generate(8, (i) {
        return makeGroupData(i, dailyExpenses[i]);
      });

  BarChartData mainBarData() {
    return BarChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 38,
          getTitlesWidget: getTiles,
        )),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: leftTitles,
          ),
        ),
      ),
      maxY: _maxY,
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups: showingGroups(),
    );
  }

  Widget getTiles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w700,
      fontSize: 12,
    );
    Widget text;

    switch (value.toInt()) {
      case 0:
        text = Text('01', style: style);
        break;
      case 1:
        text = Text('02', style: style);
        break;
      case 2:
        text = Text('03', style: style);
        break;
      case 3:
        text = Text('04', style: style);
        break;
      case 4:
        text = Text('05', style: style);
        break;
      case 5:
        text = Text('06', style: style);
        break;
      case 6:
        text = Text('07', style: style);
        break;
      case 7:
        text = Text('08', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w700,
      fontSize: 12,
    );
    String text;
    if (value == 0) {
      text = '0';
    } else if (value == _maxY / 4) {
      text = '${(_maxY / 4).round()}';
    } else if (value == _maxY / 2) {
      text = '${(_maxY / 2).round()}';
    } else if (value == _maxY * 0.75) {
      text = '${(_maxY * 0.75).round()}';
    } else if (value == _maxY) {
      text = '${_maxY.round()}';
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }
}
