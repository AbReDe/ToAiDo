import 'package:flutter/material.dart';
import 'package:toaido_flutter/presentation/screens/login/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme data ayrları gelcek
      //65ms/px sınırı aşmamak icin performans optimizasyon bench uygulama eklenecek
      home: LoginScreen(),
    );
  }
}
