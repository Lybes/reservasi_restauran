import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/ui.dart';
import '../../widgets/primary_button.dart';

/// Padanan MenuListScreen & DrinksScreen pelanggan yang disesuaikan untuk Admin.
/// Menggunakan model UI, tata letak MenuItemTile, dan pewarnaan yang sama persis dengan pelanggan.
class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  bool _loading = true;
  List<Map<String, dynamic>> _menuList = [];

  static const _availableImages = [
    'chikenskin.jpg',
    'gorengan.jpg',
    'french.jpg',
    'calamary.jpg',
    'onion.jpg',
    'kentangkeju.jpg',
    'icegoreng.jpg',
    'cireng.jpg',
    'zaitunkayatoast.jpg',
    'zaitunfritte.jpg',
    'esteh.jpg',
    'tehtarik.jpg',
    'susutape.jpg',
    'blend.jpg',
    'kopikalcer.jpg',
    'kopibutter.jpg',
    'juzmangga.jpg',
    'juzapel.jpg',
    'juzjambu.jpg',
    'juztimun.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _loading = true);
    final data = await ApiService.fetchMenu(
      kategori: _selectedCategory == 'Semua' ? null : _selectedCategory.toLowerCase(),
    );
    if (!mounted) return;
    setState(() {
      _menuList = data;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredMenu {
    if (_searchQuery.isEmpty) return _menuList;
    return _menuList
        .where((m) =>
            (m['nama'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? item}) async {
    final isEditing = item != null;
    final nameCtrl = TextEditingController(text: item?['nama']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: item?['harga']?.toString() ?? '');
    String category = (item?['kategori'] ?? 'makanan').toString();
    String? selectedImage = item?['gambar']?.toString();
    if (selectedImage == null || !_availableImages.contains(selectedImage)) {
      selectedImage = category == 'makanan' ? 'chikenskin.jpg' : 'esteh.jpg';
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              isEditing ? 'Edit Menu Restoran' : 'Tambah Menu Restoran',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nama Menu*', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Nama makanan/minuman',
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
                  const Text('Harga (Rp)*', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Contoh: 15000',
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
                  const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: category,
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
                    items: const [
                      DropdownMenuItem(value: 'makanan', child: Text('Makanan')),
                      DropdownMenuItem(value: 'minuman', child: Text('Minuman')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          category = val;
                          if (val == 'makanan' && !selectedImage!.contains('jpg')) {
                            selectedImage = 'chikenskin.jpg';
                          } else if (val == 'minuman' && selectedImage == 'chikenskin.jpg') {
                            selectedImage = 'esteh.jpg';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Pilih Foto Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                    items: _availableImages.map((img) {
                      return DropdownMenuItem(
                        value: img,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                'assets/images/$img',
                                width: 26,
                                height: 26,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              img.replaceAll('.jpg', '').replaceAll('.png', ''),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setDialogState(() => selectedImage = val),
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
                  final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
                  if (name.isEmpty || price <= 0) {
                    showMessage(dialogCtx, 'Nama dan harga harus diisi dengan benar');
                    return;
                  }

                  Navigator.pop(ctx, {
                    'name': name,
                    'price': price,
                    'category': category,
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
    final price = result['price'] as int;
    final cat = result['category'] as String;
    final img = result['image'] as String?;

    bool ok = false;
    if (isEditing) {
      final id = item['id'] as int;
      ok = await ApiService.updateMenu(
        id: id,
        nama: name,
        kategori: cat,
        harga: price,
        gambar: img,
      );
    } else {
      ok = await ApiService.addMenu(
        nama: name,
        kategori: cat,
        harga: price,
        gambar: img,
      );
    }

    if (!mounted) return;
    if (ok) {
      showMessage(context, isEditing ? 'Menu berhasil diperbarui' : 'Menu berhasil ditambahkan');
      _loadMenu();
    } else {
      showMessage(context, 'Gagal menyimpan data menu');
    }
  }

  Future<void> _deleteMenu(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Hapus Menu'),
        content: Text('Yakin ingin menghapus menu "${item['nama']}"?'),
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
      final ok = await ApiService.deleteMenu(item['id'] as int);
      if (!mounted) return;
      if (ok) {
        showMessage(context, 'Menu berhasil dihapus');
        _loadMenu();
      } else {
        showMessage(context, 'Gagal menghapus menu');
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
            // Header model MenuListScreen pelanggan
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.pageBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daftar Menu Restoran',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      PrimaryButton(
                        label: '+ Tambah Menu',
                        height: 38,
                        onPressed: () => _showAddEditDialog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search
                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Cari makanan atau minuman...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Kategori selector
                  Row(
                    children: ['Semua', 'Makanan', 'Minuman'].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : AppColors.textDark,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.button,
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                          onSelected: (_) {
                            setState(() => _selectedCategory = cat);
                            _loadMenu();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.divider),

            // List model MenuItemTile pelanggan
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _filteredMenu.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada menu yang sesuai',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _loadMenu,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredMenu.length,
                            itemBuilder: (context, index) {
                              final item = _filteredMenu[index];
                              return _buildMenuItemTileModel(item);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// Model tile identik dengan MenuItemTile di menu_item_tile.dart pelanggan
  Widget _buildMenuItemTileModel(Map<String, dynamic> item) {
    final nama = item['nama']?.toString() ?? '-';
    final harga = int.tryParse(item['harga']?.toString() ?? '0') ?? 0;
    final gambar = item['gambar']?.toString() ?? 'chikenskin.jpg';
    final kategori = (item['kategori']?.toString() ?? 'makanan').toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar menu (120 x 90, persis MenuItemTile pelanggan)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/$gambar',
              width: 120,
              height: 90,
              fit: BoxFit.cover,
              cacheWidth: 360,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 90,
                color: AppColors.fieldBg,
                child: const Icon(Icons.fastfood, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Detail menu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currency.format(harga),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kategori,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.button,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => _showAddEditDialog(item: item),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.button,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => _deleteMenu(item),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cancel,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
