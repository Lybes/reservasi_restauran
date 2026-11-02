import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/ui.dart';
import '../../widgets/primary_button.dart';

/// Padanan daftar ruangan pelanggan yang disesuaikan untuk Admin.
/// Menggunakan model UI RoomCard yang identik dengan Beranda pelanggan.
class AdminRuanganScreen extends StatefulWidget {
  const AdminRuanganScreen({super.key});

  @override
  State<AdminRuanganScreen> createState() => _AdminRuanganScreenState();
}

class _AdminRuanganScreenState extends State<AdminRuanganScreen> {
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  bool _loading = true;
  List<Map<String, dynamic>> _rooms = [];

  static const _roomImages = [
    'indoor.png',
    'outdoor.png',
    'vvip.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _loading = true);
    final data = await ApiService.fetchRooms();
    if (!mounted) return;
    setState(() {
      _rooms = data;
      _loading = false;
    });
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? room}) async {
    final isEditing = room != null;
    final nameCtrl = TextEditingController(text: room?['nama_ruangan']?.toString() ?? '');
    final capCtrl = TextEditingController(text: room?['kapasitas']?.toString() ?? '10');
    final priceCtrl = TextEditingController(text: room?['harga_per_jam']?.toString() ?? '50000');
    final descCtrl = TextEditingController(text: room?['deskripsi']?.toString() ?? '');
    String selectedImage = room?['gambar']?.toString() ?? 'indoor.png';
    if (!_roomImages.contains(selectedImage)) {
      selectedImage = 'indoor.png';
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              isEditing ? 'Edit Ruangan Restoran' : 'Tambah Ruangan Restoran',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nama Ruangan*', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Contoh: VIP Rooftop',
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Kapasitas*', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: capCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.textDark),
                              decoration: InputDecoration(
                                hintText: 'Orang',
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
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Harga/Jam (Rp)*', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.textDark),
                              decoration: InputDecoration(
                                hintText: '50000',
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
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Foto Ruangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: selectedImage,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.fieldBg,
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _roomImages.map((img) {
                      return DropdownMenuItem(
                        value: img,
                        child: Text(img.replaceAll('.png', '').toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedImage = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Deskripsi Ruangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Suasana, fasilitas, dan deskripsi ruangan...',
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final cap = int.tryParse(capCtrl.text.trim()) ?? 10;
                  final price = int.tryParse(priceCtrl.text.trim()) ?? 50000;
                  final desc = descCtrl.text.trim();

                  if (name.isEmpty) {
                    showMessage(dialogCtx, 'Nama ruangan wajib diisi');
                    return;
                  }

                  Navigator.pop(ctx, {
                    'name': name,
                    'cap': cap,
                    'price': price,
                    'desc': desc,
                    'image': selectedImage,
                  });
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.button,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(isEditing ? 'Simpan' : 'Tambah'),
              ),
            ],
          );
        },
      ),
    );

    if (result == null || !mounted) return;

    final name = result['name'] as String;
    final cap = result['cap'] as int;
    final price = result['price'] as int;
    final desc = result['desc'] as String;
    final img = result['image'] as String?;

    bool ok = false;
    if (isEditing) {
      ok = await ApiService.updateRoom(
        id: room['id'] as int,
        nama: name,
        kapasitas: cap,
        hargaPerJam: price,
        deskripsi: desc,
        gambar: img,
      );
    } else {
      ok = await ApiService.addRoom(
        nama: name,
        kapasitas: cap,
        hargaPerJam: price,
        deskripsi: desc,
        gambar: img,
      );
    }

    if (!mounted) return;
    if (ok) {
      showMessage(context, isEditing ? 'Ruangan berhasil diperbarui' : 'Ruangan berhasil ditambahkan');
      _loadRooms();
    } else {
      showMessage(context, 'Gagal menyimpan data ruangan');
    }
  }

  Future<void> _deleteRoom(Map<String, dynamic> room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Hapus Ruangan'),
        content: Text('Yakin ingin menghapus ruangan "${room['nama_ruangan']}"?'),
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
      final ok = await ApiService.deleteRoom(room['id'] as int);
      if (!mounted) return;
      if (ok) {
        showMessage(context, 'Ruangan berhasil dihapus');
        _loadRooms();
      } else {
        showMessage(context, 'Gagal menghapus ruangan');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header model BerandaScreen pelanggan
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.pageBg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelola Ruangan & Meja',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Kapasitas & tarif sewa meja reservasi',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  PrimaryButton(
                    label: '+ Ruangan',
                    height: 38,
                    onPressed: () => _showAddEditDialog(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.divider),

            // List Ruangan (Model RoomCard Pelanggan)
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _rooms.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada data ruangan',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _loadRooms,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _rooms.length,
                            itemBuilder: (context, index) {
                              final r = _rooms[index];
                              return _buildRoomCardModel(r);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// Model kartu yang identik dengan RoomCard di widgets/room_card.dart pelanggan
  Widget _buildRoomCardModel(Map<String, dynamic> r) {
    final nama = (r['nama_ruangan'] ?? 'Ruangan').toString();
    final cap = r['kapasitas'] ?? 10;
    final harga = int.tryParse(r['harga_per_jam']?.toString() ?? '0') ?? 0;
    final desc = r['deskripsi']?.toString() ?? '';
    final gambar = r['gambar']?.toString() ?? 'indoor.png';

    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Foto ruangan (sama persis dengan RoomCard)
            Image.asset(
              'assets/images/$gambar',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              cacheWidth: 900,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: AppColors.fieldBg,
                child: const Center(
                  child: Icon(Icons.meeting_room, size: 50, color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nama Ruangan (sama persis dengan RoomCard)
            Text(
              nama,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),

            // Kapasitas & Harga
            Text(
              'Kapasitas: $cap orang • ${_currency.format(harga)} / jam',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.button,
              ),
            ),
            const SizedBox(height: 6),

            // Deskripsi (sama persis dengan RoomCard)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Aksi Admin
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Edit Ruangan',
                    onPressed: () => _showAddEditDialog(room: r),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _deleteRoom(r),
                  style: TextButton.styleFrom(foregroundColor: AppColors.cancel),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
