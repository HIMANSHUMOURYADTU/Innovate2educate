import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FreeFallScreen extends StatefulWidget {
  const FreeFallScreen({super.key});

  @override
  State<FreeFallScreen> createState() => _FreeFallScreenState();
}

class _FreeFallScreenState extends State<FreeFallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double height = 100.0; // Initial height in meters
  double velocity = 0;
  double position = 0;
  bool airResistance = false;
  double dragCoefficient = 0.1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..addListener(() {
        setState(() {
          updateFall();
        });
      });
  }

  void updateFall() {
    const double g = 9.81;
    double t = _controller.value * getMaxTime();
    if (airResistance) {
      double vTerminal = g / dragCoefficient;
      velocity = vTerminal * (1 - exp(-dragCoefficient * t));
      position = height - (vTerminal * t - (vTerminal / dragCoefficient) * (1 - exp(-dragCoefficient * t)));
    } else {
      velocity = g * t;
      position = height - 0.5 * g * t * t;
    }
    if (position < 0) position = 0; // Ground level
  }

  double getMaxTime() {
    const double g = 9.81;
    return airResistance ? 10.0 : sqrt(2 * height / g); // Arbitrary max for air resistance
  }

  void simulateFall() {
    _controller.duration = Duration(milliseconds: (getMaxTime() * 1000).toInt());
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Free Fall", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white70),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.8),
                title: const Text("Free Fall Info", style: TextStyle(color: Colors.white)),
                content: const Text(
                  "No Drag: y = h - ½gt²\nWith Drag: v = v_t(1 - e^(-kt))",
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
              _buildSlider("Initial Height", height, 10, 200, "m", (value) => setState(() => height = value)),
              Row(
                children: [
                  Checkbox(
                    value: airResistance,
                    onChanged: (value) => setState(() => airResistance = value!),
                    activeColor: Colors.deepPurpleAccent,
                  ),
                  const Text("Air Resistance", style: TextStyle(color: Colors.white70)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Slider(
                      value: dragCoefficient,
                      min: 0.01,
                      max: 0.5,
                      divisions: 49,
                      label: "Drag Coeff: ${dragCoefficient.toStringAsFixed(2)}",
                      onChanged: airResistance ? (value) => setState(() => dragCoefficient = value) : null,
                      activeColor: Colors.deepPurpleAccent,
                      inactiveColor: Colors.white24,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton("Simulate", simulateFall),
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
                    updateFall();
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
                  "Height: ${position.toStringAsFixed(2)} m | Velocity: ${velocity.toStringAsFixed(2)} m/s",
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
                                spots: _generateFallData(),
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
                          painter: FreeFallPainter(_controller.value, height, airResistance, dragCoefficient),
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

  List<FlSpot> _generateFallData() {
    List<FlSpot> spots = [];
    const double g = 9.81;
    double maxT = getMaxTime();
    for (double t = 0; t <= maxT; t += 0.1) {
      double y = airResistance
          ? height - ((g / dragCoefficient) * t - (g / (dragCoefficient * dragCoefficient)) * (1 - exp(-dragCoefficient * t)))
          : height - 0.5 * g * t * t;
      if (y < 0) break;
      spots.add(FlSpot(t, y));
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
      "Height vs Time",
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

class FreeFallPainter extends CustomPainter {
  final double progress;
  final double height;
  final bool airResistance;
  final double dragCoefficient;

  FreeFallPainter(this.progress, this.height, this.airResistance, this.dragCoefficient);

  @override
  void paint(Canvas canvas, Size size) {
    const double g = 9.81;
    double maxT = airResistance ? 10.0 : sqrt(2 * height / g);
    double t = progress * maxT;
    double y = airResistance
        ? height - ((g / dragCoefficient) * t - (g / (dragCoefficient * dragCoefficient)) * (1 - exp(-dragCoefficient * t)))
        : height - 0.5 * g * t * t;

    if (y < 0) y = 0;
    Paint objectPaint = Paint()..color = Colors.deepPurpleAccent;
    canvas.drawCircle(
      Offset(size.width / 2, size.height * (1 - y / height)),
      10,
      objectPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}