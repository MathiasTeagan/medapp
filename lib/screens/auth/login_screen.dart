import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/text_styles.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);
        await context.read<AuthProvider>().signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
        if (!mounted) return;

        // Başarılı giriş sonrası MainScreen'e yönlendir
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } catch (e) {
        if (!mounted) return;

        String errorMessage = 'Giriş yapılırken bir hata oluştu';
        if (e.toString().contains('user-not-found')) {
          errorMessage = 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Hatalı şifre';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Geçersiz e-posta adresi';
        } else if (e.toString().contains('network-request-failed')) {
          errorMessage = 'İnternet bağlantınızı kontrol edin';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1,
              left: 20,
              right: 20,
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppTheme.screenPadding(context),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: size.width * 0.2,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'MedApp',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 48),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: Icon(
                        Icons.lock,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.primary.withOpacity(0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen şifrenizi girin';
                      }
                      if (value.length < 6) {
                        return 'Şifre en az 6 karakter olmalıdır';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Şifremi Unuttum',
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _login,
                    style: FilledButton.styleFrom(
                      minimumSize: Size(
                        double.infinity,
                        isSmallScreen ? 48 : 56,
                      ),
                    ),
                    child: _isLoading
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
                        : const Text('Giriş Yap'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hesabınız yok mu?',
                        style: AppTextStyles.bodyMedium(context),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Kayıt Ol',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: AppColors.primary,
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
