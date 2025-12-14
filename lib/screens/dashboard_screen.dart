import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../widgets/sensor_card.dart';
import '../widgets/history_sheet.dart';
import '../widgets/my_drawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  // Referensi Sensor (Read Only)
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    'home/room1/sensors',
  );

  // Referensi Kontrol Manual (Read & Write)
  final DatabaseReference _controlRef = FirebaseDatabase.instance.ref(
    'home/room1/control',
  );

  final DatabaseReference _logRef = FirebaseDatabase.instance.ref(
    'home/room1/logs',
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<FlSpot> suhuSpots = [];
  double xValue = 0;
  late AnimationController _alertController;
  String _lastStatus = "AMAN";

  // State untuk tombol Manual
  bool _isManualFanOn = false;

  // STATE KONEKSI INTERNET/SERVER
  bool _isAppConnected = false;

  @override
  void initState() {
    super.initState();
    _dbRef.keepSynced(true);
    _controlRef.keepSynced(true);

    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);

    // 1. Listener Tombol Kipas
    _controlRef.child('fan').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _isManualFanOn = event.snapshot.value == true;
        });
      }
    });

    // LISTENER KONEKSI REAL-TIME
    // .info/connected adalah path spesial Firebase untuk cek koneksi device ke server
    FirebaseDatabase.instance.ref(".info/connected").onValue.listen((event) {
      setState(() {
        _isAppConnected = (event.snapshot.value ?? false) == true;
      });
    });
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

  // Fungsi mengubah state kipas manual
  void _toggleFan(bool value) {
    _controlRef.update({'fan': value});
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
          String kipasStatusReal = "MATI";
          String kipasMode = "MANUAL";
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
              kipasStatusReal = data['kipas_status'] ?? "MATI";
              kipasMode = data['kipas_mode'] ?? "MANUAL";

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

              if (suhuSpots.isEmpty || suhuSpots.last.y != suhu) {
                suhuSpots.add(FlSpot(xValue, suhu));
                xValue++;
                if (suhuSpots.length > 20) {
                  suhuSpots.removeAt(0);
                }
              }
            } catch (e) {
              print("Error parsing data: $e");
            }
          }

          // Logika Kipas
          bool isAutoModeActive = suhu >= 35.0;
          bool switchValue = isAutoModeActive ? true : _isManualFanOn;

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

                    // HEADER NAV DENGAN INDIKATOR ONLINE/OFFLINE
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

                        // --- [PERUBAHAN UI] INDIKATOR ONLINE/OFFLINE ---
                        Column(
                          children: [
                            Text(
                              "Smart Monitoring",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Badge Status Koneksi
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    // Hijau jika Connect, Merah jika Disconnect
                                    color: _isAppConnected
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _isAppConnected ? "Online" : "Offline",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

                    // STATUS UTAMA (LINGKARAN)
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

                    const SizedBox(height: 30),

                    // --- PANEL KONTROL KIPAS ---
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: switchValue
                                  ? (isAutoModeActive
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.blue.withOpacity(0.1))
                                  : Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.wind_power_rounded,
                              color: switchValue
                                  ? (isAutoModeActive
                                        ? Colors.orange
                                        : Colors.blue[700])
                                  : Colors.grey,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Kontrol Kipas",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  isAutoModeActive
                                      ? "Mode Otomatis (>30°C)"
                                      : "Status: $kipasStatusReal",
                                  style: TextStyle(
                                    color: isAutoModeActive
                                        ? Colors.orange
                                        : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // SWITCH ON/OFF
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: switchValue,
                              activeColor: isAutoModeActive
                                  ? Colors.orange
                                  : Colors.blue,
                              activeTrackColor: isAutoModeActive
                                  ? Colors.orange[200]
                                  : Colors.blue[200],
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.grey[300],

                              onChanged: isAutoModeActive
                                  ? null
                                  : (val) => _toggleFan(val),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- GRID SENSOR ---
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
                          children: [
                            SensorCard(
                              title: "Temperatur",
                              value: "$suhu",
                              unit: "°C",
                              icon: Icons.thermostat_rounded,
                              color: Colors.orange,
                              isDanger: status.contains("PANAS"),
                            ),
                            SensorCard(
                              title: "Kelembapan",
                              value: "$kelembapan",
                              unit: "%",
                              icon: Icons.water_drop_rounded,
                              color: Colors.blue,
                              isDanger: false,
                            ),
                            SensorCard(
                              title: "Gas Level",
                              value: "$gas",
                              unit: "PPM",
                              icon: Icons.cloud_circle_rounded,
                              color: Colors.purple,
                              isDanger: gas > 200 || status.contains("ASAP"),
                            ),
                            SensorCard(
                              title: "Status Kipas",
                              value: kipasStatusReal,
                              unit: "",
                              icon: Icons.cyclone_rounded,
                              color: kipasStatusReal == "NYALA"
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    // --- GRAFIK ---
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
                                      clipData: const FlClipData.all(),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 10,
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
                                            getTitlesWidget: (value, meta) =>
                                                Text(
                                                  value.toInt().toString(),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey,
                                                  ),
                                                ),
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
                                          dotData: const FlDotData(show: true),
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
