import 'package:flutter/material.dart';

import '../utils/ui.dart';
import '../widgets/primary_button.dart';
import 'main_screen.dart';

/// Padanan AuthActivity + LoginFragment.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage(context, 'Email dan Password harus diisi.');
      return;
    }

    // TODO: Lakukan proses autentikasi ke backend/API di sini!
    if (email == 'a@gmail.com' && password == '1') {
      showMessage(context, 'Login Berhasil! Selamat datang.');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      showMessage(context, 'Email atau Password salah.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Center(
                child: Text('tabebuya', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 68),
              const Text('silahkan login akun kamu'),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
              ),
              const SizedBox(height: 48),
              Center(
                child: PrimaryButton(
                  label: 'Masuk',
                  width: 120,
                  height: 45,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
