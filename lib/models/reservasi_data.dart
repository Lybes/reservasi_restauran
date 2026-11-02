class ReservasiData {
  final int? id;
  final String namaLengkap;
  final String? email;
  final String tanggalKedatangan;
  final String waktu;
  final String listMenu;
  final String jumlahOrang;
  final String ruangan;
  final String status;
  final int totalHarga;
  final String? catatan;
  final List<dynamic> items;

  const ReservasiData({
    this.id,
    required this.namaLengkap,
    this.email,
    required this.tanggalKedatangan,
    required this.waktu,
    required this.listMenu,
    required this.jumlahOrang,
    required this.ruangan,
    required this.status,
    this.totalHarga = 0,
    this.catatan,
    this.items = const [],
  });

  factory ReservasiData.fromJson(Map<String, dynamic> json) {
    // Parse items to string summary if listMenu is empty
    String menuText = '';
    final rawItems = json['items'] as List<dynamic>? ?? [];
    if (rawItems.isNotEmpty) {
      menuText = rawItems
          .map((i) => '${i['nama']} (${i['jumlah']}x)')
          .join(', ');
    } else if (json['catatan'] != null && json['catatan'].toString().isNotEmpty) {
      menuText = json['catatan'].toString();
    } else {
      menuText = 'Tidak ada pesanan menu';
    }

    // Format tanggal
    String tanggalStr = json['tanggal']?.toString() ?? '';
    if (tanggalStr.contains('T')) {
      tanggalStr = tanggalStr.split('T')[0];
    }

    final jamMulai = json['jam_mulai']?.toString().substring(0, 5) ?? '12:00';
    final jamSelesai = json['jam_selesai']?.toString().substring(0, 5) ?? '14:00';

    return ReservasiData(
      id: json['id'] as int?,
      namaLengkap: (json['customer_name'] ?? json['user_nama'] ?? 'Pelanggan').toString(),
      email: json['user_email']?.toString(),
      tanggalKedatangan: tanggalStr,
      waktu: '$jamMulai - $jamSelesai',
      listMenu: menuText,
      jumlahOrang: '${json['jumlah_orang'] ?? 2} orang',
      ruangan: (json['nama_ruangan'] ?? 'Indoor').toString(),
      status: (json['status'] ?? 'Menunggu Konfirmasi').toString(),
      totalHarga: (json['total_harga'] is num)
          ? (json['total_harga'] as num).toInt()
          : int.tryParse(json['total_harga']?.toString() ?? '0') ?? 0,
      catatan: json['catatan']?.toString(),
      items: rawItems,
    );
  }

  ReservasiData copyWith({
    int? id,
    String? namaLengkap,
    String? email,
    String? tanggalKedatangan,
    String? waktu,
    String? listMenu,
    String? jumlahOrang,
    String? ruangan,
    String? status,
    int? totalHarga,
    String? catatan,
    List<dynamic>? items,
  }) {
    return ReservasiData(
      id: id ?? this.id,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      email: email ?? this.email,
      tanggalKedatangan: tanggalKedatangan ?? this.tanggalKedatangan,
      waktu: waktu ?? this.waktu,
      listMenu: listMenu ?? this.listMenu,
      jumlahOrang: jumlahOrang ?? this.jumlahOrang,
      ruangan: ruangan ?? this.ruangan,
      status: status ?? this.status,
      totalHarga: totalHarga ?? this.totalHarga,
      catatan: catatan ?? this.catatan,
      items: items ?? this.items,
    );
  }
}
