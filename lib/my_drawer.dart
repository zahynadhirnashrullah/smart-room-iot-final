import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'guide_screen.dart';

class MyDrawer extends StatelessWidget {
  final int activeIndex; // 0 = Dashboard, 1 = Panduan

  const MyDrawer({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // HEADER MEWAH
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: const Text(
              "Tim Monitoring IoT",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text("Politeknik Negeri Madiun"),
            currentAccountPicture: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups_rounded,
                size: 40,
                color: Color(0xFF1E88E5),
              ),
            ),
          ),

          // MENU ITEMS
          const SizedBox(height: 10),

          _buildMenuItem(
            context,
            index: 0,
            title: "Dashboard Utama",
            icon: Icons.dashboard_rounded,
            targetPage: const DashboardPage(),
          ),

          _buildMenuItem(
            context,
            index: 1,
            title: "Panduan & Anggota",
            icon: Icons.menu_book_rounded,
            targetPage: const GuidePage(),
          ),

          const Spacer(),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.grey),
            title: Text(
              'Versi Aplikasi 1.0',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
    required Widget targetPage,
  }) {
    bool isActive = index == activeIndex; // Cek apakah menu ini sedang aktif

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        // JIKA AKTIF: Warna Biru Muda. JIKA TIDAK: Transparan.
        color: isActive ? const Color(0xFFE3F2FD) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          // JIKA AKTIF: Icon Biru. JIKA TIDAK: Icon Abu.
          color: isActive ? const Color(0xFF1E88E5) : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF1E88E5) : Colors.black87,
          ),
        ),
        onTap: () {
          // Logika Navigasi PINTAR
          if (isActive) {
            Navigator.pop(
              context,
            ); // Jika klik halaman sendiri, tutup drawer aja
          } else {
            Navigator.pop(context); // Tutup drawer dulu
            // Gunakan pushReplacement agar tidak ada tombol BACK, tapi tombol MENU tetap ada
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            );
          }
        },
      ),
    );
  }
}
