import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:come_n_fix/components/chat_bubble.dart';
import 'package:come_n_fix/components/input_text_field.dart';
import 'package:come_n_fix/components/loading_animation.dart';
import 'package:come_n_fix/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IndividualChatPage extends StatefulWidget {
  final String receiverUserId;
  final String receiverUsername;
  final String senderUsername;
  const IndividualChatPage(
      {super.key,
      required this.receiverUserId,
      required this.receiverUsername,
      required this.senderUsername});

  @override
  State<IndividualChatPage> createState() => _IndividualChatPageState();
}

class _IndividualChatPageState extends State<IndividualChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverUserId,
          widget.senderUsername, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverUsername,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 124, 102, 89),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput(),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
            widget.receiverUserId, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error' + snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingAnimation();
          }

          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    var mainAxisAlignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;
    var crossAxisAlignment =
        (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start;

    return Container(
      alignment: alignment,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            data['senderUsername'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5,
          ),
          ChatBubble(
              message: data['message'],
              owner: (data['senderUsername'] == widget.senderUsername)
                  ? true
                  : false),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      child: Row(children: [
        Expanded(
            child: InputTextField(
          controller: _messageController,
          hintText: 'Enter message',
          obscureText: false,
          paddingSize: 5,
        )),
        Container(
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 124, 102, 89), shape: BoxShape.circle),
          child: IconButton(
            onPressed: sendMessage,
            icon: Icon(
              Icons.arrow_upward,
              size: 25,
              color: Colors.white,
              weight: 20,
            ),
          ),
        ),
      ]),
    );
  }
}
