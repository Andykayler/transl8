import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_samples/admin.dart';
import 'package:flutter_samples/firebase_options.dart';
import 'package:flutter_samples/samples/ui/rive_app/home.dart';
import 'package:flutter_samples/samples/ui/rive_app/on_boarding/onboarding_view.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  print("object");
 
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialization successful');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TRANSL8',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  OnBoardingView(),
    );
  }
}
