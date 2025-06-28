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
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();

  final Map<String, String> _testCredentials = {
    'testuser1': 'password123',
    'testuser2': 'password456',
  };

  void _handleLogin() {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter User ID and Password')),
      );
      return;
    }

    if (_testCredentials.containsKey(userId) && _testCredentials[userId] == password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(cameras: widget.cameras, userId: userId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid User ID or Password')),
      );
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final headerTop = screenHeight * 0.1;
    final userIdTop = screenHeight * 0.25;
    final passwordTop = screenHeight * 0.35;
    final buttonTop = screenHeight * 0.45;
    final footerTop = screenHeight * 0.55;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Stack(
            children: [
              Positioned(
                top: headerTop,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              Positioned(
                left: 27,
                top: userIdTop,
                child: SizedBox(
                  width: screenWidth - 54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.80,
                        child: Text(
                          'User ID',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _userIdController,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your User ID',
                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Container(
                        height: 1,
                        color: Theme.of(context).dividerColor,
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
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Password',
                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Container(
                        height: 1,
                        color: Theme.of(context).dividerColor,
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
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
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
                      child: Text(
                        'Forgot Password?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
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