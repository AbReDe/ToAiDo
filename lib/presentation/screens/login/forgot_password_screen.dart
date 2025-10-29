import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _message; // Kullanıcıya geri bildirim göstermek için

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _message = null; // Eski mesajı temizle
      });

      // --- BURASI API BAĞLANTISININ YAPILACAĞI YER ---
      //ekran kodunda zaten yazıdın bunu cagırıcagını devamı bende krall

      // --- API BAĞLANTISI SONU ---

      await Future.delayed(const Duration(seconds: 2)); // Simülasyon

      setState(() {
        _isLoading = false;
        _message = 'Eğer bu e-posta adresi sistemimizde kayıtlıysa, bir sıfırlama bağlantısı gönderilmiştir.';
        _emailController.clear();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Parolanı Sıfırla',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kayıtlı e-posta adresini gir, sana bir sıfırlama bağlantısı gönderelim.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 48),

                if (_message == null) ...[ // Eğer mesaj yoksa formu göster
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
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: Colors.blueAccent.withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                        height: 24, width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Sıfırlama Bağlantısı Gönder',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ] else ...[ // Eğer mesaj varsa, mesajı göster
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green)
                    ),
                    child: Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}