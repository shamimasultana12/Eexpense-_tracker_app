import 'package:expenses_tracker/core/app_colors.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: 2, vsync: this);

  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _nameC = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _tabs.dispose();
    _emailC.dispose();
    _passC.dispose();
    _nameC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailC.text.trim();
    final pass = _passC.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      _snack('Please fill in all fields');
      return;
    }
    setState(() => _loading = true);
    try {
      // ── Supabase auth ─────────────────────────────────────────
      // Uncomment when Supabase is configured:
      //
      // if (_tabs.index == 0) {
      //   await Supabase.instance.client.auth.signInWithPassword(
      //     email: email, password: pass);
      // } else {
      //   await Supabase.instance.client.auth.signUp(
      //     email: email, password: pass,
      //     data: {'name': _nameC.text.trim()});
      // }
      //
      // ─────────────────────────────────────────────────────────
      await Future.delayed(const Duration(milliseconds: 600));
      widget.onLoginSuccess();
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: -40,
                right: -20,
                child: _Orb(size: 180, opacity: 0.12),
              ),
              const Positioned(
                bottom: 120,
                left: -40,
                child: _Orb(size: 140, opacity: 0.08),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white
                                  .withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'ExpenseTracker Pro',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Track spending, stay on budget.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withValues(alpha: 0.97),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x2A0F172A),
                                blurRadius: 32,
                                offset: Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF0F5),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: TabBar(
                                  controller: _tabs,
                                  indicator: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x14122033),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  indicatorSize:
                                      TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  labelColor: AppColors.primary,
                                  unselectedLabelColor:
                                      AppColors.muted,
                                  labelStyle: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                  tabs: const [
                                    Tab(text: 'Login'),
                                    Tab(text: 'Register'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              AnimatedBuilder(
                                animation: _tabs,
                                builder: (_, __) => Column(
                                  children: [
                                    if (_tabs.index == 1) ...[
                                      TextField(
                                        controller: _nameC,
                                        decoration:
                                            const InputDecoration(
                                          hintText: 'Full Name',
                                          prefixIcon: Icon(
                                              Icons.person_outline),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    TextField(
                                      controller: _emailC,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        hintText: 'Email',
                                        prefixIcon: Icon(
                                            Icons.email_outlined),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _passC,
                                      obscureText: _obscure,
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                        prefixIcon: const Icon(
                                            Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscure
                                              ? Icons
                                                  .visibility_off_outlined
                                              : Icons
                                                  .visibility_outlined),
                                          onPressed: () => setState(
                                              () => _obscure =
                                                  !_obscure),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: _loading
                                    ? const Center(
                                        child:
                                            CircularProgressIndicator())
                                    : FilledButton(
                                        onPressed: _submit,
                                        child: AnimatedBuilder(
                                          animation: _tabs,
                                          builder: (_, __) => Text(
                                            _tabs.index == 0
                                                ? 'Login'
                                                : 'Create Account',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final double opacity;
  const _Orb({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}
