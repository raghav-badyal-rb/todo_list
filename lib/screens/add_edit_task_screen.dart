import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/task.dart'; // Adjust this import based on your file structure
import '../main.dart'; // Adjust this import based on your file structure

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  AddEditTaskScreen({this.task});

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  int _priority = 1;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _priority = widget.task!.priority;
    }
  }

  void _saveTask() async {
    final taskBox = Hive.box<Task>('tasks');

    final newTask = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate!,
      priority: _priority,
    );

    if (widget.task == null) {
      // Adding a new task
      final taskKey = await taskBox.add(newTask); // Hive automatically assigns a key
    } else {
      // Updating an existing task
      final updatedTask = widget.task!
        ..title = _titleController.text
        ..description = _descriptionController.text
        ..dueDate = _dueDate!
        ..priority = _priority;
      await updatedTask.save(); // Save the updated task
    }

    if (_dueDate != null) {
      scheduleNotification(newTask);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Due Date'),
              readOnly: true,
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dueDate = pickedDate;
                  });
                }
              },
              controller: TextEditingController(text: _dueDate != null ? DateFormat.yMMMd().format(_dueDate!) : ''),
            ),
            DropdownButton<int>(
              value: _priority,
              onChanged: (int? newValue) {
                setState(() {
                  _priority = newValue!;
                });
              },
              items: List.generate(5, (index) => index + 1)
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text('Priority $priority'),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(widget.task == null ? 'Add Task' : 'Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
