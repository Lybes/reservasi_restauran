import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../theme/app_colors.dart';

/// Padanan item_menu.xml / item_drinks.xml + MenuAdapter / DrinksAdapter.
/// Mendukung fitur tambah (+) dan kurang (-) pemesanan.
class MenuItemTile extends StatelessWidget {
  const MenuItemTile({
    super.key,
    required this.item,
    this.quantity = 0,
    this.onAdd,
    this.onRemove,
  });

  final MenuItem item;
  final int quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: quantity > 0
            ? Border.all(color: AppColors.button, width: 1.2)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              item.imagePath,
              width: 110,
              height: 85,
              fit: BoxFit.cover,
              cacheWidth: 360,
              errorBuilder: (_, __, ___) => Container(
                width: 110,
                height: 85,
                color: AppColors.fieldBg,
                child: const Icon(Icons.fastfood, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.price,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),

                // Fitur Tambah & Kurang Pemesanan
                if (onAdd != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: quantity == 0
                        ? InkWell(
                            onTap: onAdd,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.button,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, size: 16, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tambah',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: AppColors.fieldBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: onRemove,
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
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
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: onAdd,
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
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
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
