import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = 'jimmygrammy@gmail.com';
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: 375,
          height: 812,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              // Email Label
              const Positioned(
                left: 27,
                top: 289,
                child: SizedBox(
                  width: 225,
                  child: Opacity(
                    opacity: 0.80,
                    child: Text(
                      'Email Address',
                      style: TextStyle(
                        color: Color(0xFF323232),
                        fontSize: 14,
                        fontFamily: 'Colfax',
                        fontWeight: FontWeight.w400,
                        height: 1.29,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Email Input Field
              Positioned(
                left: 27,
                top: 308,
                child: SizedBox(
                  width: 321,
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(
                      color: Color(0xFF0C135A),
                      fontSize: 16,
                      fontFamily: 'Colfax',
                      fontWeight: FontWeight.w400,
                      height: 1.12,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              
              // Email Underline
              Positioned(
                left: 27,
                top: 351,
                child: Container(
                  width: 321,
                  height: 1,
                  decoration: const BoxDecoration(color: Color(0xFF323232)),
                ),
              ),
              
              // Password Label
              const Positioned(
                left: 27,
                top: 384,
                child: SizedBox(
                  width: 225,
                  child: Opacity(
                    opacity: 0.80,
                    child: Text(
                      'Password',
                      style: TextStyle(
                        color: Color(0xFF323232),
                        fontSize: 14,
                        fontFamily: 'Colfax',
                        fontWeight: FontWeight.w400,
                        height: 1.29,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Password Input Field
              Positioned(
                left: 27,
                top: 403,
                child: SizedBox(
                  width: 321,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(
                      color: Color(0xFF323232),
                      fontSize: 16,
                      fontFamily: 'Colfax',
                      fontWeight: FontWeight.w400,
                      height: 1.12,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter New Password',
                      hintStyle: TextStyle(
                        color: Color(0xFF323232),
                        fontSize: 16,
                        fontFamily: 'Colfax',
                        fontWeight: FontWeight.w400,
                        height: 1.12,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              
              // Password Underline
              Positioned(
                left: 27,
                top: 446,
                child: Container(
                  width: 321,
                  height: 1,
                  decoration: const BoxDecoration(color: Color(0xFF323232)),
                ),
              ),
              
              // Login Button
              Positioned(
                left: 27,
                top: 497,
                child: GestureDetector(
                  onTap: () => _login(),
                  child: Container(
                    width: 321,
                    height: 51.91,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF404CCF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Colfax',
                          fontWeight: FontWeight.w400,
                          height: 0.90,
                          letterSpacing: 0.40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Forgot Password
              Positioned(
                left: 127,
                top: 589,
                child: GestureDetector(
                  onTap: () => _forgotPassword(),
                  child: const Text(
                    'Forgot Password? ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF323232),
                      fontSize: 14,
                      fontFamily: 'Colfax',
                      fontWeight: FontWeight.w400,
                      height: 1,
                      letterSpacing: 0.28,
                    ),
                  ),
                ),
              ),
              
              // New User Prompt
              Positioned(
                left: 96,
                top: 623,
                child: Row(
                  children: [
                    const Text(
                      'New User?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF323232),
                        fontSize: 14,
                        fontFamily: 'Colfax',
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 0.28,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _createAccount(),
                      child: const Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF404CCF),
                          fontSize: 14,
                          fontFamily: 'Colfax',
                          fontWeight: FontWeight.w500,
                          height: 1,
                          letterSpacing: 0.28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() {
    // Implement login functionality
    debugPrint('Login with: ${_emailController.text}');
  }

  void _forgotPassword() {
    // Implement forgot password
    debugPrint('Forgot password pressed');
  }

  void _createAccount() {
    // Implement create account
    debugPrint('Create account pressed');
  }
}