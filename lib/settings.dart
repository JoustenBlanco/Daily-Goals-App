import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  final bool isDarkMode;
  final bool isAutoDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onAutoThemeChanged;

  const Settings({
    Key? key,
    required this.isDarkMode,
    required this.isAutoDarkMode,
    required this.onThemeChanged,
    required this.onAutoThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo oscuro automático (6pm a 6am)'),
            value: isAutoDarkMode,
            onChanged: (bool value) {
              onAutoThemeChanged(value);
            },
          ),
          SwitchListTile(
            title: const Text('Tema oscuro'),
            value: isDarkMode,
            onChanged: isAutoDarkMode
                ? null
                : (bool value) {
                    onThemeChanged(value);
                  },
          ),
        ],
      ),
    );
  }
}