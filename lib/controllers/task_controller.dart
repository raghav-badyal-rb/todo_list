import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskController extends GetxController {
  final Box<Task> taskBox = Hive.box<Task>('tasks');

  void addTask(Task task) {
    taskBox.add(task);
    update();
  }

  void editTask(int index, Task task) {
    taskBox.putAt(index, task);
    update();
  }

  void deleteTask(int index) {
    taskBox.deleteAt(index);
    update();
  }
}
