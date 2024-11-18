import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'app_drawer.dart';

class MessageBoardsScreen extends StatelessWidget {
  final List<Map<String, String>> boards = [
    {'name': 'General', 'icon': 'icon_url_1'},
    {'name': 'Announcements', 'icon': 'icon_url_2'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Message Boards')),
      body: ListView.builder(
        itemCount: boards.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.forum), 
            title: Text(boards[index]['name']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(boardName: boards[index]['name']!),
                ),
              );
            },
          );
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
