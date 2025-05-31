import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_tracking_app/common/widgets/custom_button.dart';
import 'package:staff_tracking_app/common/widgets/custom_textfield.dart';
import 'package:staff_tracking_app/features/authentication/view/widgets/sigin_signup_button.dart';
import 'package:staff_tracking_app/features/authentication/view/widgets/signin_signup_text.dart';
import '../../providers/auth_provider.dart';
import '../../../admin/view/screens/admin_home.dart';
import '../../../staff/view/screens/staff_home.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = ref.read(authViewModelProvider);

    try {
      await authVM.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final role = authVM.user?.role;
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHome()),
        );
      } else if (role == 'staff') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StaffHome()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unknown user role.')));
      }
    } catch (e) {
      log('Login error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SigninSignupText(text: "Sign In"),
                SizedBox(height: 50),
                CustomTextfield(
                  controller: _emailController,
                  hint: 'Enter Email',
                  onValidator:
                      (value) =>
                          (value == null || !value.contains('@'))
                              ? 'Enter a valid email'
                              : null,
                ),
                const SizedBox(height: 16),
                CustomTextfield(
                  controller: _passwordController,
                  hint: 'Enter Password',
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  onValidator:
                      (value) =>
                          (value == null || value.length < 6)
                              ? 'Minimum 6 characters required'
                              : null,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  title: 'Login',
                  onPressed: () {
                    _handleLogin();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: SiginSignupButton(
          text1: "Don't have an account? ",
          text2: 'Sign Up',
          widget: RegisterScreen(),
        ),
      ),
    );
  }
}


