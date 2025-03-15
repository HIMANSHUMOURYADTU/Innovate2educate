import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Placeholder imports (create these files if they don’t exist)

import 'chemistry.dart';
import 'cosomolgy.dart';
import 'current_electricity.dart';
import 'free_fall.dart';
import 'pendulumscreen.dart';


void main() {
  runApp(const PhysicsApp());
}

class PhysicsApp extends StatelessWidget {
  const PhysicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70), // Replaces bodyText2
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Replaces headline6
        ),
        useMaterial3: true, // Enable Material 3 for Flutter 3.x
      ),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Physics Simulations",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.deepPurpleAccent,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MenuButton(
                          text: "Projectile Motion",
                          onPressed: () => _navigate(context, ProjectileMotionScreen()),
                        ),
                        MenuButton(
                          text: "Pendulum Motion",
                          onPressed: () => _navigate(context, PendulumMotionScreen()),
                        ),
                        MenuButton(
                          text: "Free Fall",
                          onPressed: () => _navigate(context,  FreeFallScreen()),
                        ),
                        MenuButton(
                          text: "Current Electricity",
                          onPressed: () => _navigate(context,  CurrentElectricityScreen()),
                        ),
                        MenuButton(
                          text: "Cosmology Simulation",
                          onPressed: () => _navigate(context,  CosomologyScreen()),
                        ),
                        MenuButton(
                          text: "Chemistry Hub",
                          onPressed: () => _navigate(context,  ChemistryHomeScreen()),
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

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MenuButton({required this.text, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.deepPurpleAccent,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// PROJECTILE MOTION SIMULATION
class ProjectileMotionScreen extends StatefulWidget {
  const ProjectileMotionScreen({super.key});

  @override
  State<ProjectileMotionScreen> createState() => _ProjectileMotionScreenState();
}

class _ProjectileMotionScreenState extends State<ProjectileMotionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Map<String, dynamic>> projectiles = [];
  double v = 10;
  double angle = 45;
  double kineticEnergy = 0;
  double potentialEnergy = 0;
  bool airResistance = false;
  double dragCoefficient = 0.1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addListener(() {
        setState(() {
          updateEnergies();
        });
      });
  }

  void updateEnergies() {
    const double g = 9.81;
    double t = _controller.value * getMaxTimeOfFlight();
    kineticEnergy = 0;
    potentialEnergy = 0;
    for (var proj in projectiles) {
      double v0 = proj['v'];
      double theta = proj['angle'] * pi / 180;
      double x = airResistance ? calculateXWithDrag(t, v0, theta) : v0 * cos(theta) * t;
      double y = airResistance ? calculateYWithDrag(t, v0, theta) : v0 * sin(theta) * t - 0.5 * g * t * t;
      if (y >= 0) {
        double vx = airResistance ? v0 * cos(theta) * exp(-dragCoefficient * t) : v0 * cos(theta);
        double vy = airResistance ? (v0 * sin(theta) - g / dragCoefficient) * exp(-dragCoefficient * t) + g / dragCoefficient : v0 * sin(theta) - g * t;
        double speed = sqrt(vx * vx + vy * vy);
        kineticEnergy += 0.5 * 1 * speed * speed;
        potentialEnergy += 1 * g * y;
      }
    }
  }

  double getMaxTimeOfFlight() {
    const double g = 9.81;
    double maxTime = 0;
    for (var proj in projectiles) {
      double v0 = proj['v'];
      double theta = proj['angle'] * pi / 180;
      double time = airResistance ? estimateTimeWithDrag(v0, theta) : (2 * v0 * sin(theta)) / g;
      maxTime = max(maxTime, time);
    }
    return maxTime;
  }

  double calculateXWithDrag(double t, double v0, double theta) {
    return v0 * cos(theta) * (1 - exp(-dragCoefficient * t)) / dragCoefficient;
  }

  double calculateYWithDrag(double t, double v0, double theta) {
    const double g = 9.81;
    return (v0 * sin(theta) + g / dragCoefficient) * (1 - exp(-dragCoefficient * t)) / dragCoefficient - (g * t) / dragCoefficient;
  }

  double estimateTimeWithDrag(double v0, double theta) {
    const double g = 9.81;
    double tEstimate = (2 * v0 * sin(theta)) / g;
    double y = calculateYWithDrag(tEstimate, v0, theta);
    while (y > 0) {
      tEstimate += 0.1;
      y = calculateYWithDrag(tEstimate, v0, theta);
    }
    return tEstimate;
  }

  void simulateProjectile() {
    double timeOfFlight = getMaxTimeOfFlight();
    _controller.duration = Duration(milliseconds: (timeOfFlight * 1000).toInt());
    _controller.reset();
    _controller.forward();
  }

  void addProjectile() {
    projectiles.add({
      'v': v,
      'angle': angle,
      'color': Colors.primaries[Random().nextInt(Colors.primaries.length)],
      'path': <FlSpot>[],
    });
    simulateProjectile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Projectile Motion", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white70),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.8),
                title: const Text("Physics Info", style: TextStyle(color: Colors.white)),
                content: const Text(
                  "y = v₀sin(θ)t - ½gt²\nx = v₀cos(θ)t\nKE = ½mv²\nPE = mgh",
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
              _buildSlider("Initial Velocity", v, 5, 50, "m/s", (value) => setState(() => v = value)),
              _buildSlider("Launch Angle", angle, 0, 90, "°", (value) => setState(() => angle = value)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton("Add Projectile", addProjectile),
                  _buildButton("Simulate All", simulateProjectile),
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
                    updateEnergies();
                  }),
                ],
              ),
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
                  "KE: ${kineticEnergy.toStringAsFixed(2)} J | PE: ${potentialEnergy.toStringAsFixed(2)} J",
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
                            lineBarsData: projectiles.map((proj) {
                              List<FlSpot> path = [];
                              double t = 0;
                              double maxT = airResistance
                                  ? estimateTimeWithDrag(proj['v'], proj['angle'] * pi / 180)
                                  : (2 * proj['v'] * sin(proj['angle'] * pi / 180)) / 9.81;
                              while (t <= maxT) {
                                double x = airResistance
                                    ? calculateXWithDrag(t, proj['v'], proj['angle'] * pi / 180)
                                    : proj['v'] * cos(proj['angle'] * pi / 180) * t;
                                double y = airResistance
                                    ? calculateYWithDrag(t, proj['v'], proj['angle'] * pi / 180)
                                    : proj['v'] * sin(proj['angle'] * pi / 180) * t - 0.5 * 9.81 * t * t;
                                if (y < 0) break;
                                path.add(FlSpot(x, y));
                                t += 0.1;
                              }
                              return LineChartBarData(
                                spots: path,
                                isCurved: true,
                                color: proj['color'],
                                barWidth: 3,
                              );
                            }).toList(),
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
                          painter: MultiProjectilePainter(_controller.value, projectiles, airResistance, dragCoefficient),
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

  static Widget _getTitles(double value, TitleMeta meta) {
    return Text(
      value.toStringAsFixed(1),
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    );
  }

  static Widget _getTopTitles(double value, TitleMeta meta) {
    return const Text(
      "Projectile Paths",
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

class MultiProjectilePainter extends CustomPainter {
  final double progress;
  final List<Map<String, dynamic>> projectiles;
  final bool airResistance;
  final double dragCoefficient;

  MultiProjectilePainter(this.progress, this.projectiles, this.airResistance, this.dragCoefficient);

  @override
  void paint(Canvas canvas, Size size) {
    const double g = 9.81;
    double maxX = 0;
    double maxY = 0;
    for (var proj in projectiles) {
      double timeOfFlight = airResistance
          ? estimateTimeWithDrag(proj['v'], proj['angle'] * pi / 180)
          : (2 * proj['v'] * sin(proj['angle'] * pi / 180)) / g;
      maxX = max(maxX, airResistance
          ? calculateXWithDrag(timeOfFlight, proj['v'], proj['angle'] * pi / 180)
          : proj['v'] * cos(proj['angle'] * pi / 180) * timeOfFlight);
      maxY = max(maxY, (proj['v'] * sin(proj['angle'] * pi / 180) * proj['v'] * sin(proj['angle'] * pi / 180)) / (2 * g));
    }

    for (var proj in projectiles) {
      double t = progress * (airResistance
          ? estimateTimeWithDrag(proj['v'], proj['angle'] * pi / 180)
          : (2 * proj['v'] * sin(proj['angle'] * pi / 180)) / g);
      double x = airResistance
          ? calculateXWithDrag(t, proj['v'], proj['angle'] * pi / 180)
          : proj['v'] * cos(proj['angle'] * pi / 180) * t;
      double y = airResistance
          ? calculateYWithDrag(t, proj['v'], proj['angle'] * pi / 180)
          : proj['v'] * sin(proj['angle'] * pi / 180) * t - 0.5 * g * t * t;

      if (y >= 0) {
        Paint paint = Paint()
          ..color = proj['color']
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset((x / maxX) * size.width, size.height - ((y / maxY) * size.height)),
          5,
          paint,
        );
        canvas.drawCircle(
          Offset((x / maxX) * size.width, size.height - ((y / maxY) * size.height)),
          8,
          Paint()
            ..color = proj['color'].withOpacity(0.3)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
    }
  }

  double estimateTimeWithDrag(double v0, double theta) {
    const double g = 9.81;
    double tEstimate = (2 * v0 * sin(theta)) / g;
    double y = (v0 * sin(theta) + g / dragCoefficient) * (1 - exp(-dragCoefficient * tEstimate)) / dragCoefficient - (g * tEstimate) / dragCoefficient;
    while (y > 0) {
      tEstimate += 0.1;
      y = (v0 * sin(theta) + g / dragCoefficient) * (1 - exp(-dragCoefficient * tEstimate)) / dragCoefficient - (g * tEstimate) / dragCoefficient;
    }
    return tEstimate;
  }

  double calculateXWithDrag(double t, double v0, double theta) {
    return v0 * cos(theta) * (1 - exp(-dragCoefficient * t)) / dragCoefficient;
  }

  double calculateYWithDrag(double t, double v0, double theta) {
    const double g = 9.81;
    return (v0 * sin(theta) + g / dragCoefficient) * (1 - exp(-dragCoefficient * t)) / dragCoefficient - (g * t) / dragCoefficient;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
