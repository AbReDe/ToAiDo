import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Form alanlarını kontrol etmek için controller'lar
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Formun durumunu yönetmek için bir anahtar
  final _formKey = GlobalKey<FormState>();

  // API isteği sırasında yüklenme durumunu yönetmek için
  bool _isLoading = false;

  @override
  void dispose() {
    // Controller'ları temizleyerek hafıza sızıntısını önle
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Kayıt olma fonksiyonu
  Future<void> _signUp() async {
    // Formun geçerli olup olmadığını kontrol et
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // --- BURASI API BAĞLANTISININ YAPILACAĞI YER ---
      //bunu sonra siilmeyi unutma



      // Simülasyon için 2 saniye bekle
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );
    final inputFillColor = Colors.black12;
    final hintStyle = TextStyle(color: Colors.blueAccent);

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
                    "Hesap Oluştur",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aramıza katıl ve projelerini planlamaya başla.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Kullanıcı Adı Alanı
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Kullanıcı Adı',
                      hintStyle: hintStyle,
                      prefixIcon: Icon(Icons.person_outline, color: Colors.blueAccent),
                      filled: true,
                      fillColor: inputFillColor,
                      border: inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir kullanıcı adı girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

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
                      if (value.length < 6) {
                        return 'Parola en az 6 karakter olmalıdır.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Parola Tekrar Alanı
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Parolayı Onayla',
                      hintStyle: hintStyle,
                      prefixIcon: Icon(Icons.lock_clock_outlined, color: Colors.blueAccent),
                      filled: true,
                      fillColor: inputFillColor,
                      border: inputBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen parolanızı tekrar girin.';
                      }
                      if (value != _passwordController.text) {
                        return 'Parolalar eşleşmiyor.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Kaydol Butonu
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
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
                      'Kaydol',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Giriş yapma linki
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zaten bir hesabın var mı? ',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Giriş ekranına geri dön
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Giriş Yap',
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