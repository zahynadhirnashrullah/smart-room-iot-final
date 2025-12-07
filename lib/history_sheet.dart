import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
// BARIS YANG ERROR TADI SUDAH SAYA HAPUS DI SINI

class HistorySheet extends StatelessWidget {
  const HistorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Referensi ke data LOGS di Firebase
    final DatabaseReference logRef = FirebaseDatabase.instance.ref(
      'home/room1/logs',
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.7, // Tinggi 70% layar
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          // Garis Pegangan (Drag Handle)
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header Judul
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Riwayat Insiden",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                // Tombol Refresh / Hapus (Opsional)
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text("Realtime Log"),
                ),
              ],
            ),
          ),

          // LIST DATA DARI FIREBASE (StreamBuilder)
          Expanded(
            child: StreamBuilder(
              // Ambil data, urutkan berdasarkan timestamp, ambil 20 terakhir
              stream: logRef.orderByChild('timestamp').limitToLast(20).onValue,
              builder: (context, snapshot) {
                // 1. Tampilan Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Tampilan Jika Ada Data
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  // Konversi Data Firebase (Map) menjadi List
                  try {
                    Map<dynamic, dynamic> map =
                        snapshot.data!.snapshot.value as Map;
                    List<dynamic> list = [];
                    map.forEach((key, value) {
                      list.add(value);
                    });

                    // Urutkan dari yang Paling Baru (Reverse Sort)
                    list.sort((a, b) {
                      var timeA = a['timestamp'] ?? 0;
                      var timeB = b['timestamp'] ?? 0;
                      return timeB.compareTo(timeA);
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        var log = list[index];
                        bool isDanger = log['status'] == 'danger';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon Status Bulat
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isDanger
                                      ? const Color(0xFFFFEBEE)
                                      : const Color(0xFFE8F5E9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isDanger
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_circle_outline,
                                  color: isDanger ? Colors.red : Colors.green,
                                ),
                              ),
                              const SizedBox(width: 15),

                              // Teks Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log['title'] ?? "Info System",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDanger
                                            ? Colors.red[700]
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      log['time'] ?? "-",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Nilai Sensor (Pojok Kanan)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  log['value'] ?? "",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } catch (e) {
                    return Center(child: Text("Error memuat data: $e"));
                  }
                }

                // 3. Tampilan Jika Kosong
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_toggle_off,
                        size: 50,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Belum ada riwayat tercatat",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
