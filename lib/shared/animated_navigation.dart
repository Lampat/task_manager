import 'package:flutter/material.dart';

// A custom animation for animating the route from one screen to another
Route createAnimatedRoute(Widget pageToRoute) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => pageToRoute,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        // opacity: animation,
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        ),
      );
    },
  );
}
