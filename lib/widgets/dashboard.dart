import 'dart:ui';

import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  final List<Map<String, dynamic>> habits;

  const Dashboard({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildSummaryCard(theme, isDark),
          const SizedBox(height: 24),
          _buildRecentHabitsList(context, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, bool isDark) {
    final doneCount = habits.where((h) => h['isDone'] == true).length;
    final total = habits.length;
    final percent = total > 0 ? doneCount / total : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: _glassDecoration(theme),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Progresso Geral', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text('${(percent * 100).toStringAsFixed(1)}% completado', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentHabitsList(BuildContext context, ThemeData theme, bool isDark) {
    final recentHabits = habits.length > 3 ? habits.sublist(habits.length - 3) : habits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hábitos Recentes', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...recentHabits.reversed.map((habit) {
          final progress = habit['isDone'] == true ? 1.0 : 0.0;
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: _glassDecoration(theme),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            habit['name'] ?? '',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          height: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              color: theme.colorScheme.primary,
                              backgroundColor: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  BoxDecoration _glassDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.4),
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
