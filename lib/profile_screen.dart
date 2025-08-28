import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String firstName;
  final String lastName;

  const ProfileScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('First Name: $firstName', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Last Name: $lastName', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
