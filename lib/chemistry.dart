import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MaterialApp(home: ChemistryHomeScreen()));
}

class ChemistryHomeScreen extends StatelessWidget {
  const ChemistryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chemistry Hub", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Explore Chemistry",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildHubCard(context, "Virtual Labs", Icons.science, const VirtualLabsScreen()),
                      _buildHubCard(context, "Periodic Table", Icons.table_chart, const PeriodicTableScreen()),
                      _buildHubCard(context, "Element Match", Icons.gamepad, const ElementMatchGame()),
                      _buildHubCard(context, "Reaction Balance", Icons.balance, const ReactionBalanceGame()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHubCard(BuildContext context, String title, IconData icon, Widget destination) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.deepPurpleAccent, blurRadius: 10, offset: Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Virtual Labs Screen
class VirtualLabsScreen extends StatefulWidget {
  const VirtualLabsScreen({super.key});

  @override
  State<VirtualLabsScreen> createState() => _VirtualLabsScreenState();
}

class _VirtualLabsScreenState extends State<VirtualLabsScreen> {
  double acidVolume = 0.0;
  double baseVolume = 0.0;
  double ph = 7.0;

  void performTitration() {
    setState(() {
      // Simplified pH calculation for demo (acid/base neutralization)
      if (acidVolume > baseVolume) {
        ph = 7 - (acidVolume - baseVolume) * 0.1;
      } else if (baseVolume > acidVolume) {
        ph = 7 + (baseVolume - acidVolume) * 0.1;
      } else {
        ph = 7.0; // Neutral
      }
      if (ph < 1) ph = 1;
      if (ph > 13) ph = 13;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Virtual Lab: Acid-Base Titration", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
              _buildSlider("Acid Volume", acidVolume, 0, 50, "mL", (value) => setState(() => acidVolume = value)),
              _buildSlider("Base Volume", baseVolume, 0, 50, "mL", (value) => setState(() => baseVolume = value)),
              ElevatedButton(
                onPressed: performTitration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Perform Titration"),
              ),
              const SizedBox(height: 20),
              Text(
                "pH: ${ph.toStringAsFixed(1)}",
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: _generateTitrationData(),
                        isCurved: true,
                        color: Colors.deepPurpleAccent,
                        barWidth: 3,
                      ),
                    ],
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                    ),
                    borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24)),
                    gridData: const FlGridData(show: true),
                    minY: 0,
                    maxY: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateTitrationData() {
    List<FlSpot> spots = [];
    for (double vol = 0; vol <= 50; vol += 1) {
      double tempPh = 7.0;
      if (vol > baseVolume) {
        tempPh = 7 - (vol - baseVolume) * 0.1;
      } else if (baseVolume > vol) {
        tempPh = 7 + (baseVolume - vol) * 0.1;
      }
      if (tempPh < 1) tempPh = 1;
      if (tempPh > 13) tempPh = 13;
      spots.add(FlSpot(vol, tempPh));
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
}

// Periodic Table Screen
class PeriodicTableScreen extends StatelessWidget {
  const PeriodicTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final elements = [
      {"symbol": "H", "name": "Hydrogen", "atomicNumber": 1, "mass": 1.008},
      {"symbol": "He", "name": "Helium", "atomicNumber": 2, "mass": 4.0026},
      {"symbol": "Li", "name": "Lithium", "atomicNumber": 3, "mass": 6.94},
      // Add more elements as needed (up to 118 for a full table)
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Interactive Periodic Table", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 18,
              childAspectRatio: 1,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: elements.length,
            itemBuilder: (context, index) {
              final element = elements[index];
              return GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    title: Text(element["name"] as String, style: const TextStyle(color: Colors.white)),
                    content: Text(
                      "Symbol: ${element["symbol"]}\nAtomic Number: ${element["atomicNumber"]}\nMass: ${element["mass"]}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close", style: TextStyle(color: Colors.deepPurpleAccent)),
                      ),
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withOpacity(0.7),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Center(
                    child: Text(
                      element["symbol"] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Element Match Mini-Game
class ElementMatchGame extends StatefulWidget {
  const ElementMatchGame({super.key});

  @override
  State<ElementMatchGame> createState() => _ElementMatchGameState();
}

class _ElementMatchGameState extends State<ElementMatchGame> {
  final List<Map<String, String>> elements = [
    {"symbol": "H", "name": "Hydrogen"},
    {"symbol": "O", "name": "Oxygen"},
    {"symbol": "C", "name": "Carbon"},
    {"symbol": "N", "name": "Nitrogen"},
  ];
  late List<String> symbols;
  late List<String> names;
  int score = 0;
  String? selectedSymbol;
  String? selectedName;

  @override
  void initState() {
    super.initState();
    symbols = elements.map((e) => e["symbol"]!).toList()..shuffle();
    names = elements.map((e) => e["name"]!).toList()..shuffle();
  }

  void checkMatch(String symbol, String name) {
    setState(() {
      if (selectedSymbol == null) {
        selectedSymbol = symbol;
      } else if (selectedName == null) {
        selectedName = name;
        if (elements.any((e) => e["symbol"] == selectedSymbol && e["name"] == selectedName)) {
          score += 10;
          symbols.remove(selectedSymbol);
          names.remove(selectedName);
        }
        selectedSymbol = null;
        selectedName = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Element Match Game", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
              Text("Score: $score", style: const TextStyle(fontSize: 20, color: Colors.white)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: symbols.map((symbol) => _buildGameTile(symbol, () => checkMatch(symbol, ""))).toList(),
                  ),
                  Column(
                    children: names.map((name) => _buildGameTile(name, () => checkMatch("", name))).toList(),
                  ),
                ],
              ),
              if (symbols.isEmpty)
                const Text(
                  "You Won!",
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameTile(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

// Reaction Balance Mini-Game
class ReactionBalanceGame extends StatefulWidget {
  const ReactionBalanceGame({super.key});

  @override
  State<ReactionBalanceGame> createState() => _ReactionBalanceGameState();
}

class _ReactionBalanceGameState extends State<ReactionBalanceGame> {
  final List<Map<String, dynamic>> reactions = [
    {
      "equation": "H₂ + O₂ → H₂O",
      "correct": {"H₂": 2, "O₂": 1, "H₂O": 2},
    },
    {
      "equation": "CH₄ + O₂ → CO₂ + H₂O",
      "correct": {"CH₄": 1, "O₂": 2, "CO₂": 1, "H₂O": 2},
    },
  ];
  int currentReaction = 0;
  Map<String, int> userCoefficients = {};
  int score = 0;

  @override
  void initState() {
    super.initState();
    resetCoefficients();
  }

  void resetCoefficients() {
    userCoefficients = {};
    for (var part in reactions[currentReaction]["equation"].split(" → ")) {
      for (var molecule in part.split(" + ")) {
        userCoefficients[molecule] = 1;
      }
    }
  }

  void checkBalance() {
    setState(() {
      final correct = reactions[currentReaction]["correct"] as Map<String, int>;
      if (userCoefficients.entries.every((entry) => entry.value == (correct[entry.key] ?? 0))) {
        score += 10;
        currentReaction = (currentReaction + 1) % reactions.length;
        resetCoefficients();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final equationParts = reactions[currentReaction]["equation"].split(" → ");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reaction Balance Game", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
              Text("Score: $score", style: const TextStyle(fontSize: 20, color: Colors.white)),
              const SizedBox(height: 20),
              Text(
                "Balance: ${equationParts[0]} → ${equationParts[1]}",
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: userCoefficients.keys.map((molecule) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () => setState(() {
                          if (userCoefficients[molecule]! > 1) userCoefficients[molecule] = userCoefficients[molecule]! - 1;
                        }),
                      ),
                      Text(
                        "${userCoefficients[molecule]} $molecule",
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => setState(() => userCoefficients[molecule] = userCoefficients[molecule]! + 1),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: checkBalance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Check Balance"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}