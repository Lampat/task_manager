import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("heeeyeyryeyeyey"),
            Consumer(builder: (_, ref, __) {
              return TextButton(
                onPressed: () async {
                  final auth = ref.read(authControllerProvider);
                  await auth.signOut();
                },
                child: const Text('Log out'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
