import 'package:flutter/material.dart';
import 'my_drawer.dart'; // <--- Import Drawer Baru

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // --- PANGGIL DRAWER PINTAR DI SINI (Index 1 = Panduan) ---
      drawer: const MyDrawer(activeIndex: 1),

      // ---------------------------------------------------------
      appBar: AppBar(
        title: const Text(
          "Panduan & Informasi Tim",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Icon Menu akan otomatis muncul (Garis Tiga) karena ada drawer di atas
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- BAGIAN 1: PROFIL KELOMPOK (TEAM) ---
          const Text(
            "Tim Pengembang",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.group, size: 30, color: Color(0xFF1E88E5)),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Kelompok IoT Monitoring",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "D3 Teknologi Informasi - Politeknik Negeri Madiun",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(height: 30),

                // --- DAFTAR ANGGOTA (EDIT DATA DI SINI) ---
                _buildMemberItem("Amanda Rizki Yorina", "NIM: 233307032"),
                _buildMemberItem("Daffa Yosataris", "NIM: 233307041"),
                _buildMemberItem("Fadhil Vidiarta", "NIM: 233307047"),
                _buildMemberItem("Haris Cahyana", "NIM: 233307050"),
                _buildMemberItem("Zahy Nadhir", "NIM: 233307060"),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- BAGIAN 2: PANDUAN KESELAMATAN ---
          const Text(
            "Prosedur Keadaan Darurat",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          _buildGuideItem(
            title: "Jika Sensor Gas Berbunyi",
            icon: Icons.warning_amber_rounded,
            color: Colors.red,
            content:
                "1. Tetap tenang dan jangan panik.\n"
                "2. DILARANG menyalakan/mematikan saklar listrik.\n"
                "3. Buka semua pintu dan jendela segera.\n"
                "4. Cabut regulator tabung gas.\n"
                "5. Keluar ruangan menuju tempat terbuka.",
          ),

          _buildGuideItem(
            title: "Jika Suhu Ruangan Ekstrem",
            icon: Icons.thermostat_rounded,
            color: Colors.orange,
            content:
                "1. Periksa sumber panas (kompor/alat elektronik).\n"
                "2. Nyalakan sistem ventilasi manual.\n"
                "3. Jauhkan bahan mudah terbakar dari sumber panas.\n"
                "4. Gunakan APAR jika terlihat api kecil.",
          ),

          const SizedBox(height: 30),

          // --- BAGIAN 3: KONTAK DARURAT ---
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.red),
                    SizedBox(height: 5),
                    Text(
                      "DAMKAR",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "113",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.local_police, color: Colors.blue),
                    SizedBox(height: 5),
                    Text(
                      "POLISI",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "110",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMemberItem(String name, String nim) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(nim, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              content,
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
