import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import added

class ChatScreen extends StatelessWidget {
  final String boardName;
  final TextEditingController _messageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  ChatScreen({required this.boardName});

  // Function to send a message
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      return; // Do nothing if the message is empty
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      await _firestore.collection('messages').add({
        'board': boardName,
        'message': message.trim(),
        'username': user?.email ?? 'Anonymous',
        'datetime': DateTime.now(),
        'userId': user?.uid,
      });
      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(boardName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('board', isEqualTo: boardName)
                  .orderBy('datetime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Show newest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageText = message['message'];
                    final messageUser = message['username'];
                    final messageTime = (message['datetime'] as Timestamp).toDate();
                    final isCurrentUser = message['userId'] == FirebaseAuth.instance.currentUser?.uid;

                    return _buildMessageBubble(
                      messageText: messageText,
                      username: messageUser,
                      timestamp: messageTime,
                      isCurrentUser: isCurrentUser,
                    );
                  },
                );
              },
            ),
          ),

          // Message Input Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to build a message bubble
  Widget _buildMessageBubble({
    required String messageText,
    required String username,
    required DateTime timestamp,
    required bool isCurrentUser,
  }) {
    final formattedTime = DateFormat('hh:mm a').format(timestamp);

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isCurrentUser ? Radius.circular(12) : Radius.zero,
            bottomRight: isCurrentUser ? Radius.zero : Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 4),
            Text(
              messageText,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
