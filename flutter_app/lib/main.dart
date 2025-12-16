import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/auth_screens/view/login_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



void main() async { // async yap
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ToAiDo', // Uygulamanın adı
      debugShowCheckedModeBanner: false, // Sağ üstteki "Debug" bandını kaldırır

      // Tema Ayarları
      theme: ThemeData(
        useMaterial3: true, // Flutter'ın en yeni tasarım sistemi
        primaryColor: const Color(0xFF1E3C72), // Login ekranındaki koyu mavi
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3C72),
          primary: const Color(0xFF1E3C72),
          secondary: const Color(0xFF2A5298),
        ),
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // Uygulama ilk açıldığında hangi ekran gelsin?
      home: LoginView(),
    );
  }
}