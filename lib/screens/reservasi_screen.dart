import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/cart_store.dart';
import '../data/reservasi_store.dart';
import '../models/reservasi_data.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../utils/ui.dart';
import '../widgets/cart_crud_modal.dart';
import '../widgets/primary_button.dart';
import 'konfirmasi_screen.dart';
import 'menu_list_screen.dart';

/// Padanan ReservasiFragment + fragment_reservasi.xml.
class ReservasiScreen extends StatefulWidget {
  const ReservasiScreen({super.key});

  @override
  State<ReservasiScreen> createState() => _ReservasiScreenState();
}

class _ReservasiScreenState extends State<ReservasiScreen> {
  static const _opsiJumlahOrang = ['1 orang', '2-4 orang', '5-10 orang', '10+ orang'];
  static const _opsiRuangan = ['VVIP', 'Indoor', 'Outdoor'];

  final _dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  final _tanggalCtrl = TextEditingController();
  final _waktuCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _menuCtrl = TextEditingController();

  late DateTime _selectedDate;
  String? _jumlahOrang;
  String? _ruangan;

  @override
  void initState() {
    super.initState();
    _resetForm(notify: false);
    _prefillName();
  }

  Future<void> _prefillName() async {
    final name = await ApiService.currentUserNama();
    if (name != null && name.isNotEmpty && mounted) {
      setState(() => _namaCtrl.text = name);
    }
  }

  @override
  void dispose() {
    _tanggalCtrl.dispose();
    _waktuCtrl.dispose();
    _namaCtrl.dispose();
    _menuCtrl.dispose();
    super.dispose();
  }

