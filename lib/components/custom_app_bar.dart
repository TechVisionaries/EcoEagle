import 'package:flutter/material.dart';

class CustomAppBar {
  static AppBar appBar(String title,
      {List<Widget>? actions, PreferredSizeWidget? bottom}) {
    return (AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold, // Bold text
          color: Colors.white, // White text color
        ),
      ),
      centerTitle: true,
      foregroundColor: Colors.white,
      backgroundColor: const Color.fromARGB(255, 94, 189, 149),
      elevation: 0,
      actions: actions,
      bottom: bottom,
    ));
  }
}
