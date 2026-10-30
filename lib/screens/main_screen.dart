import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'beranda_screen.dart';
import 'reservasi_screen.dart';
import 'riwayat_screen.dart';

/// Padanan MainActivity + BottomNavigationView.
///
/// Tab Reservasi punya Navigator sendiri, supaya halaman Menu / Drinks /
/// Konfirmasi tampil di dalam tab (bottom nav tetap terlihat), sama seperti
/// perilaku fragment container di versi Android.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  /// Dipakai layar lain untuk pindah tab, mis. `MainScreen.of(context).goToTab(2)`.
  static MainScreenState of(BuildContext context) =>
      context.findAncestorStateOfType<MainScreenState>()!;

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  static const tabBeranda = 0;
  static const tabReservasi = 1;
  static const tabRiwayat = 2;

  int _index = tabBeranda;
  final _reservasiNavKey = GlobalKey<NavigatorState>();

  void goToTab(int index) => setState(() => _index = index);

  void _onDestinationSelected(int index) {
    // Tap tab Reservasi saat sudah di tab itu -> kembali ke form awal.
    if (index == _index && index == tabReservasi) {
      _reservasiNavKey.currentState?.popUntil((r) => r.isFirst);
    }
    goToTab(index);
  }

  void _onBack() {
    final nav = _reservasiNavKey.currentState;
    if (_index == tabReservasi && nav != null && nav.canPop()) {
      nav.pop();
    } else if (_index != tabBeranda) {
      goToTab(tabBeranda);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            BerandaScreen(onPesan: () => goToTab(tabReservasi)),
            Navigator(
              key: _reservasiNavKey,
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => const ReservasiScreen(),
              ),
            ),
            const RiwayatScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white,
          selectedIndex: _index,
          onDestinationSelected: _onDestinationSelected,
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
              icon: Icon(Icons.history),
              label: 'Riwayat',
            ),
          ],
        ),
      ),
    );
  }
}
