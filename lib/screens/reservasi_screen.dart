import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/cart_store.dart';
import '../data/reservasi_store.dart';
import '../models/reservasi_data.dart';
import '../services/api_service.dart';
import '../utils/ui.dart';
import '../widgets/cart_crud_modal.dart';
import 'konfirmasi_screen.dart';
import 'menu_list_screen.dart';

/// Padanan ReservasiFragment + fragment_reservasi.xml.
class ReservasiScreen extends StatefulWidget {
  const ReservasiScreen({super.key});

  @override
  State<ReservasiScreen> createState() => _ReservasiScreenState();
}

class _ReservasiScreenState extends State<ReservasiScreen> {
  static const _accent = Color(0xFF9A4A32);
  static const _ink = Color(0xFF2B2420);
  static const _muted = Color(0xFF8C8178);
  static const _line = Color(0xFFE9E1D8);
  static const _canvas = Color(0xFFF7F1E8);
  static const _field = Color(0xFFFBF9F6);
  static const _selected = Color(0xFFF4E8E3);

  static const _opsiJumlahOrang = [
    '1 orang',
    '2-4 orang',
    '5-10 orang',
    '10+ orang'
  ];
  static const _opsiRuangan = ['VVIP', 'Indoor', 'Outdoor'];

  final _dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
  final _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

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
      backgroundColor: _canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: _accent,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TABEBUYA RESTAURANT',
                          style: TextStyle(
                            color: _accent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.4,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Buat reservasi',
                          style: TextStyle(
                            color: _ink,
                            fontFamily: 'serif',
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih waktu, ruangan, dan menu untuk kunjunganmu.',
                style: TextStyle(color: _muted, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                      icon: Icons.schedule_rounded,
                      title: 'Detail kunjungan',
                      subtitle: 'Tentukan jadwal dan data pemesan.',
                    ),
                    const SizedBox(height: 18),
                    const _Label('Tanggal reservasi'),
                    _Field(
                      controller: _tanggalCtrl,
                      hint: 'Pilih tanggal',
                      readOnly: true,
                      onTap: _pickDate,
                      prefixIcon: Icons.calendar_month_outlined,
                      suffix:
                          const Icon(Icons.expand_more_rounded, color: _muted),
                    ),
                    const SizedBox(height: 14),
                    const _Label('Waktu kedatangan'),
                    _Field(
                      controller: _waktuCtrl,
                      hint: 'Contoh: 18:00 - 20:00',
                      prefixIcon: Icons.access_time_rounded,
                    ),
                    const SizedBox(height: 14),
                    const _Label('Nama pemesan'),
                    _Field(
                      controller: _namaCtrl,
                      hint: 'Nama lengkap',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 22),
                    const Divider(height: 1, color: _line),
                    const SizedBox(height: 20),
                    const _SectionTitle(
                      icon: Icons.groups_2_outlined,
                      title: 'Atur tempat duduk',
                      subtitle: 'Pilih jumlah tamu dan suasana ruangan.',
                    ),
                    const SizedBox(height: 16),
                    const _Label('Jumlah tamu'),
                    _RadioGroup(
                      options: _opsiJumlahOrang,
                      value: _jumlahOrang,
                      onChanged: (v) => setState(() => _jumlahOrang = v),
                    ),
                    const SizedBox(height: 16),
                    const _Label('Ruangan pilihan'),
                    _RadioGroup(
                      options: _opsiRuangan,
                      value: _ruangan,
                      onChanged: (v) => setState(() => _ruangan = v),
                    ),
                    const SizedBox(height: 22),
                    const Divider(height: 1, color: _line),
                    const SizedBox(height: 20),
                    const _SectionTitle(
                      icon: Icons.restaurant_menu_rounded,
                      title: 'Menu pilihan',
                      subtitle: 'Menu bisa ditambahkan sekarang atau nanti.',
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      controller: _menuCtrl,
                      hint: 'Pilih makanan dan minuman',
                      readOnly: true,
                      onTap: _pilihMenu,
                      prefixIcon: Icons.restaurant_outlined,
                      suffix: IconButton(
                        tooltip: 'Buka keranjang',
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: _accent,
                        ),
                        onPressed: _bukaModalKeranjang,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListenableBuilder(
                      listenable: CartStore.instance,
                      builder: (context, _) {
                        final cart = CartStore.instance;

                        if (cart.isEmpty) {
                          return SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _pilihMenu,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Pilih menu'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _accent,
                                side: const BorderSide(color: _line),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _field,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${cart.totalCount} item dipilih',
                                      style: const TextStyle(
                                        color: _ink,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _currency.format(cart.totalPrice),
                                    style: const TextStyle(
                                      color: _accent,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _bukaModalKeranjang,
                                      icon: const Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 18,
                                      ),
                                      label: const Text('Keranjang'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _accent,
                                        side: const BorderSide(color: _line),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 11,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: _pilihMenu,
                                      icon: const Icon(Icons.add_rounded,
                                          size: 18),
                                      label: const Text('Tambah menu'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _accent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 11,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _selected,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: _accent,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Reservasi akan dikonfirmasi oleh pihak restoran setelah pesanan dikirim.',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: _pesan,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text(
                          'Kirim reservasi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _ReservasiScreenState._selected,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _ReservasiScreenState._accent, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ReservasiScreenState._ink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _ReservasiScreenState._muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          color: _ReservasiScreenState._ink,
          fontSize: 13,
          fontWeight: FontWeight.w600,
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
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: _ReservasiScreenState._ink, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _ReservasiScreenState._muted),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: _ReservasiScreenState._muted, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: _ReservasiScreenState._field,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _ReservasiScreenState._line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: _ReservasiScreenState._accent,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

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
    return Wrap(
      spacing: 8,
      runSpacing: 2,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(option),
            selected: option == value,
            onSelected: (_) => onChanged(option),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: option == value
                  ? _ReservasiScreenState._accent
                  : _ReservasiScreenState._ink,
              fontSize: 13,
              fontWeight: option == value ? FontWeight.w600 : FontWeight.normal,
            ),
            backgroundColor: _ReservasiScreenState._field,
            selectedColor: _ReservasiScreenState._selected,
            side: BorderSide(
              color: option == value
                  ? _ReservasiScreenState._accent
                  : _ReservasiScreenState._line,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
      ],
    );
  }
}
