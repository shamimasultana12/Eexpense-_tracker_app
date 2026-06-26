import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'app_view.dart';

class MyApp extends StatelessWidget {
  final ExpenseRepository repository;
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) => MyAppView(repository: repository);
}
