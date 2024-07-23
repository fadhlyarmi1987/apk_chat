import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../roomchat/roomchat_bos_page.dart';

class DashboardBosPage extends StatelessWidget {
  final String userName;
  final String email;

  DashboardBosPage(
      {required this.userName, required this.email, required String division});

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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                width: 200,
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('User'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Setting'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Log Out'),
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 131, 234),
        title: Text(
          userName,
          style: TextStyle(color: Colors.white),
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
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bos')
                  .doc(email) // Gunakan email pengguna yang login
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('Data tidak ditemukan!'));
                }

                // Ambil referensi koleksi 'chats' untuk email yang sedang login
                CollectionReference chatsRef = FirebaseFirestore.instance
                    .collection('bos')
                    .doc(email)
                    .collection('chats')
                    ;

                return StreamBuilder<QuerySnapshot>(
                  stream: chatsRef.orderBy('time', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('Belum ada pesan!'));
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var doc = docs[index];
                        var fromUser = doc['dari'];
                        var messageTime = doc['time'];
                        var chatText = doc['text'];
                        var isRead = doc['isread'] ?? false;

                        return Card(
                          color: isRead ? Color.fromARGB(255, 147, 172, 236) : Color.fromARGB(255, 147, 172, 236),
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                          elevation: 3,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoomChatBosPage(
                                    userName: userName,
                                    email: email,
                                    fromUser: fromUser,
                                    chatText: chatText,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal: $messageTime',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
