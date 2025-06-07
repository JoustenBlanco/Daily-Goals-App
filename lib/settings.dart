import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasks_list/login.dart';
import 'package:tasks_list/widgets/taskProvider.dart';
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
      context.read<AuthProvider>().logout();
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
    final authProvider = context.watch<AuthProvider>();
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final isAutoDarkMode = context.watch<ThemeProvider>().isAutoDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Modo oscuro automático (6pm a 6am)'),
                  value: isAutoDarkMode,
                  onChanged: (bool value) {
                    context.read<ThemeProvider>().toggleAutoDarkMode(value);
                  },
                  secondary: const Icon(Icons.brightness_auto),
                ),
                SwitchListTile(
                  title: const Text('Tema oscuro'),
                  value: isDarkMode,
                  onChanged: isAutoDarkMode
                      ? null
                      : (bool value) { context.read<ThemeProvider>().toggleDarkMode(value); },
                  secondary: const Icon(Icons.dark_mode),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sesiones guardadas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...authProvider.savedSessions.map((sessionString) {
            Map<String, dynamic> sessionData = jsonDecode(sessionString);

            final userId = sessionData['user']?['id'] ?? 'Usuario desconocido';
            final email = sessionData['user']?['email'] ?? 'Sin email';

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.account_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  email,
                  style: TextStyle(
                    fontWeight: authProvider.userId == userId ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: authProvider.userId == userId
                    ? const Text('Sesión actual', style: TextStyle(color: Colors.green))
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (authProvider.userId == userId)
                      const Icon(Icons.check_circle, color: Colors.green),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Eliminar sesión',
                      onPressed: () async {
                        await authProvider.deleteSession(sessionString);
                        setState(() {}); // Refresca la lista
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sesión eliminada')),
                        );
                        if (authProvider.savedSessions.isEmpty) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
                onTap: () async {
                  try {
                    if (!await authProvider.switchToSession(sessionString)){
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sesión cambiada'))
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al cambiar sesión: $e'))
                    );
                  }
                },
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: const Text('Iniciar nueva sesión'),
              leading: const Icon(Icons.add),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: const Text('Cerrar sesión'),
              leading: const Icon(Icons.logout),
              onTap: () => _signOut(context),
            ),
          ),
        ],
      ),
    );
  }
}
