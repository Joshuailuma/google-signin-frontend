import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_signin_app/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final baseUrl = '10.0.2.2:8080';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome! You are logged in'),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final response = await _viewProfile();
                final Map<String, dynamic> body = jsonDecode(response!.body);

                final firstName = body['firstName'] ?? '';
                final lastName = body ['lastName'] ?? '';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      firstName: firstName,
                      lastName: lastName,
                    ),
                  ),
                );
              },
              child: const Text('View profile'),
            ),


            const SizedBox(height: 20),


            ElevatedButton(
              onPressed: () async {
                await googleSignIn.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  Future<http.Response?> _viewProfile() async {
    final url = Uri.parse('http://${baseUrl}/profile');

    String? token = await _getAuthToken();
    if (token == null) {
      print("No token found, user not logged in.");
    }

    try {
      http.Response response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("Token gotten $token");

      if (response.statusCode == 200) {
        print("User Data: ${response.body}");
        return response;
      } else {
        print("Failed to fetch user data: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

}