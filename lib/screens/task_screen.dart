import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/globals.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/providers/auth_provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/services/notification_service.dart';
import 'package:task_manager/shared/date_format.dart';
import 'package:task_manager/shared/delete_dialog.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskCategory _selectedCategory;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDateTime;
  DateTime? _reminderDateTime;
  DateTime? _shouldEditDatetime;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize values with already created if we are editing or the default if we are creating the task
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _selectedCategory = widget.task?.category ?? TaskCategory.work;
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedDateTime = widget.task?.dueDate;
    _reminderDateTime = widget.task?.reminderTime;
    _shouldEditDatetime = widget.task?.reminderTime;
  }

  @override
  void dispose() {
    // dispose the controllers
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Function to pick date and time
  Future<DateTime?> _pickDateTime(
      BuildContext context, DateTime? alreadySelected) async {
    DateTime? dateTimePick = alreadySelected;
    final date = await showDatePicker(
      context: context,
      initialDate: dateTimePick ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(dateTimePick ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          dateTimePick = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }

    return dateTimePick;
  }

  // save the task > submiting the form
  Future<void> _saveTask(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateTime == null) {
      snackbarKey.currentState
          ?.showSnackBar(globalSnackBar("Please select a date to continue"));

      return;
    }

    final userId = ref.read(getUserIdProvider);
    if (userId == null) {
      snackbarKey.currentState
          ?.showSnackBar(globalSnackBar("User is not logged in"));

      return;
    }

    final newTask = Task(
      id: widget.task?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text,
      category: _selectedCategory,
      priority: _selectedPriority,
      dueDate: _selectedDateTime!,
      reminderTime: _reminderDateTime,
    );

    final taskRepo = ref.read(taskServiceProvider);
    if (widget.task == null) {
      taskRepo.createTask(userId, newTask);
      if (_reminderDateTime != null) {
        await NotificationService().scheduleNotification(newTask);
      }
    } else {
      taskRepo.updateTask(userId, newTask);
      if (_reminderDateTime != null &&
          _reminderDateTime != _shouldEditDatetime) {
        await NotificationService().cancelNotification(newTask.id);
        await NotificationService().scheduleNotification(newTask);
      }
    }

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.deepPurple[300],
              onPressed: () async {
                final userId = ref.read(getUserIdProvider);
                if (userId != null) {
                  final confirmDelete =
                      await deleteDialog(context, widget.task?.title ?? "");
                  if (confirmDelete) {
                    ref
                        .read(taskServiceProvider)
                        .deleteTask(userId, widget.task!.id);

                    if (widget.task?.reminderTime != null) {
                      await NotificationService()
                          .cancelNotification(widget.task!.id);
                    }
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please add a title";
                    }
                    if (value.length < 6) {
                      return "Add more than 6 characters to title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: TaskCategory.values.map((category) {
                    return DropdownMenuItem<TaskCategory>(
                      value: category,
                      child: Text(category.name[0].toUpperCase() +
                          category.name.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskPriority>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: TaskPriority.values.map((priority) {
                    return DropdownMenuItem<TaskPriority>(
                      value: priority,
                      child: Text(priority.name[0].toUpperCase() +
                          priority.name.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final res =
                            await _pickDateTime(context, _selectedDateTime);

                        if (res != null) {
                          setState(() {
                            _selectedDateTime = res;
                          });
                        }
                      },
                      child: const Text(
                        'Pick Date & Time',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Text(
                      _selectedDateTime != null
                          ? formatIsoToReadableDate(
                              _selectedDateTime!.toLocal().toIso8601String())
                          : 'No Date Selected',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final res =
                            await _pickDateTime(context, _reminderDateTime);

                        if (res != null) {
                          setState(() {
                            _reminderDateTime = res;
                          });
                        }
                      },
                      child: const Text(
                        'Pick Reminder Time',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Text(_reminderDateTime != null
                        ? formatIsoToReadableDate(
                            _reminderDateTime!.toLocal().toIso8601String())
                        : 'No date selected'),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _saveTask(context),
                  child: Text(widget.task == null ? 'Add Task' : 'Save Task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
