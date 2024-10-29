import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dashboard/dashboard_page.dart';
import '../dashboard/dashboard_page_bos.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 34, 156, 245), // Set full background color
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 34, 156, 245),
        automaticallyImplyLeading: false,
      ),
      body: LoginForm(),
    );
  }
}


class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16.0,
            MediaQuery.of(context).padding.top + kToolbarHeight,
            16.0,
            16.0,
          ),
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/umm_logo_text.png',
                height: 110.0,
              ),
              SizedBox(height: 10.0),
              Text(
                'Login',
                style: GoogleFonts.kodchasan(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.0),
              _buildTextField(
                _emailController,
                'Email',
                TextInputType.emailAddress,
              ),
              SizedBox(height: 10.0),
              _buildTextField(
                _passwordController,
                'Password',
                TextInputType.text,
                true,
              ),
              SizedBox(height: 20.0),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                width: 115,
                height: 35,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'MASUK',
                    style: GoogleFonts.kodchasan(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Belum punya akun? klik icon di samping untuk mendaftar!',
                      style: GoogleFonts.kodchasan(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Transform.rotate(
                      angle: 3.14,
                      child: Image.asset(
                        'assets/right_switch.png',
                        width: 50.0,
                        height: 50.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, [
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  ]) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 239, 236, 236),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  void _login() async {
    // Implementasi login
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
