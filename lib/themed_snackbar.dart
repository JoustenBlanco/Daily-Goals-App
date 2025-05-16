import 'package:flutter/material.dart';

void showThemedSnackBar(BuildContext context, String message, bool isDark) {
  final theme = Theme.of(context);
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
