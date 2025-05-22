// login/login_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/login_view_model.dart';

class LoginView extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: InputDecoration(labelText: 'Username')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            viewModel.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: () async {
                    final success = await viewModel.login(_usernameController.text, _passwordController.text);
                    if (success) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed')));
                    }
                  },
                  child: Text('Login'),
                ),
          ],
        ),
      ),
    );
  }
}
