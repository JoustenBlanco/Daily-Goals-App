import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasks_list/login.dart';
import 'package:tasks_list/widgets/themeProvider.dart';
import 'package:tasks_list/widgets/authProvider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      context.read<AuthProvider>().setAuthentication(false,null);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final isAutoDarkMode = context.watch<ThemeProvider>().isAutoDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo oscuro automático (6pm a 6am)'),
            value: isAutoDarkMode,
            onChanged: (bool value) {
              context.read<ThemeProvider>().toggleAutoDarkMode(value);
            },
          ),
          SwitchListTile(
            title: const Text('Tema oscuro'),
            value: isDarkMode,
            onChanged: isAutoDarkMode
                ? null
                : (bool value) { context.read<ThemeProvider>().toggleDarkMode(value); },
          ),
          const Divider(),
          ListTile(
            title: const Text('Cerrar sesión'),
            leading: const Icon(Icons.logout),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
