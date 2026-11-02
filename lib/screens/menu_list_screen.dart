import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/cart_store.dart';
import '../data/menu_data.dart';
import '../theme/app_colors.dart';
import '../widgets/cart_crud_modal.dart';
import '../widgets/menu_item_tile.dart';
import '../widgets/primary_button.dart';

/// Padanan MenuListFragment pelanggan dengan data statis Makanan & Minuman.
/// Dilengkapi fitur Tambah (+) & Kurang (-) pemesanan, serta Modal Keranjang CRUD.
class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _bukaModalKeranjang() async {
    final confirmed = await CartCrudModal.show(context);
    if (confirmed == true && mounted) {
      Navigator.pop(context, CartStore.instance.toSummaryString());
    }
  }

  void _selesaiDanGunakan() {
    Navigator.pop(context, CartStore.instance.toSummaryString());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartStore.instance,
      builder: (context, _) {
        final cart = CartStore.instance;

        return Scaffold(
          backgroundColor: AppColors.pageBg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            shadowColor: Colors.black12,
            title: const Text(
              'Pilihan Menu Reservasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            actions: [
              // Icon Keranjang dengan badge counter (Membuka Modal CRUD)
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: AppColors.textDark),
                    tooltip: 'Lihat Keranjang',
                    onPressed: _bukaModalKeranjang,
                  ),
                  if (cart.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.cancel,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.totalCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.button,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.button,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: 'Makanan (${foodMenu.length})'),
                Tab(text: 'Minuman (${drinksMenu.length})'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab Makanan Statis
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: foodMenu.length,
                itemBuilder: (_, i) {
                  final item = foodMenu[i];
                  final qty = cart.getQuantity(item.name);

                  return MenuItemTile(
                    item: item,
                    quantity: qty,
                    onAdd: () => cart.addItem(item),
                    onRemove: () => cart.decreaseItem(item),
                  );
                },
              ),

              // Tab Minuman Statis
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: drinksMenu.length,
                itemBuilder: (_, i) {
                  final item = drinksMenu[i];
                  final qty = cart.getQuantity(item.name);

                  return MenuItemTile(
                    item: item,
                    quantity: qty,
                    onAdd: () => cart.addItem(item),
                    onRemove: () => cart.decreaseItem(item),
                  );
                },
              ),
            ],
          ),

          // Bottom Bar Keranjang Pesanan (Sticky di bawah)
          bottomSheet: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _bukaModalKeranjang,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${cart.totalCount} Menu Dipilih',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_up,
                                size: 18,
                                color: AppColors.button,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cart.isEmpty
                                ? 'Pilih menu makanan/minuman'
                                : _currency.format(cart.totalPrice),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: cart.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: cart.isEmpty
                                  ? AppColors.textMuted
                                  : AppColors.button,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PrimaryButton(
                    label: 'Gunakan Pesanan',
                    width: 160,
                    height: 45,
                    onPressed: _selesaiDanGunakan,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
