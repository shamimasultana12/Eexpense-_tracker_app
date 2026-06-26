import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/app_colors.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/screens/home/views/home_screen.dart';
import 'package:expenses_tracker/screens/onboarding/onboarding_screen.dart';
import 'package:expenses_tracker/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppView extends StatefulWidget {
  final ExpenseRepository repository;
  const MyAppView({super.key, required this.repository});

  @override
  State<MyAppView> createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> {
  // Simple auth state — start at onboarding
  Widget _home() => OnboardingScreen(
        onDone: () => _goLogin(),
      );

  // Navigation helpers using global key
  static final _navKey = GlobalKey<NavigatorState>();

  void _goLogin() {
    _navKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginScreen(onLoginSuccess: _goHome),
      ),
    );
  }

  void _goHome() {
    _navKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider<ExpenseRepository>.value(
          value: widget.repository,
          child: BlocProvider(
            create: (_) =>
                GetExpensesBloc(widget.repository)..add(GetExpenses()),
            child: HomeScreen(onLogout: _goLogin),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ExpenseRepository>.value(
      value: widget.repository,
      child: MaterialApp(
        navigatorKey: _navKey,
        debugShowCheckedModeBanner: false,
        title: 'Expense Tracker Pro',
        theme: _buildTheme(),
        home: _home(),
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        surface: Colors.white,
        onSurface: Color(0xFF122033),
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accentAmber,
        outline: AppColors.muted,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Color(0xFF122033),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF122033),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
    );
  }
}
