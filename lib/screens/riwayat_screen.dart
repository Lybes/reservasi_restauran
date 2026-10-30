import 'package:flutter/material.dart';

import '../data/reservasi_store.dart';
import '../models/reservasi_data.dart';
import '../theme/app_colors.dart';

/// Padanan RiwayatFragment + RiwayatAdapter + item_riwayat.xml.
class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListenableBuilder(
            listenable: ReservasiStore.instance,
            builder: (context, _) {
              final riwayat = ReservasiStore.instance.riwayat;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aktivitas',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (riwayat.isEmpty)
                    const Text(
                      'Belum ada riwayat reservasi yang tercatat.',
                      style: TextStyle(fontSize: 18, color: Color(0xFF888888)),
                    ),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: riwayat.length,
                      itemBuilder: (_, i) => _RiwayatCard(data: riwayat[i]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  const _RiwayatCard({required this.data});

  final ReservasiData data;

  Color get _statusColor => switch (data.status) {
        'Berhasil' => AppColors.success,
        'Dibatalkan' => AppColors.cancel,
        _ => AppColors.pending,
      };

  @override
  Widget build(BuildContext context) {
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
              data.ruangan,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.calendar_today,
              text: '${data.tanggalKedatangan} • ${data.waktu}',
            ),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.groups, text: data.jumlahOrang),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.restaurant_menu, text: data.listMenu),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  data.status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
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
