import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'main_screen.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const LoginPage({required this.cameras, super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Test credentials for local validation
  final Map<String, String> _testCredentials = {
    'testuser1': 'password123',
    'testuser2': 'password456',
  };

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Email and Password')),
      );
      return;
    }

    if (_testCredentials.containsKey(email) && _testCredentials[email] == password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(cameras: widget.cameras, userId: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Email or Password')),
      );
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final emailTop = screenHeight * 0.356;
    final passwordTop = screenHeight * 0.473;
    final buttonTop = screenHeight * 0.612;
    final footerTop = screenHeight * 0.725;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Stack(
            children: [
              Positioned(
                left: 27,
                top: emailTop,
                child: SizedBox(
                  width: screenWidth - 54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.80,
                        child: Text(
                          'Email Address',
                          style: TextStyle(
                            color: const Color(0xFF323232),
                            fontSize: 14,
                            fontFamily: 'Colfax',
                            fontWeight: FontWeight.w400,
                            height: 1.29,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        style: TextStyle(
                          color: const Color(0xFF0C135A),
                          fontSize: 16,
                          fontFamily: 'Colfax',
                          fontWeight: FontWeight.w400,
                          height: 1.12,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'jimmygrammy@gmail.com',
                          hintStyle: TextStyle(color: Color(0xFF323232)),
                        ),
                      ),
                      Container(
                        height: 1,
                        decoration: const BoxDecoration(color: Color(0xFF323232)),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 27,
                top: passwordTop,
                child: SizedBox(
                  width: screenWidth - 54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.80,
                        child: Text(
                          'Password',
                          style: TextStyle(
                            color: const Color(0xFF323232),
                            fontSize: 14,
                            fontFamily: 'Colfax',
                            fontWeight: FontWeight.w400,
                            height: 1.29,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(
                          color: const Color(0xFF0C135A),
                          fontSize: 16,
                          fontFamily: 'Colfax',
                          fontWeight: FontWeight.w400,
                          height: 1.12,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter New Password',
                          hintStyle: TextStyle(color: Color(0x80323232)),
                        ),
                      ),
                      Container(
                        height: 1,
                        decoration: const BoxDecoration(color: Color(0xFF323232)),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 27,
                top: buttonTop,
                child: GestureDetector(
                  onTap: _handleLogin,
                  child: Container(
                    width: screenWidth - 54,
                    height: 51.91,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF404CCF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              Positioned(
                left: 0,
                right: 0,
                top: footerTop,
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'New User?',
                          style: TextStyle(
                            color: Color(0xFF323232),
                            fontSize: 14,
                            fontFamily: 'Colfax',
                            fontWeight: FontWeight.w400,
                            height: 1,
                            letterSpacing: 0.28,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Create Account',
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}