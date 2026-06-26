import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/app.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Using LocalExpenseRepo by default.
  // To use Supabase, replace with SupabaseExpenseRepo after configuring credentials.
  final repository = LocalExpenseRepo();
  runApp(MyApp(repository: repository));
}
