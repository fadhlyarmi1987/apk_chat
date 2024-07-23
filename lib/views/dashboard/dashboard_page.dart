import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../setting/user_detail_page.dart';
import '../setting/settings_page.dart';
import '../roomchat/roomchat_page.dart';

class DashboardPage extends StatelessWidget {
  final String userName;
  final String email;
  final String division;

  DashboardPage({
    required this.userName,
    required this.email,
    this.division = '',
  });

  void _showOptionsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 56.0, left: 8.0),
            child: Material(
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Container(
                width: 200,
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('User'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigasi ke halaman detail pengguna
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailPage(
                              name: userName, // Kirim nama pengguna yang sedang login
                              email: email, // Kirim email yang benar
                              division: division, // Kirim divisi yang benar
                              profilePictureUrl: '', // Kirim URL foto profil jika diperlukan
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Setting'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(
                              currentName: userName,
                              email: email,
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Log Out'),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 131, 234),
        title: Text(
          '$userName',
          style: TextStyle(color: Colors.white), // Warna teks menjadi putih
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () => _showOptionsModal(context),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 20, 131, 234),
      body: Column(
        children: [
          // Garis di bawah AppBar
          Container(
            height: 1.0,
            color: const Color.fromARGB(255, 255, 255, 255), // Warna garis
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bos').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No data available'));
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                  padding: EdgeInsets.fromLTRB(4, 20, 4, 10),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    var email = docs[index].id; // Ambil email dari dokumen ID
                    return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                            builder: (context) => RoomChatPage(
                              name: data['name'] ?? 'No Name',
                                    email: email,
                                    userName: userName,
                             ),
                                ),
                              );
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: -8,
                              blurRadius: 6,
                              offset: Offset(0, 6),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        height: 70.0, // Atur tinggi Card 
                        child: Card(
                          color: Color.fromARGB(255, 147, 172, 236),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                            child: Center(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 50.0), // Atur jarak kiri sesuai kebutuhan
                                    child: Text(
                                      data['name'] ?? 'No Name',
                                      
                                      style: GoogleFonts.khmer(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                      
                                    ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
