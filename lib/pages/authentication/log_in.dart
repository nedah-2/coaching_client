import 'package:coaching_client/providers/auth_provider.dart';
import 'package:coaching_client/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context, listen: true);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                opacity: 0.3,
                image: AssetImage('assets/images/backgroud.jpg'))),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to Our Campus',
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Please log in to your account',
                style: TextStyle(fontSize: 16.0, color: Colors.blue.shade900),
              ),
              const SizedBox(height: 32.0),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(14),
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(14),
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onFieldSubmitted: (value) {
                  _submitForm(authManager);
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue.shade900,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size.fromHeight(40),
                  padding: const EdgeInsets.all(14),
                ),
                onPressed: authManager.isLoading
                    ? null
                    : () async {
                        _submitForm(authManager);
                      },
                child: authManager.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator())
                    : const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(AuthManager authManager) async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      // Form is valid, perform sign-in
      try {
        await authManager.signInWithEmailAndPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
      } catch (e) {
        if (mounted) showSnackBar(context, 'Sign in failed. Please try again.');
        emailController.clear();
        passwordController.clear();
      }
    }
  }
}
