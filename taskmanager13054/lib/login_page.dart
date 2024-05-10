import 'dart:convert';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true, 
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 4, 152, 251),
                  Color.fromARGB(255, 185, 82, 82),
                  Color.fromARGB(255, 184, 150, 150),
                  Color.fromARGB(255, 106, 87, 214),
                ],
                stops: [0.1, 0.3, 0.8, 1],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    floatingLabelStyle: const TextStyle(
                        color: Colors.red, // Color of the label text when focused
                      ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    floatingLabelStyle: const TextStyle(
                        color: Color.fromARGB(255, 2, 17, 176), // Color of the label text when focused
                      ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final response = await http.post(
                        Uri.parse(
                            'https://parseapi.back4app.com/login'), // Corrected login endpoint
                        headers: {
                          'X-Parse-Application-Id':
                              '',
                          'X-Parse-REST-API-Key':
                              '',
                          // 'X-Parse-Master-Key':
                          //     '', // Removed the leading space
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode({
                          'username': _usernameController.text,
                          'password': _passwordController.text,
                        }),
                      );

                      if (response.statusCode == 200) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Invalid credentials or error ${response.body}'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
