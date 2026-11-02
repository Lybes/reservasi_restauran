import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/cart_store.dart';
import '../theme/app_colors.dart';
import 'primary_button.dart';

/// Modal BottomSheet dengan fungsi CRUD lengkap untuk mengelola keranjang pesanan menu:
/// - Create: Menambah menu / jumlah item pesanan
/// - Read: Melihat daftar item pesanan, rincian harga satuan, subtotal, dan total
/// - Update: Mengubah kuantitas item (+ dan -)
/// - Delete: Menghapus item tertentu (ikon hapus) atau mengosongkan seluruh keranjang
class CartCrudModal extends StatelessWidget {
  const CartCrudModal({super.key});

  static final _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  /// Menampilkan modal keranjang
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CartCrudModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      child: ListenableBuilder(
        listenable: CartStore.instance,
        builder: (context, _) {
          final cart = CartStore.instance;
          final items = cart.items;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Garis handle modal atas
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: AppColors.button),
                      const SizedBox(width: 8),
                      const Text(
                        'Keranjang Pesanan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (cart.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.button.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${cart.totalCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.button,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (cart.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        cart.clear();
                      },
                      icon: const Icon(
                        Icons.delete_sweep,
                        size: 18,
                        color: AppColors.cancel,
                      ),
                      label: const Text(
                        'Kosongkan',
                        style: TextStyle(
                          color: AppColors.cancel,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),

              const Divider(height: 16, color: AppColors.divider),

              // Daftar Item Pesanan (Read & CRUD Controls)
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.remove_shopping_cart_outlined,
                          size: 54,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Keranjang masih kosong',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pilih menu makanan atau minuman dari daftar.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final cartItem = items[index];
                      final menuItem = cartItem.item;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            // Foto thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                menuItem.imagePath,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 52,
                                  height: 52,
                                  color: AppColors.fieldBg,
                                  child: const Icon(Icons.fastfood, size: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Nama & Harga Satuan
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menuItem.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    menuItem.price,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Subtotal: ${_currency.format(cartItem.subtotal)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.button,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Update Stepper (+ / -)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.fieldBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => cart.decreaseItem(menuItem),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.divider,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.remove,
                                        size: 16,
                                        color: AppColors.cancel,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      '${cartItem.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => cart.addItem(menuItem),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.button,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Delete button (hapus item tunggal)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.cancel,
                                size: 20,
                              ),
                              onPressed: () =>
                                  cart.removeItem(menuItem.name),
                              tooltip: 'Hapus item',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              const Divider(height: 16, color: AppColors.divider),

              // Total & Aksi Bawah
              if (cart.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pesanan Menu:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      _currency.format(cart.totalPrice),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.button,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '+ Tambah Menu Lain',
                        style: TextStyle(color: AppColors.textDark),
                      ),
                    ),
                  ),
                  if (cart.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Gunakan Pesanan',
                        height: 48,
                        onPressed: () {
                          // Mengembalikan true menandakan pesanan dikonfirmasi
                          Navigator.pop(context, true);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
