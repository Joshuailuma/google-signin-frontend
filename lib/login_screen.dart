import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'my_text_field.dart';

class LoginScreen extends StatelessWidget {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final baseUrl = '10.0.2.2:8080';


  LoginScreen({super.key});

   static const List<String> scopes = <String>['openid'
  ];

  GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: 'your-app-client-id.apps.googleusercontent.com',
      scopes: scopes);

  Future<void> _handleGoogleSignIn(BuildContext context) async {

    try {
      final googleSignInResponse = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleSignInResponse?.authentication;
      print("$googleSignInResponse  and  $googleAuth");

      final String? accessToken = googleAuth?.accessToken;
      final String? idToken = googleAuth?.idToken;
      print("Id token is $idToken");
      print("Access token token is $accessToken");

      if(idToken!=null){
        final url = Uri.parse('http://${baseUrl}/authentication/google-login');
        final response = await http.post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"idToken": idToken})
        );

        print(response.body);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final String token = responseData["accessToken"];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);

          print('Token stored successfully: $token');

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          print('Google login failed');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.body)),
          );
        }
      } else{
        print('Couldn\'t get id token');

      }

    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Email box.
            InputTextField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'Enter your email address',
              prefixIcon: Icons.email,
              obscureText: false,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                return null;
              },
            ),

            // Password box
            const SizedBox(height: 20),

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
              },),


            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                _login(context, emailController.text, passwordController.text);
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => _handleGoogleSignIn(context),
              child: const Text('Sign In with Google'),
            ),
            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: const Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  void _login(BuildContext context, String email, String password) async {

      final url = Uri.parse('http://${baseUrl}/authentication/login');

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": email, "password": password}),
        );

        if (response.statusCode == 200) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final responseData = jsonDecode(response.body);
          final String token = responseData["accessToken"];
          await prefs.setString('auth_token', token);

          print('Token stored successfully: $token');

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          final Map<String, dynamic> body = jsonDecode(response.body);
          final String errorMessage = body['errorMessage'] ?? 'Something went wrong';

          print('Login failed: $errorMessage');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
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