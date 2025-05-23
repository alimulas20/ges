import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../global/widgets/app_text_field.dart';
import '../viewmodels/login_view_model.dart';

class LoginView extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [theme.colorScheme.primaryContainer, theme.colorScheme.secondaryContainer]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: NetworkImage('https://picsum.photos/200'), fit: BoxFit.cover)),
                ),
                const SizedBox(height: 32),

                // Welcome text
                Text('Tekrar Hoşgeldiniz', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text('Devam  etmek için lütfen giriş yapın', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                const SizedBox(height: 32),

                // Custom text fields
                AppTextField(controller: _usernameController, labelText: 'Kullanıcı Adı', prefixIcon: Icons.person_outline, borderRadius: 12),
                const SizedBox(height: 16),
                AppTextField(controller: _passwordController, labelText: 'Şifre', prefixIcon: Icons.lock_outline, suffixIcon: Icons.visibility_off, isPassword: true, borderRadius: 12),
                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        viewModel.isLoading
                            ? null
                            : () async {
                              final success = await viewModel.login(_usernameController.text, _passwordController.text);
                              if (success) {
                                Navigator.pushReplacementNamed(context, '/home');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giriş Başarısız'), behavior: SnackBarBehavior.floating));
                              }
                            },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child:
                        viewModel.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Giriş Yap', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),

                // Forgot password and sign up
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [TextButton(onPressed: () {}, child: Text('Şifremi Unuttum?', style: TextStyle(color: theme.colorScheme.primary)))]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
