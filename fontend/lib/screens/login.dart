import 'package:flutter/material.dart';
import 'package:task_manager/functions/supportive_functions.dart';
import 'package:task_manager/screens/signup.dart';
import 'package:task_manager/api_service.dart';
import 'package:task_manager/screens/tabs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _isObscure = true;


  void _goToSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const SignUpScreen()),
    );
  }

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await apiService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => TabsScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        title: const Text(
          'Welcome back',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                maxLength: 50,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: _isObscure
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                validator: validatePassword,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryFixed,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () => _goToSignUp(context),
                child: const Text("Don't have an account? Sign up"),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
