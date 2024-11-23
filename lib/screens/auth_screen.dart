import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:task_manager/globals.dart';
import 'package:task_manager/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  bool _register = false;

  Future<void> _submitSignInUpWithEmailAncPassword() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_register) {
        await ref.read(authServiceProvider).register(email, password);
      } else {
        await ref.read(authServiceProvider).signIn(email, password);
      }

      snackbarKey.currentState
          ?.showSnackBar(globalSnackBar("Authentication successfull"));
    }
  }

  Future<void> _signInUpWithGoogle() async {
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      snackbarKey.currentState?.showSnackBar(globalSnackBar(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Authentication'),
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Task Manager',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _signInUpWithGoogle,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: FaIcon(FontAwesomeIcons.google),
                        ),
                        if (!_register) const Text('Sign in with Google'),
                        if (_register) const Text('Sign up with Google'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('or'),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.remove_red_eye),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_register)
                    TextFormField(
                      controller: _passwordConfirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: Icon(Icons.remove_red_eye),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Password must be the same as above';
                        }
                        return null;
                      },
                    ),
                  if (_register) const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitSignInUpWithEmailAncPassword,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(_register ? 'Create Account' : 'Login'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _register = !_register;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _register
                                ? 'Already have an account? '
                                : 'No account? ',
                            style: const TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: _register ? 'Sign in' : 'Sign up!',
                            style: const TextStyle(color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
