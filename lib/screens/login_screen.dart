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

  return Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.25), // Shift everything further down

            // Email Address Label
            Text(
              'Email Address',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
            ),
            const SizedBox(height: 6),

            // Email Address Input
            TextField(
              controller: _userIdController,
              keyboardType: TextInputType.emailAddress,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'example@email.com',
                hintStyle: Theme.of(context).textTheme.bodyMedium,
                border: InputBorder.none,
              ),
            ),
            Container(
              height: 1,
              color: Theme.of(context).dividerColor,
            ),
            const SizedBox(height: 28),

            // Password Label
            Text(
              'Password',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
            ),
            const SizedBox(height: 6),

            // Password Input
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: Theme.of(context).textTheme.bodyMedium,
                border: InputBorder.none,
              ),
            ),
            Container(
              height: 1,
              color: Theme.of(context).dividerColor,
            ),

            const SizedBox(height: 36),

            // Rectangular Login Button with rounded corners
            Center(
              child: GestureDetector(
                onTap: _handleLogin,
                child: Container(
                  width: screenWidth * 0.55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10), // Greatly reduced spacing

            // Forgot Password
            Center(
              child: TextButton(
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
            ),

            // No spacing here

            // Create Account inline with "Don't have an account?"
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Account'),
          content: const Text('Please contact the developer to create an account.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  },
  style: TextButton.styleFrom(padding: EdgeInsets.zero),
  child: Text(
    'Create Account',
    style: TextStyle(
      color: Theme.of(context).primaryColor,
      fontWeight: FontWeight.w500,
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
}