import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(title: Text('Message Boards'), onTap: () => Navigator.pushNamed(context, '/home')),
          ListTile(title: Text('Profile'), onTap: () => Navigator.pushNamed(context, '/profile')),
          ListTile(title: Text('Settings'), onTap: () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
    );
  }
}
