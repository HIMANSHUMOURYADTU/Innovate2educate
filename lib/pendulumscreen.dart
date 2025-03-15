import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PendulumMotionScreen extends StatefulWidget {
  const PendulumMotionScreen({super.key});

  @override
  State<PendulumMotionScreen> createState() => _PendulumMotionScreenState();
}

class _PendulumMotionScreenState extends State<PendulumMotionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double length = 1.0; // Pendulum length in meters
  double theta0 = 30.0; // Initial angle in degrees
  double angularDisplacement = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..addListener(() {
        setState(() {
          updatePendulum();
        });
      });
  }

  void updatePendulum() {
    const double g = 9.81;
    double t = _controller.value * 10; // Simulate 10 seconds
    double omega = sqrt(g / length); // Angular frequency
    angularDisplacement = theta0 * cos(omega * t) * pi / 180; // Small-angle approximation in radians
  }

  double getPeriod() {
    const double g = 9.81;
    return 2 * pi * sqrt(length / g);
  }

  void simulatePendulum() {
    _controller.duration = Duration(milliseconds: (getPeriod() * 1000 * 2).toInt()); // Two periods
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pendulum Motion", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white70),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.8),
                title: const Text("Pendulum Info", style: TextStyle(color: Colors.white)),
                content: const Text(
                  "θ(t) = θ₀cos(ωt)\nω = √(g/L)\nT = 2π√(L/g)",
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK", style: TextStyle(color: Colors.deepPurpleAccent)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight + 20),
              _buildSlider("Length", length, 0.5, 5.0, "m", (value) => setState(() => length = value)),
              _buildSlider("Initial Angle", theta0, 5, 45, "°", (value) => setState(() => theta0 = value)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton("Simulate", simulatePendulum),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconButton(_controller.isAnimating ? Icons.pause : Icons.play_arrow, () {
                    if (_controller.isAnimating) {
                      _controller.stop();
                    } else {
                      _controller.forward();
                    }
                    setState(() {});
                  }),
                  _buildIconButton(Icons.fast_forward, () {
                    _controller.value += 0.1;
                    if (_controller.value > 1) _controller.value = 1;
                    updatePendulum();
                  }),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.deepPurpleAccent,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  "Angle: ${(angularDisplacement * 180 / pi).toStringAsFixed(2)}°",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.deepPurple,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: _generatePendulumData(),
                                isCurved: true,
                                color: Colors.deepPurpleAccent,
                                barWidth: 3,
                              ),
                            ],
                            titlesData: const FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: _getTitles,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: _getTitles,
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: _getTopTitles,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24)),
                            gridData: FlGridData(
                              show: true,
                              getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
                            ),
                            backgroundColor: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        CustomPaint(
                          painter: PendulumPainter(_controller.value, length, theta0),
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generatePendulumData() {
    List<FlSpot> spots = [];
    const double g = 9.81;
    double omega = sqrt(g / length);
    for (double t = 0; t <= 10; t += 0.1) {
      double theta = theta0 * cos(omega * t);
      spots.add(FlSpot(t, theta));
    }
    return spots;
  }

  static Widget _getTitles(double value, TitleMeta meta) {
    return Text(
      value.toStringAsFixed(1),
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    );
  }

  static Widget _getTopTitles(double value, TitleMeta meta) {
    return const Text(
      "Angular Displacement (θ)",
      style: TextStyle(color: Colors.white70, fontSize: 12),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, String unit, Function(double) onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
        const SizedBox(width: 10),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            label: "${value.toStringAsFixed(1)} $unit",
            onChanged: onChanged,
            activeColor: Colors.deepPurpleAccent,
            inactiveColor: Colors.white24,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70),
      onPressed: onPressed,
      splashColor: Colors.deepPurpleAccent.withOpacity(0.5),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class PendulumPainter extends CustomPainter {
  final double progress;
  final double length;
  final double theta0;

  PendulumPainter(this.progress, this.length, this.theta0);

  @override
  void paint(Canvas canvas, Size size) {
    const double g = 9.81;
    double omega = sqrt(g / length);
    double theta = theta0 * cos(omega * progress * 10) * pi / 180;

    // Pivot point
    Offset pivot = Offset(size.width / 2, size.height / 4);
    Paint pivotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(pivot, 5, pivotPaint);

    // Pendulum bob
    double x = pivot.dx + length * 100 * sin(theta);
    double y = pivot.dy + length * 100 * cos(theta);
    Paint bobPaint = Paint()..color = Colors.deepPurpleAccent;
    canvas.drawCircle(Offset(x, y), 10, bobPaint);

    // String
    Paint stringPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2;
    canvas.drawLine(pivot, Offset(x, y), stringPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}