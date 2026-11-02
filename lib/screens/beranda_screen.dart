import 'package:flutter/material.dart';

import '../models/room.dart';
import '../services/api_service.dart';
import '../widgets/room_card.dart';
import 'login_screen.dart';

/// Padanan BerandaFragment + fragment_beranda.xml.
class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key, required this.onPesan});

  /// Dipanggil saat tombol "Pesan Sekarang" ditekan (pindah ke tab Reservasi).
  final VoidCallback onPesan;

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String _userName = 'Pelanggan';

  static const _rooms = <Room>[
    Room(
      name: 'Indoor',
      description:
          'Ruangan indoor utama dengan suasana hangat dan pencahayaan lembut. Cocok untuk makan bersama keluarga atau teman.',
      imagePath: 'assets/images/indoor.png',
    ),
    Room(
      name: 'Outdoor',
      description:
          'Area makan terbuka dengan pemandangan luar dan udara segar. Cocok untuk suasana santai atau romantis.',
      imagePath: 'assets/images/outdoor.png',
    ),
    Room(
      name: 'VVIP',
      description:
          'Ruangan eksklusif dengan pencahayaan mewah dan interior premium. Ideal untuk acara khusus atau tamu VIP.',
      imagePath: 'assets/images/vvip.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final nama = await ApiService.currentUserNama();
    if (nama != null && nama.isNotEmpty && mounted) {
      setState(() => _userName = nama);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun?'),
        content: const Text('Anda akan keluar dari akun reservasi Tabebuya.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF9A4A32)),
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logoresto.png', width: 36, height: 36),
                    const SizedBox(width: 8),
                    const Text(
                      'tabebuya',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9A4A32),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFF2B2420)),
                  tooltip: 'Keluar',
                  onPressed: _logout,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Hai, $_userName 👋',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B2420)),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/restaurant.png',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: 1000,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selamat Datang di Aplikasi Reservasi Restoran!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Nikmati pengalaman makan yang lebih nyaman tanpa perlu menunggu antrean panjang.\n'
              'Mulai reservasi sekarang dan pilih meja yang sesuai kebutuhanmu.',
              style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ruangan yang Tersedia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (final room in _rooms) RoomCard(room: room, onBook: widget.onPesan),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
