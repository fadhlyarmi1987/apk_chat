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
  bool _switchToRegister = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 34, 156, 245), // Set background color
      padding: EdgeInsets.fromLTRB(
          16.0,
          MediaQuery.of(context).padding.top + kToolbarHeight + 0.0,
          16.0,
          16.0),
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
              _emailController, 'Email', TextInputType.emailAddress),
          SizedBox(height: 10.0),
          _buildTextField(
              _passwordController, 'Password', TextInputType.text, true),
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
                  angle: 3.14, // 180 derajat dalam radian
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      [TextInputType keyboardType = TextInputType.text,
      bool obscureText = false]) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 239, 236, 236), // Set warna
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // posisi shadow
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
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        

        // Cek koleksi 'users'
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(email).get();
        String collection = 'users';
        String name = '';
        String division = '';

        // Jika dokumen tidak ada di 'users', cek di 'bos'
        if (!userDoc.exists) {
          userDoc = await _firestore.collection('bos').doc(email).get();
          if (userDoc.exists) {
            collection = 'bos';
          }
        }

        // Ambil nama pengguna dari Firestore
        if (userDoc.exists) {
          name = userDoc['name'] ?? '';
          division = userDoc['divisi'] ?? '';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor:
                Colors.transparent, // Atur backgroundColor menjadi transparan
            elevation:
                0, // Atur elevation menjadi 0 untuk menghapus bayangan default
            content: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(30), // Atur border radius
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 12.0), // Padding dalam kontainer
              child: Center(
                heightFactor: 1.0,
                child: Text(
                  'Login Berhasil, Selamat Datang $name!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white), // Warna teks menjadi putih
                ),
              ),
            ),
            duration: Duration(seconds: 3),
          ),
        );

        if (collection == 'bos') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardBosPage(
                userName: name,
                email: email,
                division: division,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(
                  userName: name, email: email, division: division),
            ),
          );
        }
        print('Login berhasil: sebagai email: $email, nama $name, divisi $division');
      } else {
        print('User null setelah login');
      }
    } catch (e) {
      print('Error saat login: $e');
      String errorMessage = 'Terjadi kesalahan saat login';
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? 'Terjadi kesalahan saat login';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Center(
            heightFactor: 1.0,
            child: Text(
              'Email / Password Salah!',
              textAlign: TextAlign.center,
            ),
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
