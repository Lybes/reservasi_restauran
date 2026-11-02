import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/ui.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Palet (sama dengan login)
  static const _bg = Color(0xFFF7F1E8);
  static const _ink = Color(0xFF2B2420);
  static const _muted = Color(0xFF8C8178);
  static const _accent = Color(0xFF9A4A32);
  static const _line = Color(0xFFD9CFC2);

  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String _role = 'pelanggan';
  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;

    final nama = _namaCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (nama.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      showMessage(context, 'Semua kolom harus diisi.');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      showMessage(context, 'Format email tidak valid.');
      return;
    }
    if (password.length < 6) {
      showMessage(context, 'Password minimal 6 karakter.');
      return;
    }
    if (password != confirm) {
      showMessage(context, 'Konfirmasi password tidak sama.');
      return;
    }

    setState(() => _loading = true);
    final result = await ApiService.register(nama, email, password, role: _role);
    if (!mounted) return;
    setState(() => _loading = false);

    showMessage(context, result.message);
    if (result.success) {
      Navigator.of(context).pop(email); // kembali ke login, bawa email
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

  Widget _eye(bool hidden, VoidCallback onTap) {
    return IconButton(
      splashRadius: 20,
      icon: Icon(
        hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
        color: _muted,
      ),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'tabebuya',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 22,
                  letterSpacing: 1.2,
                  color: _accent,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Buat akun baru.',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 34,
                  height: 1.2,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Daftar untuk mulai memesan meja atau mengelola restoran.',
                style: TextStyle(fontSize: 14, height: 1.5, color: _muted),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _namaCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _emailFocus.requestFocus(),
                cursorColor: _accent,
                style: const TextStyle(color: _ink),
                decoration: _fieldDecoration('Nama lengkap'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                focusNode: _emailFocus,
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
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _confirmFocus.requestFocus(),
                cursorColor: _accent,
                style: const TextStyle(color: _ink),
                decoration: _fieldDecoration(
                  'Password',
                  suffix: _eye(_hidePassword,
                      () => setState(() => _hidePassword = !_hidePassword)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmCtrl,
                focusNode: _confirmFocus,
                obscureText: _hideConfirm,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                cursorColor: _accent,
                style: const TextStyle(color: _ink),
                decoration: _fieldDecoration(
                  'Ulangi password',
                  suffix: _eye(_hideConfirm,
                      () => setState(() => _hideConfirm = !_hideConfirm)),
                ),
              ),
              const SizedBox(height: 20),

              // Role selection
              const Text(
                'Daftar Sebagai:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _role = 'pelanggan'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _role == 'pelanggan'
                              ? _accent.withValues(alpha: 0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _role == 'pelanggan' ? _accent : _line,
                            width: _role == 'pelanggan' ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 18,
                              color: _role == 'pelanggan' ? _accent : _muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Pelanggan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _role == 'pelanggan'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _role == 'pelanggan' ? _accent : _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _role = 'admin'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _role == 'admin'
                              ? _accent.withValues(alpha: 0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _role == 'admin' ? _accent : _line,
                            width: _role == 'admin' ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 18,
                              color: _role == 'admin' ? _accent : _muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Admin Resto',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _role == 'admin'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _role == 'admin' ? _accent : _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    disabledBackgroundColor: _accent.withValues(alpha: 0.6),
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
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Masuk',
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
            ],
          ),
        ),
      ),
    );
  }
}
