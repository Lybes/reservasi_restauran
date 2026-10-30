import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../theme/app_colors.dart';
import '../widgets/menu_item_tile.dart';
import '../widgets/primary_button.dart';
import 'drinks_screen.dart';

/// Padanan MenuListFragment (daftar menu makanan).
class MenuListScreen extends StatelessWidget {
  const MenuListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.pageBg,
        title: const Text(
          'Menu Makanan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: foodMenu.length,
              itemBuilder: (_, i) => MenuItemTile(item: foodMenu[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              label: 'Drinks',
              width: 178,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DrinksScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
