import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_list/widgets/themeProvider.dart';

void showThemedSnackBar(BuildContext context, String message) {
  final theme = Theme.of(context);
  final isDark = context.read<ThemeProvider>().isDarkMode;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: isDark
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onPrimary,
        ),
      ),
      backgroundColor: isDark
          ? theme.colorScheme.surface
          : theme.colorScheme.primary,
    ),
  );
}
