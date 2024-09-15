import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/screens/add_edit_task_screen.dart';
import 'package:todo_list/widgets/task_search_delegate.dart';
import '../models/task.dart'; // Adjust this import based on your file structure

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Box<Task> _taskBox;
  List<Task> _tasks = [];
  String _searchQuery = '';
  String _sortBy = 'Priority';

  @override
  void initState() {
    super.initState();
    _taskBox = Hive.box<Task>('tasks');
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = _taskBox.values.toList();
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      List<Task> filteredTasks = _taskBox.values.toList();

      if (_searchQuery.isNotEmpty) {
        filteredTasks = filteredTasks
            .where((task) =>
                task.title.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }

      switch (_sortBy) {
        case 'Due Date':
          filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          break;
        case 'Creation Date':
          filteredTasks.sort(
              (a, b) => a.key.compareTo(b.key)); // Assumes key is creation date
          break;
        default:
          filteredTasks.sort((a, b) => a.priority.compareTo(b.priority));
          break;
      }

      _tasks = filteredTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(
                  onSearch: (query) {
                    // Use WidgetsBinding to ensure update happens after build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _searchQuery = query;
                        _applyFilters();
                      });
                    });
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Sort By'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('Priority'),
                          onTap: () {
                            setState(() {
                              _sortBy = 'Priority';
                              _applyFilters();
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text('Due Date'),
                          onTap: () {
                            setState(() {
                              _sortBy = 'Due Date';
                              _applyFilters();
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text('Creation Date'),
                          onTap: () {
                            setState(() {
                              _sortBy = 'Creation Date';
                              _applyFilters();
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Dismissible(
            key: Key(task.key.toString()), // Ensure task.key is unique
            background: Container(color: Colors.red),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              // Remove the task from the box
              _taskBox.delete(task.key);
              // Update the UI
              setState(() {
                _tasks.removeAt(index);
              });
              // Optionally, show a snackbar or other feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task deleted'),
                ),
              );
            },
            child: ListTile(
              title: Text(task.title),
              subtitle: Text(
                  '${task.description}\nDue: ${DateFormat.yMMMd().format(task.dueDate)}'),
              trailing: Text('Priority: ${task.priority}'),
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => AddEditTaskScreen(task: task),
                      ),
                    )
                    .then((_) => _loadTasks());
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => AddEditTaskScreen(),
                ),
              )
              .then((_) => _loadTasks());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
