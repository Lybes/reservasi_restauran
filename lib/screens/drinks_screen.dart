import 'package:flutter/material.dart';

import '../data/cart_store.dart';
import '../data/menu_data.dart';
import '../theme/app_colors.dart';
import '../widgets/cart_crud_modal.dart';
import '../widgets/menu_item_tile.dart';
import '../widgets/primary_button.dart';

/// Padanan DrinksFragment (daftar menu minuman statis).
class DrinksScreen extends StatelessWidget {
  const DrinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartStore.instance,
      builder: (context, _) {
        final cart = CartStore.instance;

        return Scaffold(
          backgroundColor: AppColors.pageBg,
          appBar: AppBar(
            backgroundColor: AppColors.pageBg,
            title: const Text(
              'Menu Minuman',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => CartCrudModal.show(context),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: drinksMenu.length,
                  itemBuilder: (_, i) {
                    final item = drinksMenu[i];
                    return MenuItemTile(
                      item: item,
                      quantity: cart.getQuantity(item.name),
                      onAdd: () => cart.addItem(item),
                      onRemove: () => cart.decreaseItem(item),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: PrimaryButton(
                  label: 'Selesai & Gunakan',
                  width: 200,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
