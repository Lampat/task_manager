import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

SnackBar globalSnackBar(String message) => SnackBar(
      content: Text(message),
      elevation: 10,
      behavior: SnackBarBehavior.floating,
    );


// use the snackbar anywhere like this:
// snackbarKey.currentState?.showSnackBar(globalSnackBar("....")); 