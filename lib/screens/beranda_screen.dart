import 'package:flutter/material.dart';

import '../models/room.dart';
import '../widgets/room_card.dart';

/// Padanan BerandaFragment + fragment_beranda.xml.
class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key, required this.onPesan});

  /// Dipanggil saat tombol "Pesan Sekarang" ditekan (pindah ke tab Reservasi).
  final VoidCallback onPesan;

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
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/logoresto.png', width: 40, height: 40),
            const Text(
              'tabebuya',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Hai, (nama pengguna)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Image.asset(
              'assets/images/restaurant.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              cacheWidth: 1000,
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
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ruangan yang Tersedia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (final room in _rooms) RoomCard(room: room, onBook: onPesan),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
