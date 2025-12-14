import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final String title, value, unit;
  final IconData icon;
  final Color color; // Warna ikon saat normal
  final bool isDanger; // Pemicu warna merah

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA WARNA (AGAR SAMA PERSIS ANTARA GAS & SUHU) ---
    // Jika BAHAYA: Background Merah, Teks Putih, Icon Putih
    // Jika AMAN: Background Putih, Teks Hitam, Icon Berwarna

    final backgroundColor = isDanger
        ? const Color(0xFFE53935)
        : Colors.white; // Merah Tegas
    final mainTextColor = isDanger ? Colors.white : Colors.grey[800];
    final subTextColor = isDanger ? Colors.white70 : Colors.grey[600];
    final iconColor = isDanger ? Colors.white : color;
    final bgIconColor = isDanger
        ? Colors.white.withOpacity(0.2)
        : color.withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        // Border merah tua jika bahaya agar makin menyala
        border: isDanger
            ? Border.all(
                color: const Color.fromARGB(216, 183, 28, 28),
                width: 2,
              )
            : null,
      ),
      child: Stack(
        children: [
          // 1. Dekorasi Icon Besar di Belakang (Bayangan)
          Positioned(
            right: -10,
            bottom: -10,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(icon, size: 80, color: bgIconColor),
            ),
          ),

          // 2. Konten Utama
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Kecil di Pojok Kiri Atas
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDanger
                        ? Colors.white.withOpacity(0.2)
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),

                const Spacer(),

                // Judul Sensor (Temperatur)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: mainTextColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        unit,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: subTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
