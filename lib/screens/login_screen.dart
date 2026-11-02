import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/ui.dart';
import 'main_screen.dart';
import 'registrasi_screen.dart';

/// Padanan AuthActivity + LoginFragment.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Palet
  static const _bg = Color(0xFFF7F1E8);
  static const _ink = Color(0xFF2B2420);
  static const _muted = Color(0xFF8C8178);
  static const _accent = Color(0xFF9A4A32);
  static const _line = Color(0xFFD9CFC2);

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _hidePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage(context, 'Email dan Password harus diisi.');
      return;
    }

    setState(() => _loading = true);
    final result = await ApiService.login(email, password);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      showMessage(context, result.message);
    }
  }

  /// Buka halaman daftar. Kalau berhasil daftar, email otomatis terisi di login.
  Future<void> _openRegister() async {
    final email = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (email != null && mounted) {
      _emailCtrl.text = email;
      _passwordCtrl.clear();
      _passwordFocus.requestFocus();
    }
  }

  InputDecoration _fieldDecoration(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _muted, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: _accent, fontSize: 13),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _line),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _accent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),
                      const Text(
                        'tabebuya',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          letterSpacing: 1.2,
                          color: _accent,
                        ),
                      ),
                      const SizedBox(height: 64),
                      const Text(
                        'Meja favoritmu\nsudah menunggu.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 34,
                          height: 1.2,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Masuk untuk melihat reservasi dan memesan tempat.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(height: 44),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                        cursorColor: _accent,
                        style: const TextStyle(color: _ink),
                        decoration: _fieldDecoration('Email'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordCtrl,
                        focusNode: _passwordFocus,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        cursorColor: _accent,
                        style: const TextStyle(color: _ink),
                        decoration: _fieldDecoration(
                          'Password',
                          suffix: IconButton(
                            splashRadius: 20,
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: _muted,
                            ),
                            onPressed: () => setState(
                              () => _hidePassword = !_hidePassword,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: halaman lupa password
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: _muted,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Lupa password?',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: _accent,
                            disabledBackgroundColor:
                                _accent.withValues(alpha: 0.6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Belum punya akun? ',
                                style: TextStyle(color: _muted, fontSize: 13),
                              ),
                              GestureDetector(
                                onTap: _openRegister,
                                child: const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    color: _accent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}