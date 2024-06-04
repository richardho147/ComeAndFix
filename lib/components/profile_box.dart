import 'package:flutter/material.dart';

class ProfileBox extends StatelessWidget {
  final String section;
  final String text;
  final void Function()? onPressed;
  const ProfileBox(
      {super.key,
      required this.section,
      required this.text,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.only(left: 15, bottom: 15),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                section,
                style: TextStyle(color: Colors.grey[500]),
              ),
              IconButton(
                onPressed: onPressed,
                icon: Icon(Icons.settings),
                color: Colors.grey[400],
              )
            ],
          ),
          Text(text),
        ],
      ),
    );
  }
}
