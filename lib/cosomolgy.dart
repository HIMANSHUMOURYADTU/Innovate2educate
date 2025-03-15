import 'dart:math'; // Provides exp, pow, sqrt, etc.
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Define custom sinh function since it's not in dart:math
double sinh(double x) {
  return (exp(x) - exp(-x)) / 2;
}

class CosomologyScreen extends StatefulWidget {
  const CosomologyScreen({super.key});

  @override
  State<CosomologyScreen> createState() => _CosomologyScreenState();
}

class _CosomologyScreenState extends State<CosomologyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double h0 = 70.0; // Hubble constant in km/s/Mpc
  double omegaM = 0.3; // Matter density parameter
  double omegaLambda = 0.7; // Dark energy density parameter
  double scaleFactor = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..addListener(() {
        setState(() {
          updateScaleFactor();
        });
      });
  }

  void updateScaleFactor() {
    double t = _controller.value * 10; // Simulate 10 billion years
    scaleFactor = calculateScaleFactor(t);
  }

  double calculateScaleFactor(double t) {
    // Simplified Friedmann equation for flat universe
    // a(t) = (sinh(3/2 * H0 * sqrt(Omega_Lambda) * t))^(2/3)
    const double c = 3.0e5; // Speed of light in km/s
    double h0InProperUnits = h0 / c; // Convert H0 to 1/s
    double term = 1.5 * h0InProperUnits * sqrt(omegaLambda) * t;
    return pow(sinh(term), 2.0 / 3.0) as double; // Using custom sinh
  }

  void simulateExpansion() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cosmology Simulation", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white70),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.8),
                title: const Text("Cosmology Info", style: TextStyle(color: Colors.white)),
                content: const Text(
                  "a(t) ∝ (sinh(3/2 H₀ √Ω_Λ t))^(2/3)\nH₀: Hubble Constant\nΩ_m: Matter Density\nΩ_Λ: Dark Energy Density",
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
              _buildSlider("Hubble Constant (H₀)", h0, 50, 100, "km/s/Mpc", (value) => setState(() => h0 = value)),
              _buildSlider("Matter Density (Ω_m)", omegaM, 0, 1, "", (value) => setState(() => omegaM = value)),
              _buildSlider("Dark Energy (Ω_Λ)", omegaLambda, 0, 1, "", (value) => setState(() => omegaLambda = value)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton("Simulate", simulateExpansion),
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
                    updateScaleFactor();
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
                  "Scale Factor: ${scaleFactor.toStringAsFixed(2)}",
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
                                spots: _generateExpansionData(),
                                isCurved: true,
                                color: Colors.deepPurpleAccent,
                                barWidth: 3,
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toStringAsFixed(1),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toStringAsFixed(1),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) => const Text(
                                    " JESSSScale Factor a(t)",
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
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
                          painter: GalaxyExpansionPainter(_controller.value, h0, omegaM, omegaLambda),
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

  List<FlSpot> _generateExpansionData() {
    List<FlSpot> spots = [];
    for (double t = 0; t <= 10; t += 0.1) {
      double a = calculateScaleFactor(t);
      spots.add(FlSpot(t, a));
    }
    return spots;
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

class GalaxyExpansionPainter extends CustomPainter {
  final double progress;
  final double h0;
  final double omegaM;
  final double omegaLambda;

  GalaxyExpansionPainter(this.progress, this.h0, this.omegaM, this.omegaLambda);

  double calculateScaleFactor(double t) {
    const double c = 3.0e5; // Speed of light in km/s
    double h0InProperUnits = h0 / c;
    double term = 1.5 * h0InProperUnits * sqrt(omegaLambda) * t;
    return pow(sinh(term), 2.0 / 3.0) as double; // Using custom sinh
  }

  @override
  void paint(Canvas canvas, Size size) {
    double a = calculateScaleFactor(progress * 10);
    Paint galaxyPaint = Paint()..color = Colors.white.withOpacity(0.8);

    // Simulate galaxy positions expanding with scale factor
    for (int i = 0; i < 10; i++) {
      double x = size.width * 0.1 * i * a;
      double y = size.height * 0.5;
      if (x < size.width) {
        canvas.drawCircle(Offset(x, y), 5 * a, galaxyPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}