import 'package:coaching_client/firebase_options.dart';

import 'package:coaching_client/pages/authentication/authentication.dart';
import 'package:coaching_client/providers/auth_provider.dart';
import 'package:coaching_client/providers/meeting_provider.dart';
import 'package:coaching_client/providers/notification_provider.dart';

import 'package:coaching_client/providers/task_provider.dart';
import 'package:coaching_client/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Define your providers here
        ChangeNotifierProvider(create: (_) => AuthManager()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => MeetingProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(NotificationService()),
        ),
      ],
      child: MaterialApp(
        title: 'Lifestyle Coach',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
          useMaterial3: true,
        ),
        home: const AuthenticationPage(),
      ),
    );
  }
}
