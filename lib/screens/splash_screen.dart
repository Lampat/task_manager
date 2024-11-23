import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/screens/auth_screen.dart';
import 'package:task_manager/screens/home_screen.dart';
import '../providers/auth_provider.dart';

class SpalshScreen extends ConsumerWidget {
  const SpalshScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) {
        if (user != null) {
          // User is already singed in
          return const HomeScreen();
        } else {
          // User is not signed in
          return const AuthScreen();
        }
      },
      error: (error, stack) {
        return const Center(
          child: Column(
            children: [
              Text('Something went wrong, please try again'),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
