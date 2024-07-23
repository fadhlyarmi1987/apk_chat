import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // Import package intl for date formatting

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _convertEmailToUid(String email) {
    var bytes = utf8.encode(email); // data being hashed
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> register(String name, String divisi, String email, String password, String collection) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        String uid = user.uid; // Mendapatkan UID pengguna yang baru dibuat

        // Menyimpan informasi pengguna ke Firestore sesuai aturan
        await _firestore.collection(collection).doc(email).set({
          'name': name,
          'divisi': divisi,
          'email': email,
          'password': password,
          'collection': collection,
        });
      }
      return user;
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  Future<void> sendMessage(String receiverEmail, String message) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String senderEmail = user.email!;
      Timestamp time = Timestamp.now(); // Current timestamp

      try {
        // Format waktu sesuai kebutuhan
        var formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(time.toDate());

        // Start a batch
        WriteBatch batch = _firestore.batch();

        // Message data
        Map<String, dynamic> messageData = {
          'from': senderEmail,
          'to': receiverEmail,
          'text': message,
          'time': formattedTime, // Menggunakan waktu yang diformat
          'dari': 'unknown', // Menambahkan field 'dari' dengan nilai 'unknown'
          'isread': false, // Menambahkan field 'isread' dengan nilai false
        };

        // Reference to sender's chat collection
        DocumentReference senderChatRef = _firestore.collection('bos').doc(senderEmail).collection('chats').doc(time.toDate().toString());

        // Reference to receiver's bos chat collection
        DocumentReference receiverBosChatRef = _firestore.collection('bos').doc(receiverEmail).collection('chats').doc(time.toDate().toString());

        // Add the message to the sender's chat collection
        batch.set(senderChatRef, messageData);

        // Add the message to the receiver's bos chat collection
        batch.set(receiverBosChatRef, messageData);

        // Commit the batch
        await batch.commit();
      } catch (e) {
        print('Error sending message: $e');
        throw e;
      }
    } else {
      throw 'User not logged in!';
    }
  }
}
