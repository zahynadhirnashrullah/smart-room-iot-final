import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'app_theme.dart';
import 'sensor_card.dart';
import 'history_sheet.dart';
import 'my_drawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    'home/room1/sensors',
  );
  final DatabaseReference _logRef = FirebaseDatabase.instance.ref(
    'home/room1/logs',
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<FlSpot> suhuSpots = [];
  double xValue = 0;
  late AnimationController _alertController;
  String _lastStatus = "AMAN";

  @override
  void initState() {
    super.initState();
    _dbRef.keepSynced(true);
    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _alertController.dispose();
    super.dispose();
  }

  void _recordIncident(String title, String status, String value) {
    String timeNow = DateFormat('dd MMM, HH:mm').format(DateTime.now());
    _logRef.push().set({
      'title': title,
      'time': timeNow,
      'status': status,
      'value': value,
      'timestamp': ServerValue.timestamp,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      drawer: const MyDrawer(activeIndex: 0),

      body: StreamBuilder(
        stream: _dbRef.onValue,
        builder: (context, snapshot) {
          double suhu = 0;
          var kelembapan = 0;
          var gas = 0;
          String status = "Menghubungkan...";
          bool isSafe = true;

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            try {
              final data = Map<dynamic, dynamic>.from(
                snapshot.data!.snapshot.value as Map,
              );
              suhu = double.parse(data['suhu'].toString());
              kelembapan = data['kelembapan'] ?? 0;
              gas = data['gas'] ?? 0;
              status = data['status'] ?? "AMAN";

              isSafe =
                  !status.contains("ASAP") &&
                  !status.contains("PANAS") &&
                  !status.contains("BAHAYA");

              if (!isSafe && _lastStatus.contains("AMAN")) {
                _recordIncident(
                  "Bahaya Terdeteksi!",
                  "danger",
                  "Suhu: $suhu°C | Gas: $gas",
                );
              }
              _lastStatus = isSafe ? "AMAN" : "BAHAYA";

              // Update Grafik
              if (suhuSpots.isEmpty || suhuSpots.last.y != suhu) {
                suhuSpots.add(FlSpot(xValue, suhu));
                xValue++;
                if (suhuSpots.length > 20)
                  suhuSpots.removeAt(0); // Menampilkan 20 titik terakhir
              }
            } catch (e) {
              print("Error: $e");
            }
          }

          return Stack(
            children: [
              // BACKGROUND HEADER
              Container(
                height: 380,
                decoration: BoxDecoration(
                  gradient: isSafe
                      ? AppTheme.safeGradient
                      : AppTheme.dangerGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSafe
                          ? Colors.green.withOpacity(0.4)
                          : Colors.red.withOpacity(0.6),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),

              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 10),
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.menu_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                          ),
                        ),
                        Text(
                          "Smart Monitoring",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.history_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const HistorySheet(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // STATUS UTAMA
                    Center(
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: isSafe
                                ? const AlwaysStoppedAnimation(1.0)
                                : _alertController,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                isSafe
                                    ? Icons.shield_outlined
                                    : Icons.warning_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            isSafe ? "Kondisi Aman" : "PERINGATAN BAHAYA!",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- GRID SENSOR (PERBAIKAN LOGIKA MERAH) ---
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int gridCols = constraints.maxWidth > 600 ? 4 : 2;
                        return GridView.count(
                          crossAxisCount: gridCols,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.1,
                          // ... di dalam GridView.count ...
                          children: [
                            // --- KARTU 1: TEMPERATUR ---
                            SensorCard(
                              title: "Temperatur",
                              value: "$suhu",
                              unit: "°C",
                              icon: Icons.thermostat_rounded,
                              color: Colors.orange,
                              // LOGIKA BAHAYA: Jika Suhu > 35 ATAU Status mengandung kata "PANAS"
                              // Maka kartu akan berubah jadi MERAH SOLID
                              isDanger: suhu > 35 || status.contains("PANAS"),
                            ),

                            // --- KARTU 2: KELEMBAPAN ---
                            SensorCard(
                              title: "Kelembapan",
                              value: "$kelembapan",
                              unit: "%",
                              icon: Icons.water_drop_rounded,
                              color: Colors.blue,
                              isDanger:
                                  false, // Kelembapan jarang bahaya, jadi false aja
                            ),

                            // --- KARTU 3: GAS ---
                            SensorCard(
                              title: "Gas Level",
                              value: "$gas",
                              unit: "PPM",
                              icon: Icons.cloud_circle_rounded,
                              color: Colors.purple,
                              // LOGIKA BAHAYA: Jika Gas > 200 ATAU Status mengandung kata "ASAP/BAHAYA"
                              isDanger:
                                  gas > 200 ||
                                  status.contains("ASAP") ||
                                  status.contains("BAHAYA"),
                            ),

                            // --- KARTU 4: SISTEM ---
                            SensorCard(
                              title: "Status Sistem",
                              value: snapshot.hasData ? "Online" : "...",
                              unit: "",
                              icon: Icons.wifi_tethering,
                              color: Colors.green,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    // --- GRAFIK (PERBAIKAN: AGAR TIDAK KELUAR GARIS) ---
                    Container(
                      height: 350,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowColor,
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Grafik Temperatur Realtime",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: suhuSpots.isEmpty
                                ? const Center(
                                    child: Text(
                                      "Menunggu Data...",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : LineChart(
                                    LineChartData(
                                      // KUNCI UTAMA: clipData mencegah garis keluar kotak
                                      clipData: const FlClipData.all(),

                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval:
                                            10, // Garis bantu tiap 10 derajat
                                        getDrawingHorizontalLine: (value) =>
                                            FlLine(
                                              color: Colors.grey[200],
                                              strokeWidth: 1,
                                            ),
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 35,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: suhuSpots,
                                          isCurved: true,
                                          color: isSafe
                                              ? Colors.orange
                                              : Colors.red,
                                          barWidth: 3,
                                          isStrokeCapRound: true,
                                          dotData: const FlDotData(
                                            show: true,
                                          ), // Menampilkan Titik
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color:
                                                (isSafe
                                                        ? Colors.orange
                                                        : Colors.red)
                                                    .withOpacity(0.15),
                                          ),
                                        ),
                                      ],
                                      // BATASI RANGE (Agar grafik tidak loncat-loncat)
                                      // Misal: Suhu ruangan umumnya 20 - 50 derajat.
                                      minY: 20,
                                      maxY: 60,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
