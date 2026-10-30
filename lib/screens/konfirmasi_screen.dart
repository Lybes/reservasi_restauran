import 'package:flutter/material.dart';

import '../widgets/primary_button.dart';
import 'main_screen.dart';

/// Padanan KonfirmasiFragment + fragment_konfirmasi.xml.
class KonfirmasiScreen extends StatelessWidget {
  const KonfirmasiScreen({super.key});

  void _keTab(BuildContext context, int tab) {
    final main = MainScreen.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    main.goToTab(tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/centangsukses.png',
                  width: 199,
                  height: 211,
                  semanticLabel: 'Ikon Sukses',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reservasi Berhasil Dibuat!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Text(
                    'Terima kasih telah melakukan reservasi. Kami sudah menerima pesanan kamu dan sedang mempersiapkan meja yang kamu pilih.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Kembali',
                        onPressed: () =>
                            _keTab(context, MainScreenState.tabBeranda),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Cek pesanan',
                        onPressed: () =>
                            _keTab(context, MainScreenState.tabRiwayat),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
