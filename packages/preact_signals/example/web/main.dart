import 'dart:html';
import 'package:preact_signals/preact_signals.dart';

typedef Task = ({String title, bool completed});

void main() {
  // Application logic
  final todoForm = document.getElementById("todoForm")!;
  final todoInput = document.getElementById("todoInput") as InputElement;
  final todoList = document.getElementById("todoList")!;
  final taskFilter = document.getElementById("taskFilter")!;
  final taskCounter = document.getElementById("taskCounter")!;

  final tasks = signal<List<Task>>([]);
  final filter = signal("all");

  final filteredTasks = computed(() {
    final currentFilter = filter.value;
    final currentTasks = tasks.value;
    if (currentFilter == "all") {
      return currentTasks;
    } else if (currentFilter == "active") {
      return currentTasks.where((task) => !task.completed).toList();
    } else {
      return currentTasks.where((task) => task.completed).toList();
    }
  });

  final taskCount = computed(() {
    return tasks.value.length;
  });

  final activeTaskCount = computed(() {
    return tasks.value.where((task) => !task.completed).length;
  });

  final completedTaskCount = computed(() {
    // we use taskCount.peek() instead of taskCount.value
    // because this will recompute when activeTaskCount changes
    // thus, we can avoid an unnecessary subscription
    return taskCount.peek() - activeTaskCount.value;
  });

  todoForm.addEventListener("submit", (event) {
    event.preventDefault();
    final taskTitle = todoInput.value?.trim();
    if (taskTitle != null) {
      final newTask = (title: taskTitle, completed: false);
      tasks.value = [...tasks.value, newTask];
      todoInput.value = "";
    }
  });

  taskFilter.addEventListener("change", (event) {
    final target = event.target as InputElement;
    filter.value = target.value ?? '';
  });

  effect(() {
    final currentTasks = filteredTasks.value;
    todoList.innerHtml = "";
    for (var index = 0; index < currentTasks.length; index++) {
      final task = currentTasks[index];
      final listItem = document.createElement("li");
      final label = document.createElement("label");
      final checkbox = document.createElement("input") as InputElement;
      checkbox.type = "checkbox";
      checkbox.checked = task.completed;
      checkbox.addEventListener("change", (e) {
        final current = tasks.value;
        current[index] = (
          title: current[index].title,
          completed: checkbox.checked ?? false,
        );
        tasks.value = [...current];
      });
      label.append(checkbox);
      label.append(Text(" ${task.title}"));
      listItem.append(label);
      todoList.append(listItem);
    }
  });

  effect(() {
    taskCounter.text = '''
        Total: ${taskCount.value}, 
        Active: ${activeTaskCount.value}, 
        Completed: ${completedTaskCount.value}
        ''';
  });
}
