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
      context.read<AuthProvider>().checkAuthentication();
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
          ...authProvider.savedSessions.map((sessionString) {
            Map<String, dynamic> sessionData = jsonDecode(sessionString);

            final userId = sessionData['user']?['id'] ?? 'Usuario desconocido';
            final email = sessionData['user']?['email'] ?? 'Sin email';

            return ListTile(
              title: Text(email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (authProvider.userId == userId) const Icon(Icons.check, color: Colors.green),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      await authProvider.deleteSession(sessionString);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sesión eliminada')),
                      );
                    },
                  ),
                ]
              ),
              onTap: () async {
                try {
                  await authProvider.switchToSession(sessionString);
                  Map<String, dynamic> sessionData = jsonDecode(sessionString);
                  final userId = sessionData['user']?['id'];
                  if (userId != null){
                    context.read<TaskProvider>().setUser(userId!);
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
            );
          }).toList(),
          const Divider(),
          ListTile(
            title: const Text('Iniciar nueva sesión'),
            leading: const Icon(Icons.add),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
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
