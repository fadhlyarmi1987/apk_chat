import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class RoomChatPage extends StatefulWidget {
  final String userName;
  final String email;
  final String name;

  RoomChatPage({required this.userName, required this.email, required this.name});

  @override
  _RoomChatPageState createState() => _RoomChatPageState();
}

class _RoomChatPageState extends State<RoomChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final AuthController _authController = AuthController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double _currentRating = 0;

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String message = _messageController.text;
      User? user = _auth.currentUser;

      if (user != null) {
        try {
          await _authController.sendMessage(widget.email, message);
          _messageController.clear();
          _showRatingDialog();
        } catch (e) {
          print('Error sending message: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sending message: $e'),
            ),
          );
        }
      } else {
        print('User is not logged in');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User is not logged in'),
          ),
        );
      }
    }
  }

  void _markAsRead(DocumentSnapshot doc) {
    doc.reference.update({'isread': true});
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Beri Rating untuk ${widget.userName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: _currentRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _currentRating = rating;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Kirim'),
              onPressed: () {
                _submitRating();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRating() async {
    if (_currentRating > 0) {
      try {
        await FirebaseFirestore.instance.collection('ratings').add({
          'to': widget.email,
          'rating': _currentRating,
          'from': _auth.currentUser?.email,
          'timestamp': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating berhasil dikirim!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim rating: $e')),
        );
      }
    }
  }

  @override
Widget build(BuildContext context) {
  User? user = _auth.currentUser;
  String senderEmail = user != null ? user.email! : '';
  return Scaffold(
    appBar: AppBar(
      title: Text('Kirimkan Pesan Ke ${widget.name}'),
    ),
    body: Column(
      children: <Widget>[
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bos')
                .doc(senderEmail)
                .collection('chats')
                .where('to', isEqualTo: widget.email)
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text('Belum ada pesan!'),
                );
              }

              final messages = snapshot.data!.docs;
              List<MessageBubble> messageWidgets = [];

              for (var message in messages) {
                final messageText = message['text'];
                final messageSender = message['from'];
                final isRead = message['isread'] ?? false;
                final currentUser = _auth.currentUser?.email;

                final messageWidget = MessageBubble(
                  text: messageText,
                  isMe: currentUser == messageSender,
                  isRead: isRead,
                  onTap: () => _markAsRead(message),
                );

                messageWidgets.add(messageWidget);
              }

              return ListView(
                reverse: true,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                children: messageWidgets,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Tulis pesan...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              _showRatingDialog();
            },
            child: Text('Beri Rating'),
          ),
        ),
      ],
    ),
  );
}

}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final bool isRead;
  final Function onTap;

  MessageBubble({required this.text, required this.isMe, required this.isRead, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () => onTap(),
            child: Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
              elevation: 5.0,
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black54,
                        fontSize: 15.0,
                      ),
                    ),
                    if (!isRead && !isMe)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          'Belum dibaca',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
