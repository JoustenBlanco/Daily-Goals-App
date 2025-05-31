import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasks_list/widgets/themeProvider.dart';
import 'package:tasks_list/widgets/authProvider.dart';
import 'package:tasks_list/widgets/taskProvider.dart';
import 'package:tasks_list/task_list_page.dart';
import 'package:tasks_list/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://qypqofmhbfwqduecblfv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5cHFvZm1oYmZ3cWR1ZWNibGZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI4NjIwNTIsImV4cCI6MjA1ODQzODA1Mn0.WF3oSkSl5FjyuMdM0uLCqX70VckO5mbAxdmz-s8nkRY',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainState();
}

class _MainState extends State<MainApp> {
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    context.read<ThemeProvider>().loadPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    }); 
  }

  Future<void> _checkSession() async {
    context.read<AuthProvider>().checkAuthentication();
    setState(() {
      _isCheckingSession = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final _isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    
    if (_isCheckingSession) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Lista de Tareas',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
              useMaterial3: true,
              colorScheme: ColorScheme(
                brightness: Brightness.dark,
                primary: Color(0xFF2196F3),
                onPrimary: Colors.white,
                secondary: Color(0xFF4CAF50),
                onSecondary: Colors.white,
                error: Color(0xFFFF5252),
                onError: Colors.white,
                background: Color(0xFF181C20),
                onBackground: Colors.white,
                surface: Color(0xFF23272F),
                onSurface: Colors.white,
              ),
              scaffoldBackgroundColor: Color(0xFF181C20),
              appBarTheme: AppBarTheme(
                backgroundColor: Color(0xFF23272F),
                foregroundColor: Colors.white,
              ),
            )
          : ThemeData.light().copyWith(
              useMaterial3: true,
              colorScheme: ColorScheme(
                brightness: Brightness.light,
                primary: Color(0xFF1976D2),
                onPrimary: Colors.white,
                secondary: Color(0xFF43A047),
                onSecondary: Colors.white,
                error: Color(0xFFD32F2F),
                onError: Colors.white,
                background: Color(0xFFF5F7FA),
                onBackground: Color(0xFF23272F),
                surface: Colors.white,
                onSurface: Color(0xFF23272F),
              ),
              scaffoldBackgroundColor: Color(0xFFF5F7FA),
              appBarTheme: AppBarTheme(
                backgroundColor: Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
            ),
      home: _isAuthenticated ? TaskListPage() : LoginPage(),
    );
  }
}      

