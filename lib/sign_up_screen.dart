import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'my_text_field.dart';

class SignupScreen extends StatefulWidget {

 const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();
  static const List<String> scopes = <String>['openid'
  ];

  GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: '794524554994-je7prjh6bivuh162ps55vjh3nekti431.apps.googleusercontent.com', scopes: scopes);

  final baseUrl = '10.0.2.2:8080';

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final googleSignInResponse = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleSignInResponse?.authentication;
      print(googleAuth);
      final String? idToken = googleAuth?.idToken;

      final url = Uri.parse('http://${baseUrl}/authentication/google-login');

      final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"idToken": idToken})
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final String token = responseData["accessToken"];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          print('SGoogle signup failed: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.body)),
          );
        }
          } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
        );
        }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            InputTextField(
              controller: firstNameController,
              labelText: 'First name',
              hintText: 'Enter your first name',
              prefixIcon: Icons.person,
              obscureText: false,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 10),

            InputTextField(
              controller: lastNameController,
              labelText: 'Last name',
              hintText: 'Enter your last name',
              prefixIcon: Icons.person,
              obscureText: false,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Last name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 10),

            InputTextField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'Enter your email address',
              prefixIcon: Icons.email,
              obscureText: false,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email address is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 10),

            InputTextField(
                controller: passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icons.lock,
                obscureText: true, keyboardType: TextInputType.visiblePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                _signUp(context, emailController.text,
                    passwordController.text,
                    firstNameController.text, lastNameController.text);
              },
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => _handleGoogleSignIn(context),
              child: const Text('Sign Up with Google'),
            ),
            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
                },
              child: const Text('Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  void _signUp(BuildContext context, String email,
      String password,
      String firstName,
      String lastName) async {
      final url = Uri.parse('http://${baseUrl}/authentication/register');

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": email, "password": password, "firstName": firstName, "lastName": lastName}),
        );

        if (response.statusCode == 201) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          final Map<String, dynamic> body = jsonDecode(response.body);
          final String errorMessage = body['errorMessage'] ?? 'Something went wrong';
          print('Signup failed: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup failed: $errorMessage')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
}