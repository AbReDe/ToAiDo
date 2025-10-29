import 'package:flutter/material.dart';
import 'package:toaido_flutter/presentation/screens/login/forgot_password_screen.dart';
import 'package:toaido_flutter/presentation/screens/login/signin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //controllerlar
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Formun durumunu yöneten anahtar
  final _formKey = GlobalKey<FormState>();

  // API isteği sırasında yüklenme durumunu yönetmek için buna animation arastır ekle
  bool _isLoading = false;

  @override
  void dispose() {
    // Controller'ları temizleyerek hafıza sızıntısını önle
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --------------- provider veya bloc ekle buraya -----------------
  // ------- bır kere giris yapan birdaha yapamasın telefon bellegine kaydet  -------



  // Giriş yapma fonksiyonu
  Future<void> _signIn() async {
    // Formun geçerli olup olmadığını kontrol et
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // --- BURASI API BAĞLANTISININ YAPILACAĞI YER ---
      // duzgun kod yaz buraya once sunucu otomatık nasıl acarım onu arastır


      // Simülasyon için 2 saniye bekle
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Temel renk ve stil tanımlamaları
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );
    final inputFillColor = Colors.black12;
    final hintStyle = TextStyle(color: Colors.blueAccent);
    final Colorbox= Colors.white70;

    return Scaffold(

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Başlık ve Slogan
                  const Text(
                    "ToAiDo'ya Hoş Geldiniz",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Yapay zeka ile projelerini planla,\ngörevlerini yönet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // E-posta Alanı
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'E-posta',
                      hintStyle: hintStyle,
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.blueAccent),
                      filled: true,
                      fillColor: inputFillColor,
                      border: inputBorder,
                    ),
                    // -------- galiba bunu baska yerde yapmam lazım ama deniyecem burda once -----
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Lütfen geçerli bir e-posta adresi girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Parola Alanı
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Parola',
                      hintStyle: hintStyle,
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.blueAccent),
                      filled: true,
                      fillColor: inputFillColor,
                      border: inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen parolanızı girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Parolamı Unuttum
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        'Parolamı Unuttum',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Giriş Yap Butonu
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.blueAccent.withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kayıt olma linki
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hesabın yok mu? ',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          'Hemen Kaydol',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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