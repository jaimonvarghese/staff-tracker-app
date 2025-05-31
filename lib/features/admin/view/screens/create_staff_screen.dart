import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_tracking_app/common/widgets/custom_button.dart';
import 'package:staff_tracking_app/common/widgets/custom_textfield.dart';
import 'package:staff_tracking_app/features/authentication/providers/auth_provider.dart';
import 'package:staff_tracking_app/features/authentication/view/widgets/signin_signup_text.dart';

import '../../../admin/view/screens/admin_home.dart';

class CreateStaffScreen extends ConsumerStatefulWidget {
  const CreateStaffScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateStaffScreen> createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends ConsumerState<CreateStaffScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'staff';

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = ref.read(authViewModelProvider);

    try {
      await authVM.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHome()),
      );
    } catch (e) {
      log('Register error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SigninSignupText(text: "Create Staff"),
                SizedBox(height: 30),
                CustomTextfield(
                  controller: _nameController,
                  hint: 'Enter Staff name',
                  onValidator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter your name'
                              : null,
                ),
                const SizedBox(height: 15),
                CustomTextfield(
                  controller: _emailController,
                  hint: 'Enter staff email',
                  onValidator:
                      (value) =>
                          value == null || !value.contains('@')
                              ? 'Enter a valid email'
                              : null,
                ),
                const SizedBox(height: 15),
                CustomTextfield(
                  controller: _passwordController,
                  hint: 'Enter staff  password',
                  onValidator:
                      (value) =>
                          value != null && value.length < 6
                              ? 'Minimum 6 characters'
                              : null,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xFF2C2C2C),
                  value: _selectedRole,
                  items: const [
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text(
                        'Admin',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'staff',
                      child: Text(
                        'Staff',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                  decoration: InputDecoration(
                    hintText: _selectedRole,
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 25),
                CustomButton(
                  title: 'Create ',
                  onPressed: () {
                    _handleRegister();
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
