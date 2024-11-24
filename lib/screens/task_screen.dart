import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/globals.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/providers/auth_provider.dart';
import 'package:task_manager/providers/task_provider.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _selectedCategory = widget.task?.category ?? TaskCategory.work;
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedDateTime = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveTask(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateTime == null) {
      snackbarKey.currentState
          ?.showSnackBar(globalSnackBar("Please select a date to continue"));

      return;
    }

    // if (_titleController.text.isEmpty || _selectedDateTime == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Title and due date are required.')),
    //   );
    //   return;
    // }

    final userId = ref.read(getUserIdProvider);
    if (userId == null) {
      snackbarKey.currentState
          ?.showSnackBar(globalSnackBar("User is not logged in"));

      return;
    }

    final newTask = Task(
      id: widget.task?.id ??
          '', // Use existing ID if editing, otherwise generate a new one in the repository
      title: _titleController.text.trim(),
      description: _descriptionController.text,
      category: _selectedCategory,
      priority: _selectedPriority,
      dueDate: _selectedDateTime!,
    );

    final taskRepo = ref.read(taskServiceProvider);
    if (widget.task == null) {
      taskRepo.createTask(userId, newTask);
    } else {
      taskRepo.updateTask(userId, newTask);
    }

    Navigator.pop(context);
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
                      onPressed: () => _pickDateTime(context),
                      child: const Text(
                        'Pick Date & Time',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Text(
                      _selectedDateTime != null
                          ? formatIsoToReadableDate(
                              _selectedDateTime!.toLocal().toIso8601String())
                          // ? '${_selectedDateTime!.toLocal()}'.split('.')[0]
                          : 'No Date Selected',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                // const Spacer(),
                const SizedBox(height: 40),
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
