import 'package:flutter/material.dart';
import 'dataBaseHelper.dart';
import 'tarea.dart';
import 'settings.dart';
import 'themed_snackbar.dart'; // <-- Importa el nuevo archivo

class Task {
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});
}

class TaskListPage extends StatefulWidget {
  final bool isDarkMode;
  final bool isAutoDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onAutoThemeChanged;
  final Future<void> Function() onOpenSettings;

  const TaskListPage({
    Key? key,
    required this.isDarkMode,
    required this.isAutoDarkMode,
    required this.onThemeChanged,
    required this.onAutoThemeChanged,
    required this.onOpenSettings,
  }) : super(key: key);

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Tarea> tasks = [];
  String searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  late bool isDark;
  late bool isAutoDark;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    isDark = widget.isDarkMode;
    isAutoDark = widget.isAutoDarkMode;
  }

  @override
  void didUpdateWidget(covariant TaskListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isDark != widget.isDarkMode || isAutoDark != widget.isAutoDarkMode) {
      setState(() {
        isDark = widget.isDarkMode;
        isAutoDark = widget.isAutoDarkMode;
      });
    }
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await DataBaseHelper().getTareas();
    setState(() {
      tasks = loadedTasks;
    });
  }

  Future<void> addTask(String title) async {
    final tarea = Tarea(nombre: title, completada: 0);
    await DataBaseHelper().insertTarea(tarea);
    await _loadTasks();
  }

  Future<void> toggleTask(Tarea tarea) async {
    tarea.completada = tarea.completada == 1 ? 0 : 1;
    await DataBaseHelper().updateTarea(tarea);
    await _loadTasks();
  }

  Future<void> deleteTask(Tarea tarea) async {
    await DataBaseHelper().deleteTarea(tarea.id!);
    await _loadTasks();
  }

  Future<void> editTask(Tarea tarea, String newTitle) async {
    tarea.nombre = newTitle;
    await DataBaseHelper().updateTarea(tarea);
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<Tarea> filteredTasks =
        tasks.where((task) {
          return task.nombre.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

    List<Tarea> pendingTasks =
        filteredTasks.where((task) => task.completada == 0).toList();
    List<Tarea> completedTasks =
        filteredTasks.where((task) => task.completada == 1).toList();

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
          builder: (context) => Settings(
            isDarkMode: isDark,
            isAutoDarkMode: isAutoDark,
            onThemeChanged: (value) {
              setState(() {
            isDark = value;
              });
              widget.onThemeChanged(value);
            },
            onAutoThemeChanged: (value) {
              setState(() {
            isAutoDark = value;
              });
              widget.onAutoThemeChanged(value);
            },
          ),
            ),
          );
          setState(() {
            isDark = widget.isDarkMode;
            isAutoDark = widget.isAutoDarkMode;
          });
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

  Widget buildTaskItem(Tarea tarea, bool isCompleted, ThemeData theme, bool isDark) {
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
          value: tarea.completada == 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          activeColor: theme.colorScheme.secondary,
          checkColor: Colors.white,
          onChanged: (value) {
            toggleTask(tarea);
          },
        ),
        title: GestureDetector(
          onLongPress: () => showEditTaskDialog(tarea),
          child: Text(
            tarea.nombre,
            style: TextStyle(
              fontSize: 16,
              decoration: tarea.completada == 1 ? TextDecoration.lineThrough : null,
              color: tarea.completada == 1
                  ? theme.disabledColor
                  : theme.colorScheme.onSurface,
              fontWeight: tarea.completada == 1 ? FontWeight.normal : FontWeight.w600,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: theme.colorScheme.primary),
              tooltip: 'Editar',
              onPressed: () => showEditTaskDialog(tarea),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.secondary),
              tooltip: 'Eliminar',
              onPressed: () => _confirmDeleteTask(tarea),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTask(Tarea tarea) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar tarea'),
        content: Text('¿Deseas eliminar la tarea "${tarea.nombre}"?'),
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
      await deleteTask(tarea);
      showThemedSnackBar(
        context,
        'Tarea eliminada.',
        isDark,
      );
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
              await addTask(value);
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
                await addTask(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void showEditTaskDialog(Tarea tarea) {
    final controller = TextEditingController(text: tarea.nombre);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Tarea'),
        content: TextField(
          autofocus: true,
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nuevo título'),
          onSubmitted: (value) async {
            if (value.isNotEmpty && value != tarea.nombre) {
              await editTask(tarea, value);
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
              if (controller.text.isNotEmpty && controller.text != tarea.nombre) {
                await editTask(tarea, controller.text);
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
    final completedCount = tasks.where((task) => task.completada == 1).length;
    if (completedCount == 0) {
      showThemedSnackBar(
        context,
        'No hay tareas completadas para eliminar.',
        isDark,
      );
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
      for (var tarea in tasks.where((t) => t.completada == 1).toList()) {
        await DataBaseHelper().deleteTarea(tarea.id!);
      }
      await _loadTasks();
      showThemedSnackBar(
        context,
        'Tareas completadas eliminadas.',
        isDark,
      );
    }
  }

  void _completeAllPendingTasks() async {
    final pending = tasks.where((task) => task.completada == 0).toList();
    if (pending.isEmpty) {
      showThemedSnackBar(
        context,
        'No hay tareas pendientes para completar.',
        isDark,
      );
      return;
    }
    for (var tarea in pending) {
      tarea.completada = 1;
      await DataBaseHelper().updateTarea(tarea);
    }
    await _loadTasks();
    showThemedSnackBar(
      context,
      '¡Todas las tareas marcadas como completadas!',
      isDark,
    );
  }
}
