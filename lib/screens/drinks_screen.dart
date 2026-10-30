import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../theme/app_colors.dart';
import '../widgets/menu_item_tile.dart';
import '../widgets/primary_button.dart';

/// Padanan DrinksFragment (daftar menu minuman).
class DrinksScreen extends StatelessWidget {
  const DrinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.pageBg,
        title: const Text(
          'Menu Minuman',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: drinksMenu.length,
              itemBuilder: (_, i) => MenuItemTile(item: drinksMenu[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              label: 'Kembali',
              width: 178,
              // Di versi Android tombol ini kembali ke form Reservasi.
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ),
        ],
      ),
    );
  }
}
