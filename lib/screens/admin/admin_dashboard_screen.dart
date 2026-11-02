import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/room.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/ui.dart';
import '../../widgets/primary_button.dart';

/// Padanan BerandaScreen pelanggan yang disesuaikan untuk Admin.
/// Menggunakan model UI, tata letak, dan komponen yang sama persis dengan Beranda pelanggan.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    required this.onGoToReservasi,
    required this.onGoToMenu,
    required this.onGoToRuangan,
  });

  final VoidCallback onGoToReservasi;
  final VoidCallback onGoToMenu;
  final VoidCallback onGoToRuangan;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  bool _loading = true;
  String _adminName = 'Admin';
  Map<String, dynamic> _stats = {
    'total_reservations': 0,
    'pending_reservations': 0,
    'confirmed_reservations': 0,
    'completed_reservations': 0,
    'total_rooms': 3,
    'total_menu': 20,
    'total_revenue': 0,
  };
  List<Map<String, dynamic>> _recentPending = [];

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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final name = await ApiService.currentUserNama();
    final stats = await ApiService.fetchAdminStats();
    final pendingRes = await ApiService.fetchReservations(status: 'Menunggu Konfirmasi');

    if (!mounted) return;
    setState(() {
      if (name != null && name.isNotEmpty) _adminName = name;
      if (stats != null) _stats = stats;
      _recentPending = pendingRes.take(3).toList();
      _loading = false;
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    final success = await ApiService.updateReservationStatus(id, status);
    if (!mounted) return;
    if (success) {
      showMessage(context, 'Status reservasi berhasil diubah: $status');
      _loadData();
    } else {
      showMessage(context, 'Gagal memperbarui status');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final totalRev = int.tryParse(_stats['total_revenue']?.toString() ?? '0') ?? 0;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salam pembuka (sama persis dengan model BerandaScreen pelanggan)
            Text(
              'Hai, $_adminName (Admin) 👋',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),

            // Banner Restoran (sama dengan BerandaScreen pelanggan)
            Image.asset(
              'assets/images/restaurant.png',
              height: 190,
              width: double.infinity,
              fit: BoxFit.cover,
              cacheWidth: 1000,
            ),
            const SizedBox(height: 16),

            const Text(
              'Panel Pengelolaan Reservasi Restoran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pantau reservasi masuk, kelola daftar menu makanan & minuman, serta status meja restoran secara real-time.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),

            const SizedBox(height: 20),

            // Ringkasan Statistik Reservasi (Model Card Pelanggan)
            const Text(
              'Ringkasan Aktivitas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Reservasi',
                    count: '${_stats['total_reservations'] ?? 0}',
                    icon: Icons.calendar_month,
                    color: AppColors.button,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Perlu Konfirmasi',
                    count: '${_stats['pending_reservations'] ?? 0}',
                    icon: Icons.hourglass_top,
                    color: AppColors.pending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Dikonfirmasi',
                    count: '${_stats['confirmed_reservations'] ?? 0}',
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Estimasi Masuk',
                    count: _currency.format(totalRev),
                    icon: Icons.monetization_on_outlined,
                    color: AppColors.textDark,
                    isSmallText: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Bagian Reservasi Menunggu Konfirmasi (Model _RiwayatCard Pelanggan)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Perlu Ditindaklanjuti',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: widget.onGoToReservasi,
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(color: AppColors.button, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_recentPending.isEmpty)
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 36),
                        SizedBox(height: 8),
                        Text(
                          'Semua reservasi telah diproses!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tidak ada reservasi menunggu konfirmasi saat ini.',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              for (final resv in _recentPending)
                _AdminPendingCard(
                  data: resv,
                  onApprove: () => _updateStatus(resv['id'] as int, 'Berhasil'),
                  onReject: () => _updateStatus(resv['id'] as int, 'Dibatalkan'),
                ),

            const SizedBox(height: 24),

            // Ruangan yang Tersedia (Model RoomCard Pelanggan)
            const Text(
              'Ruangan & Meja Restoran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (final room in _rooms)
              Card(
                elevation: 2,
                color: Colors.white,
                margin: const EdgeInsets.only(top: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Image.asset(
                        room.imagePath,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        cacheWidth: 900,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          room.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                        ),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: 'Kelola Ruangan',
                        onPressed: widget.onGoToRuangan,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.isSmallText = false,
  });

  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final bool isSmallText;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: isSmallText ? 16 : 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menggunakan model _RiwayatCard yang sama dengan pelanggan
class _AdminPendingCard extends StatelessWidget {
  const _AdminPendingCard({
    required this.data,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, dynamic> data;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final room = (data['nama_ruangan'] ?? 'Indoor').toString();
    final name = (data['customer_name'] ?? data['user_nama'] ?? 'Pelanggan').toString();
    String tanggal = (data['tanggal'] ?? '').toString();
    if (tanggal.contains('T')) tanggal = tanggal.split('T')[0];
    final jamMulai = (data['jam_mulai'] ?? '12:00').toString().substring(0, 5);
    final orang = '${data['jumlah_orang'] ?? 2} orang';
    final status = (data['status'] ?? 'Menunggu Konfirmasi').toString();

    return Card(
      elevation: 4,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.person, text: name),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.calendar_today, text: '$tanggal • $jamMulai'),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.groups, text: orang),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  status,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.pending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cancel,
                      side: const BorderSide(color: AppColors.cancel),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Terima'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
