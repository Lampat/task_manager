import 'package:flutter/material.dart';

Future<bool> deleteDialog(BuildContext context, String taskTitle) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm'),
            content: Text('Are you sure you want to delete $taskTitle?'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // User pressed Cancel
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // User pressed Confirm
                child: const Text('Delete'),
              ),
            ],
          );
        },
      ) ??
      false;
}
