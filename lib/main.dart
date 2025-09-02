import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/event_log_screen.dart';
import 'screens/map_screen.dart';
import 'services/fcm_service.dart';
import 'services/firestore_service.dart';
import 'services/tflite_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await TFLiteService.instance.loadModel();
  await FCMService.instance.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => TFLiteService.instance),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sound Alert',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.red[900],
          scaffoldBackgroundColor: Colors.black87,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => HomeScreen(),
          '/events': (_) => EventLogScreen(),
          '/map': (_) => MapScreen(),
        },
      ),
    );
  }
}
