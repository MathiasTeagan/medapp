import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().resetPassword(
              _emailController.text.trim(),
            );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Sıfırlama'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.screenPadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Şifrenizi mi unuttunuz?',
                  style: AppTextStyles.titleLarge(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
                  style: AppTextStyles.bodyMedium(context),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(
                      Icons.email,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen e-posta adresinizi girin';
                    }
                    if (!value.contains('@')) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return FilledButton(
                      onPressed: auth.isLoading ? null : _resetPassword,
                      style: FilledButton.styleFrom(
                        minimumSize: Size(
                          double.infinity,
                          isSmallScreen ? 48 : 56,
                        ),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Şifre Sıfırlama Bağlantısı Gönder'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
