import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CurrentElectricityScreen extends StatefulWidget {
  const CurrentElectricityScreen({super.key});

  @override
  State<CurrentElectricityScreen> createState() => _CurrentElectricityScreenState();
}

class _CurrentElectricityScreenState extends State<CurrentElectricityScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double resistance = 1000.0; // Resistance in ohms
  double capacitance = 0.001; // Capacitance in farads
  double voltageSource = 10.0; // Voltage in volts
  double voltageCapacitor = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..addListener(() {
        setState(() {
          updateCircuit();
        });
      });
  }

  void updateCircuit() {
    double t = _controller.value * 5; // Simulate 5 seconds
    double tau = resistance * capacitance; // Time constant
    voltageCapacitor = voltageSource * (1 - exp(-t / tau));
  }

  double getTimeConstant() {
    return resistance * capacitance;
  }

  void simulateCircuit() {
    _controller.duration = Duration(milliseconds: (getTimeConstant() * 5 * 1000).toInt()); // 5 time constants
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Electricity (RC Circuit)", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white70),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.8),
                title: const Text("RC Circuit Info", style: TextStyle(color: Colors.white)),
                content: const Text(
                  "V_c(t) = V_s(1 - e^(-t/RC))\nτ = RC",
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
              _buildSlider("Resistance", resistance, 100, 5000, "Ω", (value) => setState(() => resistance = value)),
              _buildSlider("Capacitance", capacitance * 1000, 0.1, 5.0, "mF", (value) => setState(() => capacitance = value / 1000)),
              _buildSlider("Voltage Source", voltageSource, 5, 20, "V", (value) => setState(() => voltageSource = value)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton("Simulate", simulateCircuit),
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
                    updateCircuit();
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
                  "V_Capacitor: ${voltageCapacitor.toStringAsFixed(2)} V",
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
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: _generateCircuitData(),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateCircuitData() {
    List<FlSpot> spots = [];
    double tau = resistance * capacitance;
    for (double t = 0; t <= 5 * tau; t += tau / 50) {
      double v = voltageSource * (1 - exp(-t / tau));
      spots.add(FlSpot(t, v));
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
      "Capacitor Voltage vs Time",
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