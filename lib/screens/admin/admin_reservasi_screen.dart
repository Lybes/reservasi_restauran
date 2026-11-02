import 'package:flutter/material.dart';

import '../../data/reservasi_store.dart';
import '../../models/reservasi_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/ui.dart';

/// Padanan RiwayatScreen pelanggan yang disesuaikan untuk Admin.
/// Menggunakan model UI, kartu, font, dan pewarnaan yang sama dengan Riwayat pelanggan.
class AdminReservasiScreen extends StatefulWidget {
  const AdminReservasiScreen({super.key});

  @override
  State<AdminReservasiScreen> createState() => _AdminReservasiScreenState();
}

class _AdminReservasiScreenState extends State<AdminReservasiScreen> {
  final List<String> _filters = [
    'Semua',
    'Menunggu Konfirmasi',
    'Berhasil',
    'Selesai',
    'Dibatalkan',
  ];
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  bool _loading = true;
  List<ReservasiData> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _loading = true);
    final raw = await ApiService.fetchReservations(
      status: _selectedFilter == 'Semua' ? null : _selectedFilter,
    );

    final List<ReservasiData> list = raw.map((j) => ReservasiData.fromJson(j)).toList();

    // Gabungkan dengan data local di ReservasiStore bila ada
    final localRiwayat = ReservasiStore.instance.riwayat;
    for (final loc in localRiwayat) {
      final exists = list.any((r) =>
          r.namaLengkap == loc.namaLengkap &&
          r.tanggalKedatangan == loc.tanggalKedatangan &&
          r.waktu == loc.waktu);
      if (!exists) {
        if (_selectedFilter == 'Semua' || loc.status == _selectedFilter) {
          list.insert(0, loc);
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _reservations = list;
      _loading = false;
    });
  }

  Future<void> _updateStatus(ReservasiData item, String newStatus) async {
    if (item.id != null) {
      final ok = await ApiService.updateReservationStatus(item.id!, newStatus);
      if (!mounted) return;
      if (ok) {
        showMessage(context, 'Status diubah menjadi: $newStatus');
        _loadReservations();
      } else {
        showMessage(context, 'Gagal memperbarui status ke database');
      }
    } else {
      setState(() {
        _reservations = _reservations.map((r) {
          if (r == item) return r.copyWith(status: newStatus);
          return r;
        }).toList();
      });
      showMessage(context, 'Status diubah menjadi: $newStatus');
    }
  }

  Future<void> _deleteReservation(ReservasiData item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Hapus Reservasi'),
        content: Text('Yakin ingin menghapus reservasi atas nama "${item.namaLengkap}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.cancel),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (item.id != null) {
        final ok = await ApiService.deleteReservation(item.id!);
        if (!mounted) return;
        if (ok) {
          showMessage(context, 'Reservasi berhasil dihapus');
          _loadReservations();
        } else {
          showMessage(context, 'Gagal menghapus reservasi');
        }
      } else {
        setState(() {
          _reservations.remove(item);
        });
        if (!mounted) return;
        showMessage(context, 'Reservasi berhasil dihapus');
      }
    }
  }

  List<ReservasiData> get _filteredReservations {
    return _reservations.where((r) {
      final query = _searchQuery.toLowerCase();
      final matchName = r.namaLengkap.toLowerCase().contains(query);
      final matchRoom = r.ruangan.toLowerCase().contains(query);
      final matchNote = (r.catatan ?? '').toLowerCase().contains(query);
      final matchMenu = r.listMenu.toLowerCase().contains(query);
      return matchName || matchRoom || matchNote || matchMenu;
    }).toList();
  }

  Color _statusColor(String status) {
    if (status.contains('Berhasil') || status.contains('dikonfirmasi')) {
      return AppColors.success;
    } else if (status.contains('Batal')) {
      return AppColors.cancel;
    } else if (status.contains('Selesai')) {
      return AppColors.button;
    }
    return AppColors.pending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header model RiwayatScreen pelanggan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kelola Reservasi',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                    onPressed: _loadReservations,
                    tooltip: 'Segarkan',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Search box model pelanggan
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Cari nama tamu, meja, menu...',
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.fieldBg,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.button,
                        backgroundColor: AppColors.fieldBg,
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() => _selectedFilter = filter);
                          _loadReservations();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),

              // Reservation List (Model _RiwayatCard Pelanggan)
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : _filteredReservations.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada riwayat reservasi yang tercatat.',
                              style: TextStyle(fontSize: 16, color: Color(0xFF888888)),
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: _loadReservations,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _filteredReservations.length,
                              itemBuilder: (context, index) {
                                final resv = _filteredReservations[index];
                                return _buildRiwayatCardModel(resv);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Model kartu yang identik dengan _RiwayatCard di riwayat_screen.dart pelanggan
  Widget _buildRiwayatCardModel(ReservasiData data) {
    final statusColor = _statusColor(data.status);

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
            // Nama Ruangan (sama persis dengan _RiwayatCard)
            Text(
              data.ruangan,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Nama Pelanggan
            _InfoRow(
              icon: Icons.person,
              text: data.namaLengkap,
            ),
            const SizedBox(height: 4),

            // Tanggal & Waktu Kedatangan
            _InfoRow(
              icon: Icons.calendar_today,
              text: '${data.tanggalKedatangan} • ${data.waktu}',
            ),
            const SizedBox(height: 4),

            // Jumlah Orang
            _InfoRow(icon: Icons.groups, text: data.jumlahOrang),
            const SizedBox(height: 4),

            // List Menu
            _InfoRow(icon: Icons.restaurant_menu, text: data.listMenu),
            if (data.catatan != null && data.catatan!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _InfoRow(icon: Icons.notes, text: data.catatan!),
            ],
            const SizedBox(height: 6),

            // Baris Status (sama persis dengan _RiwayatCard)
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
                    color: statusColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 8),

            // Tombol Aksi Admin
            Row(
              children: [
                if (data.status != 'Berhasil')
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilledButton(
                        onPressed: () => _updateStatus(data, 'Berhasil'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('Terima', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                if (data.status != 'Dibatalkan')
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(data, 'Dibatalkan'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.cancel,
                          side: const BorderSide(color: AppColors.cancel),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('Tolak', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                if (data.status == 'Berhasil')
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilledButton(
                        onPressed: () => _updateStatus(data, 'Selesai'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.button,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('Selesai', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.cancel, size: 20),
                  onPressed: () => _deleteReservation(data),
                  tooltip: 'Hapus reservasi',
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
