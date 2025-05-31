import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks_list/widgets/themed_snackbar.dart';
import 'package:tasks_list/service/dataBaseHelper.dart';
import 'package:tasks_list/widgets/themeProvider.dart';
import 'package:tasks_list/widgets/taskProvider.dart';
import 'package:tasks_list/models/task.dart';
import 'package:tasks_list/settings.dart';

class TaskListPage extends StatefulWidget {

  const TaskListPage({ Key? key }) : super(key: key);

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<TaskProvider>().loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final tasks = context.watch<TaskProvider>().tasks;

    List<Task> filteredTasks =
        tasks.where((task) {
          return task.name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

    List<Task> pendingTasks =
        filteredTasks.where((task) => task.complete == 0).toList();
    List<Task> completedTasks =
        filteredTasks.where((task) => task.complete == 1).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark
            ? theme.colorScheme.surface.withOpacity(0.95)
            : theme.colorScheme.primary,
        title: Row(
          children: [
        Container(
          decoration: BoxDecoration(
            color: isDark
            ? theme.colorScheme.primary
            : theme.colorScheme.onPrimary,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.list_alt_rounded,
            color: isDark
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Tareas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onPrimary,
            letterSpacing: 1.2,
            shadows: [
          Shadow(
            color: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
            ],
          ),
        ),
          ],
        ),
        actions: [
          IconButton(
        icon: Icon(
          Icons.settings,
          color: isDark
          ? theme.colorScheme.secondary
          : theme.colorScheme.onPrimary,
          size: 28,
          shadows: [
            Shadow(
          color: isDark
              ? Colors.black.withOpacity(0.4)
              : Colors.white.withOpacity(0.3),
          blurRadius: 3,
          offset: const Offset(1, 1),
            ),
          ],
        ),
        tooltip: 'Configuración',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
          builder: (context) => Settings(),
            ),
          );
        },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(24),
              color: isDark
                  ? theme.colorScheme.onSurface.withOpacity(0.12)
                  : Colors.white,
              child: TextField(
                focusNode: _searchFocusNode,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? theme.colorScheme.onSurface.withOpacity(0.12)
                      : Colors.white,
                  hintText: 'Buscar...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.primary.withOpacity(0.7),
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 0,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pendingTasks.isNotEmpty) ...[
            Text(
              'Pendientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            ...pendingTasks.map((task) => buildTaskItem(task, false, theme, isDark)),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  '¡No tienes tareas pendientes!',
                  style: TextStyle(
                    color: theme.disabledColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          ExpansionTile(
            initiallyExpanded: false,
            tilePadding: EdgeInsets.zero,
            title: Row(
              children: [
                Icon(Icons.check_circle, color: theme.colorScheme.secondary, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Completadas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                if (completedTasks.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? theme.colorScheme.surfaceVariant : Color(0xFFE1F5FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      completedTasks.length.toString(),
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            children: completedTasks.isNotEmpty
                ? completedTasks
                    .map((task) => buildTaskItem(task, true, theme, isDark))
                    .toList()
                : [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'No hay tareas completadas.',
                        style: TextStyle(
                          color: theme.disabledColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
          ),
          const SizedBox(height: 60),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: theme.colorScheme.surface,
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.delete_outline_outlined, color: theme.iconTheme.color),
                tooltip: 'Eliminar completadas',
                onPressed: _deleteCompletedTasks,
              ),
              IconButton(
                icon: Icon(Icons.done_all, color: theme.iconTheme.color),
                tooltip: 'Completar todas',
                onPressed: _completeAllPendingTasks,
              ),
              Spacer(),
              FloatingActionButton(
                onPressed: showAddTaskDialog,
                elevation: 0,
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.add),
                mini: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTaskItem(Task task, bool isCompleted, ThemeData theme, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isCompleted
            ? Border.all(color: theme.colorScheme.secondary.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.complete == 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          activeColor: theme.colorScheme.secondary,
          checkColor: Colors.white,
          onChanged: (value) {
            context.read<TaskProvider>().toggleTask(task);
          },
        ),
        title: GestureDetector(
          onLongPress: () => showEditTaskDialog(task),
          child: Text(
            task.name,
            style: TextStyle(
              fontSize: 16,
              decoration: task.complete == 1 ? TextDecoration.lineThrough : null,
              color: task.complete == 1
                  ? theme.disabledColor
                  : theme.colorScheme.onSurface,
              fontWeight: task.complete == 1 ? FontWeight.normal : FontWeight.w600,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: theme.colorScheme.primary),
              tooltip: 'Editar',
              onPressed: () => showEditTaskDialog(task),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.secondary),
              tooltip: 'Eliminar',
              onPressed: () => _confirmDeleteTask(task),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar task'),
        content: Text('¿Deseas eliminar la tarea "${task.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<TaskProvider>().deleteTask(task);
      showThemedSnackBar(context, 'Tarea eliminada.');
    }
  }

  void showAddTaskDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Tarea'),
        content: TextField(
          autofocus: true,
          controller: controller,
          decoration: const InputDecoration(hintText: 'Título de la tarea'),
          onSubmitted: (value) async {
            if (value.isNotEmpty) {
              await context.read<TaskProvider>().addTask(value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await context.read<TaskProvider>().addTask(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void showEditTaskDialog(Task task) {
    final controller = TextEditingController(text: task.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Tarea'),
        content: TextField(
          autofocus: true,
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nuevo título'),
          onSubmitted: (value) async {
            if (value.isNotEmpty && value != task.name) {
              await context.read<TaskProvider>().editTask(task, value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty && controller.text != task.name) {
                await context.read<TaskProvider>().editTask(task, controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // --- Funcionalidades de la botomppBar ---

  void _deleteCompletedTasks() async {
    final completedCount = context.read<TaskProvider>().tasks.where((task) => task.complete == 1).length;
    if (completedCount == 0) {
      showThemedSnackBar(context, 'No hay tareas completadas para eliminar.');
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Eliminar tareas completadas'),
            content: Text('¿Deseas eliminar todas las tareas completadas?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Eliminar'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      for (var task in context.read<TaskProvider>().tasks.where((t) => t.complete == 1).toList()) {
        await DataBaseHelper().deleteTask(task.id!);
      }
      await context.read<TaskProvider>().loadTasks();
      showThemedSnackBar(context, 'Tareas completadas eliminadas.');
    }
  }

  void _completeAllPendingTasks() async {
    final pending = context.read<TaskProvider>().tasks.where((task) => task.complete == 0).toList();
    if (pending.isEmpty) {
      showThemedSnackBar(context, 'No hay tareas pendientes para completar.');
      return;
    }
    for (var task in pending) {
      task.complete = 1;
      await DataBaseHelper().updateTask(task);
    }
    await context.read<TaskProvider>().loadTasks();
    showThemedSnackBar(context, '¡Todas las tareas marcadas como completadas!');
  }
}