  void _resetForm({bool notify = true}) {
    void apply() {
      _selectedDate = DateTime.now();
      _tanggalCtrl.text = _dateFormat.format(_selectedDate);
      _waktuCtrl.clear();
      _menuCtrl.clear();
      _jumlahOrang = null;
      _ruangan = null;
      CartStore.instance.clear();
    }

    if (notify) {
      setState(apply);
    } else {
      apply();
    }
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalCtrl.text = _dateFormat.format(picked);
      });
    }
  }

  /// Buka halaman pemilihan Menu List statis
  Future<void> _pilihMenu() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const MenuListScreen()),
    );

    // Otomatis isi ke field list menu dari keranjang pesanan
    final summary = result ?? CartStore.instance.toSummaryString();
    if (mounted) {
      setState(() {
        _menuCtrl.text = summary;
      });
    }
  }

  /// Buka Modal Keranjang dengan fungsi CRUD lengkap
  Future<void> _bukaModalKeranjang() async {
    await CartCrudModal.show(context);
    // Setelah modal CRUD selesai, update langsung field list menu
    final summary = CartStore.instance.toSummaryString();
    if (mounted) {
      setState(() {
        _menuCtrl.text = summary;
      });
    }
  }

  void _pesan() {
    final nama = _namaCtrl.text.trim();
    final tanggal = _tanggalCtrl.text.trim();
    final waktu = _waktuCtrl.text.trim();

    if (_jumlahOrang == null || _ruangan == null) {
      showMessage(context, 'Harap pilih jumlah orang dan ruangan!');
      return;
    }
    if (nama.isEmpty || tanggal.isEmpty || waktu.isEmpty) {
      showMessage(context, 'Nama, Tanggal, dan Waktu wajib diisi!');
      return;
    }

    final menu = _menuCtrl.text.trim();
    final cart = CartStore.instance;

    // Hitung total harga dasar ruangan + total menu
    int roomRate = 50000;
    if (_ruangan == 'Outdoor') roomRate = 75000;
    if (_ruangan == 'VVIP') roomRate = 150000;
    final totalEstimasi = roomRate * 2 + cart.totalPrice;

    final resv = ReservasiData(
      namaLengkap: nama,
      tanggalKedatangan: tanggal,
      waktu: waktu,
      listMenu: menu.isEmpty ? 'Tidak Ada' : menu,
      jumlahOrang: _jumlahOrang!,
      ruangan: _ruangan!,
      status: 'Menunggu Konfirmasi',
      totalHarga: totalEstimasi,
      items: cart.items
          .map((i) => {
                'nama': i.item.name,
                'harga': i.priceNumeric,
                'jumlah': i.quantity,
                'subtotal': i.subtotal,
              })
          .toList(),
    );
    ReservasiStore.instance.add(resv);

    // Persist ke database MySQL db_reservasipml
    final dateIso = _selectedDate.toIso8601String().split('T')[0];
    ApiService.createReservation(
      customerName: nama,
      roomName: _ruangan!,
      tanggal: dateIso,
      waktu: waktu,
      jumlahOrang: _jumlahOrang!,
      totalHarga: totalEstimasi,
      catatan: menu.isNotEmpty ? 'Menu: $menu' : '',
    );

    _resetForm();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const KonfirmasiScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reservasi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 12),
                const _Label('Tanggal Reservasi*'),
                _Field(
                  controller: _tanggalCtrl,
                  hint: 'select a date...',
                  readOnly: true,
                  onTap: _pickDate,
                  suffix: const Icon(Icons.calendar_today, size: 20),
                ),
                const SizedBox(height: 14),
                const _Label('Pilih waktu*'),
                _Field(controller: _waktuCtrl, hint: 'Contoh: 18:00 - 20:00'),
                const SizedBox(height: 14),
                const _Label('Nama Lengkap*'),
                _Field(controller: _namaCtrl, hint: 'Nama Lengkap'),
                const SizedBox(height: 14),

                // Field List Menu (Otomatis terisi dari keranjang pesanan)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _Label('List menu *'),
                    ListenableBuilder(
                      listenable: CartStore.instance,
                      builder: (context, _) {
                        if (CartStore.instance.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return InkWell(
                          onTap: _bukaModalKeranjang,
                          child: const Row(
                            children: [
                              Icon(Icons.edit_note, size: 16, color: AppColors.button),
                              SizedBox(width: 4),
                              Text(
                                'Kelola Keranjang (CRUD)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.button,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                _Field(
                  controller: _menuCtrl,
                  hint: 'Klik "Menu List" untuk memilih menu makanan & minuman',
                  readOnly: true,
                  onTap: _pilihMenu,
                  suffix: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                    onPressed: _bukaModalKeranjang,
                  ),
                ),
                const SizedBox(height: 8),

                // Rincian Ringkas Keranjang jika sudah memilih menu
                ListenableBuilder(
                  listenable: CartStore.instance,
                  builder: (context, _) {
                    final cart = CartStore.instance;

                    if (cart.isEmpty) {
                      return PrimaryButton(
                        label: 'Menu List',
                        height: 45,
                        width: double.infinity,
                        onPressed: _pilihMenu,
                      );
                    }

                    return Container(
                      margin: const EdgeInsets.only(top: 4, bottom: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.fieldBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${cart.totalCount} Menu Dipesan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                _currency.format(cart.totalPrice),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.button,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _bukaModalKeranjang,
                                  icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                                  label: const Text('Tampilkan Pesanan'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.button,
                                    side: const BorderSide(color: AppColors.button),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: PrimaryButton(
                                  label: '+ Tambah Menu',
                                  height: 38,
                                  onPressed: _pilihMenu,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),
                const _Label('Untuk Berapa Orang?*'),
                _RadioGroup(
                  options: _opsiJumlahOrang,
                  value: _jumlahOrang,
                  onChanged: (v) => setState(() => _jumlahOrang = v),
                ),
                const SizedBox(height: 18),
                const _Label('Pilih Ruangan'),
                _RadioGroup(
                  options: _opsiRuangan,
                  value: _ruangan,
                  onChanged: (v) => setState(() => _ruangan = v),
                ),
                const SizedBox(height: 26),
                Center(
                  child: PrimaryButton(
                    label: 'Pesan',
                    width: 120,
                    height: 45,
                    onPressed: _pesan,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.fieldBg,
        isDense: true,
        contentPadding: const EdgeInsets.all(12),
        border: InputBorder.none,
      ),
    );
  }
}

/// Pengganti RadioGroup + RadioButton (satu pilihan dari beberapa opsi).
class _RadioGroup extends StatelessWidget {
  const _RadioGroup({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in options)
          InkWell(
            onTap: () => onChanged(option),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    option == value
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: option == value ? AppColors.button : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Text(option, style: const TextStyle(color: AppColors.textDark)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
