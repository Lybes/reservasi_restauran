import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_menu_screen.dart';
import 'admin_reservasi_screen.dart';
import 'admin_ruangan_screen.dart';

/// Padanan MainScreen pelanggan untuk role Admin.
/// Menggunakan model UI, navigasi, dan styling yang sama dengan MainScreen pelanggan.
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _index = 0;

  void goToTab(int index) => setState(() => _index = index);

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Keluar dari Akun Admin?',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        content: const Text(
          'Anda akan keluar dari sesi administrator.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.cancel),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logoresto.png',
              width: 34,
              height: 34,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.restaurant, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            const Text(
              'tabebuya',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primary),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textDark),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          AdminDashboardScreen(
            onGoToReservasi: () => goToTab(1),
            onGoToMenu: () => goToTab(2),
            onGoToRuangan: () => goToTab(3),
          ),
          const AdminReservasiScreen(),
          const AdminMenuScreen(),
          const AdminRuanganScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _index,
        onDestinationSelected: goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_calendar_outlined),
            selectedIcon: Icon(Icons.edit_calendar),
            label: 'Reservasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_restaurant_outlined),
            selectedIcon: Icon(Icons.table_restaurant),
            label: 'Ruangan',
          ),
        ],
      ),
    );
  }
}
