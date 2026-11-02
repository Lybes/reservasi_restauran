import 'package:flutter/material.dart';

import '../data/reservasi_store.dart';
import '../models/reservasi_data.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

/// Padanan RiwayatFragment + RiwayatAdapter + item_riwayat.xml.
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  bool _loading = true;
  List<ReservasiData> _dbRiwayat = [];

  @override
  void initState() {
    super.initState();
    _fetchDbRiwayat();
  }

  Future<void> _fetchDbRiwayat() async {
    setState(() => _loading = true);
    final userId = await ApiService.currentUserId();
    final raw = await ApiService.fetchReservations(userId: userId);
    final parsed = raw.map((j) => ReservasiData.fromJson(j)).toList();

    if (!mounted) return;
    setState(() {
      _dbRiwayat = parsed;
      _loading = false;
    });
  }

  List<ReservasiData> _mergedList(List<ReservasiData> localStore) {
    final list = List<ReservasiData>.from(_dbRiwayat);
    for (final loc in localStore) {
      final exists = list.any((r) =>
          r.namaLengkap == loc.namaLengkap &&
          r.tanggalKedatangan == loc.tanggalKedatangan &&
          r.waktu == loc.waktu);
      if (!exists) {
        list.insert(0, loc);
      }
    }
    return list;
  }

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
              final allRiwayat = _mergedList(ReservasiStore.instance.riwayat);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Aktivitas',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.primary),
                        onPressed: _fetchDbRiwayat,
                        tooltip: 'Segarkan',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (allRiwayat.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Belum ada riwayat reservasi yang tercatat.',
                        style: TextStyle(fontSize: 16, color: Color(0xFF888888)),
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchDbRiwayat,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: allRiwayat.length,
                          itemBuilder: (_, i) => _RiwayatCard(data: allRiwayat[i]),
                        ),
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

  Color get _statusColor {
    if (data.status.contains('Berhasil') || data.status.contains('dikonfirmasi')) {
      return AppColors.success;
    } else if (data.status.contains('Batal')) {
      return AppColors.cancel;
    } else if (data.status.contains('Selesai')) {
      return const Color(0xFF3F51B5);
    }
    return AppColors.pending;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFEADBCE), width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.ruangan,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
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
            if (data.catatan != null && data.catatan!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _InfoRow(icon: Icons.notes, text: data.catatan!),
            ],
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
        Icon(icon, size: 16, color: const Color(0xFF8C8178)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          ),
        ),
      ],
    );
  }
}
