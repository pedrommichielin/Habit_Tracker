import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/widgets/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  final void Function(bool) onThemeChanged;

  const SettingsPage({super.key, required this.onThemeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _saveNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
  }

  void _onDarkModeChanged(bool value) {
    setState(() => _darkModeEnabled = value);
    widget.onThemeChanged(value); //calback muda o tema
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notificações'),
            subtitle: const Text('Ativar ou desativar notificações'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveNotificationSetting();
            },
          ),
          SwitchListTile(
            title: const Text('Modo Escuro'),
            subtitle: const Text('Ativar tema escuro'),
            value: _darkModeEnabled,
            onChanged: _onDarkModeChanged,
          ),
        ],
      ),
    );
  }
}
