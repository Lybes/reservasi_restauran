import 'package:flutter/material.dart';

import '../models/room.dart';
import '../theme/app_colors.dart';
import 'primary_button.dart';

/// Kartu ruangan di Beranda (Indoor / Outdoor / VVIP).
class RoomCard extends StatelessWidget {
  const RoomCard({super.key, required this.room, required this.onBook});

  final Room room;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Image.asset(
              room.imagePath,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              cacheWidth: 900,
            ),
            const SizedBox(height: 12),
            Text(
              room.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                room.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              ),
            ),
            const SizedBox(height: 10),
            PrimaryButton(label: 'Pesan Sekarang', onPressed: onBook),
          ],
        ),
      ),
    );
  }
}
