import 'package:flutter/material.dart';
import 'package:task_manager/functions/supportive_functions.dart';
import 'package:task_manager/screens/login.dart';
import 'package:task_manager/api_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() {
    return _SignUpScreenState();
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _isObscure = true;

  void _goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const LoginScreen()),
    );
  }

  void _signUpUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await apiService.signup(
          _fullNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        title: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                maxLength: 50,
                decoration: InputDecoration(label: Text('Full Name')),
                validator: (value) => validateFullName(value),
              ),

              TextFormField(
                controller: _emailController,
                maxLength: 50,
                decoration: InputDecoration(label: Text('Email')),
                validator: (value) => validateEmail(value),
              ),
              TextFormField(
                controller: _passwordController,
                maxLength: 50,
                validator: (value) => validatePassword(value),
                obscureText: _isObscure,
                decoration: InputDecoration(
                  label: Text('Password'),
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
              ),
              TextFormField(
                controller: _confirmPasswordController,
                maxLength: 50,
                validator: (value) =>
                    validateConfirmPassword(value, _passwordController.text),
                obscureText: _isObscure,
                decoration: InputDecoration(
                  label: Text('Confirm Password'),
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
              ),
              SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _signUpUser(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryFixed,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  _goToLogin(context);
                },
                child: Text('Already have an account? Sign in'),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
