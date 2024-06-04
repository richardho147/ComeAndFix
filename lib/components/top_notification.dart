import 'package:flutter/material.dart';

class TopNotification extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;

  TopNotification({
    required this.message,
    this.backgroundColor = Colors.red,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        color: backgroundColor,
        child: Text(
          message,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}