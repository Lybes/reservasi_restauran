import 'package:flutter/foundation.dart';

import '../models/reservasi_data.dart';

/// Padanan TempReservasiData (object singleton di Kotlin).
/// Data hanya disimpan di memori, hilang saat aplikasi ditutup.
/// Pakai ChangeNotifier supaya halaman Riwayat otomatis ter-update.
class ReservasiStore extends ChangeNotifier {
  ReservasiStore._();
  static final ReservasiStore instance = ReservasiStore._();

  final List<ReservasiData> _riwayat = [];

  List<ReservasiData> get riwayat => List.unmodifiable(_riwayat);

  void add(ReservasiData data) {
    _riwayat.add(data);
    notifyListeners();
  }
}
