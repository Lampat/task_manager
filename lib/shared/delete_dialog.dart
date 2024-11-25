import 'package:flutter/material.dart';

// A custom dialog to appear when deleting a task
Future<bool> deleteDialog(BuildContext context, String taskTitle) async {
  return await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black38,
        barrierLabel: "",
        transitionDuration: const Duration(milliseconds: 400),
        transitionBuilder: (context, a1, a2, child) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: a1,
              curve: Curves.elasticOut,
              reverseCurve: Curves.easeOutCubic,
            ),
            child: AlertDialog(
              title: const Text('Confirm'),
              content: Text(
                  'Are you sure you want to delete the task:\n"$taskTitle" ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return const SizedBox();
        },
      ) ??
      false;
}
