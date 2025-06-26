import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/habit_form_page.dart';
import 'package:habit_tracker/views/settings_page.dart';
import 'package:habit_tracker/widgets/theme_controller.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:habit_tracker/widgets/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const FadeSlideTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: child,
    );
  }
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  Future<void> _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
    setState(() => _isDarkMode = isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF8A05BE),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF8A05BE),
          secondary: Color(0xFF8A05BE),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8A05BE),
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF00FFC6),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFC6),
          secondary: Color(0xFF00FFC6),
          surface: Colors.black,
          onPrimary: Colors.black,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00FFC6),
          foregroundColor: Colors.black,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HabitHomePage(onThemeToggle: _toggleTheme),
    );
  }
}

class HabitHomePage extends StatefulWidget {
  final Future<void> Function(bool) onThemeToggle;
  const HabitHomePage({super.key, required this.onThemeToggle});

  @override
  State<HabitHomePage> createState() => _HabitHomePageState();
}

class _HabitHomePageState extends State<HabitHomePage> {
  List<Map<String, dynamic>> _habits = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('habits');
    if (data != null) {
      setState(() {
        _habits = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('habits', jsonEncode(_habits));
  }

  Future<void> _addHabit() async {
    final newHabit = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const HabitFormPage()),
    );

    if (newHabit != null) {
      setState(() {
        _habits.add({
          ...newHabit,
          'isDone': false,
          'lastCompletedAt': DateTime.now().toIso8601String(),
        });
      });
      await _saveHabits();
    }
  }

  Future<void> _editHabit(int index) async {
    final updatedHabit = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => HabitFormPage(
              habit: _habits[index].map(
                (key, value) => MapEntry(key, value.toString()),
              ),
            ),
      ),
    );

    if (updatedHabit != null) {
      setState(() {
        _habits[index] = {
          ...updatedHabit,
          'isDone': false,
          'lastCompletedAt': DateTime.now().toIso8601String(),
        };
      });
      await _saveHabits();
    }
  }

  void _toggleHabitDone(int index) async {
    setState(() {
      _habits[index]['isDone'] = !_habits[index]['isDone'];
      _habits[index]['lastCompletedAt'] = DateTime.now().toIso8601String();
    });
    await _saveHabits();
  }

  void _deleteHabit(int index) async {
    setState(() => _habits.removeAt(index));
    await _saveHabits();
  }

  void _openSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final darkModeBefore = prefs.getBool('darkMode') ?? false;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => SettingsPage(
              onThemeChanged: (isDark) => widget.onThemeToggle(isDark),
            ),
      ),
    );
    final darkModeAfter = prefs.getBool('darkMode') ?? false;
    if (darkModeBefore != darkModeAfter) {
      await widget.onThemeToggle(darkModeAfter);
    }
  }

  Widget _buildStatsPage() {
    final doneCount = _habits.where((h) => h['isDone'] == true).length;
    final totalCount = _habits.length;
    final remainingCount = totalCount - doneCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedPercent =
        totalCount > 0 ? ((doneCount / totalCount) * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FadeSlideTransition(
        key: ValueKey(_habits.length), // troca quando mudar
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Progresso Geral',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            startDegreeOffset: -90,
                            sections: [
                              PieChartSectionData(
                                color: const Color(0xFF00E676),
                                value: doneCount.toDouble(),
                                radius: 60,
                                title: '',
                              ),
                              PieChartSectionData(
                                color: const Color(0xFFFF5252),
                                value: remainingCount.toDouble(),
                                radius: 60,
                                title: '',
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '$completedPercent%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Completado',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        color: const Color(0xFF00E676),
                        text: '$doneCount Feitos',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 24),
                      _buildLegendItem(
                        color: const Color(0xFFFF5252),
                        text: '$remainingCount Restantes',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Hábitos'), centerTitle: true),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child:
            _selectedIndex == 0
                ? _habits.isEmpty
                    ? const Center(child: Text('Nenhum hábito adicionado.'))
                    : ListView.builder(
                      key: const ValueKey('habits'),
                      padding: const EdgeInsets.all(16),
                      itemCount: _habits.length,
                      itemBuilder: (context, index) {
                        final habit = _habits[index];
                        final isDone = habit['isDone'] == true;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Card(
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Checkbox(
                                value: isDone,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                onChanged: (_) => _toggleHabitDone(index),
                              ),
                              title: Text(
                                habit['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration:
                                      isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                ),
                              ),
                              subtitle: Text(habit['description']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    onPressed: () => _editHabit(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () => _deleteHabit(index),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                : _selectedIndex == 1
                ? _buildStatsPage()
                : _selectedIndex == 2
                ? Dashboard(habits: _habits)
                : SettingsPage(
                  onThemeChanged: (isDark) => widget.onThemeToggle(isDark),
                ),
      ),

      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: _addHabit,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: const Icon(Icons.add),
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Hábitos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}
