import 'package:coaching_client/home.dart';
import 'package:coaching_client/pages/authentication/log_in.dart';
import 'package:coaching_client/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthManager>(context, listen: false).setPreloadContext(context);
    return Consumer<AuthManager>(
      builder: (context, authProvider, _) {
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (authProvider.user == null || !authProvider.isStudent) {
          return const LoginPage();
        } else {
          return HomePage(
            uid: authProvider.user!.uid,
          );
        }
      },
    );
  }
}
