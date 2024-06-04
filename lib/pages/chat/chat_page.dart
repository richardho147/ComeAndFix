import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:come_n_fix/components/loading_animation.dart';
import 'package:come_n_fix/pages/chat/individual_chat_page.dart';
import 'package:come_n_fix/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  final UserRepository userRep = new UserRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingAnimation();
        }

        var users =
            snapshot.data!.docs.where((doc) => doc.id != currentUid).toList();

        return FutureBuilder<List<bool>>(
          future: Future.wait(users.map((doc) => _hasMessages(doc.id))),
          builder: (context, hasMessagesSnapshots) {
            if (hasMessagesSnapshots.connectionState ==
                ConnectionState.waiting) {
              return LoadingAnimation();
            }

            bool hasAnyMessages =
                hasMessagesSnapshots.data!.any((hasMessages) => hasMessages);

            return hasAnyMessages
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Text(
                          'Chats',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                          child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          var doc = users[index];
                          var hasMessages = hasMessagesSnapshots.data![index];

                          if (hasMessages) {
                            return _buildUserListItem(doc);
                          } else {
                            return Container();
                          }
                        },
                      )),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/noChat.jpg'),
                          width: 380,
                        ),
                        Text(
                          'You Haven\'t Contacted Anyone',
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 124, 102, 89),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
          },
        );
      },
    );
  }

  // Widget build(BuildContext context) {
  //   return StreamBuilder<QuerySnapshot>(
  //       stream: FirebaseFirestore.instance.collection('users').snapshots(),
  //       builder: (context, snapshot) {
  //         if (snapshot.hasError) {
  //           return const Text('error');
  //         }
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return LoadingAnimation();
  //         }

  //         return Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Padding(
  //               padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
  //               child: Text(
  //                 'Chats',
  //                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //             Expanded(
  //               child: ListView(
  //                 children: snapshot.data!.docs
  //                     .map<Widget>((doc) => FutureBuilder<bool>(
  //                         future: _hasMessages(doc.id),
  //                         builder: (context, hasMessagesSnapshot) {
  //                           if (hasMessagesSnapshot.connectionState ==
  //                               ConnectionState.waiting) {
  //                             return Container();
  //                           }
  //                           if (hasMessagesSnapshot.data == true) {
  //                             return _buildUserListItem(doc);
  //                           }
  //                           return Container();
  //                         }))
  //                     .toList(),
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    if (currentUid != document.id) {
      return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                '${data['profile url']}',
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Image.asset(
                      'assets/images/profilePlaceholder.png'); // Fallback image
                },
              ),
            ),
            title: Text(data['username']),
            onTap: () async {
              String username = await userRep.getUserName(currentUid);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IndividualChatPage(
                      receiverUserId: document.id,
                      receiverUsername: data['username'],
                      senderUsername: username,
                    ),
                  ));
            }),
      );
    } else {
      return Container();
    }
  }

  Future<bool> _hasMessages(String userId) async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('chat_rooms').get();
    for (var doc in querySnapshot.docs) {
      var text = doc.id.split('_');

      if ((text[0] == userId && text[1] == currentUid) ||
          (text[0] == currentUid && text[1] == userId)) {
        return true;
      }
    }

    return false;
  }
}


// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final String currentUid = FirebaseAuth.instance.currentUser!.uid;
//   final UserRepository userRep = new UserRepository();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('users').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Text('error');
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return LoadingAnimation();
//           }

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
//                 child: Text(
//                   'Chats',
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Expanded(
//                 child: ListView(
//                   children: snapshot.data!.docs
//                       .map<Widget>((doc) => FutureBuilder<bool>(
//                           future: _hasMessages(doc.id),
//                           builder: (context, hasMessagesSnapshot) {
//                             if (hasMessagesSnapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return Container();
//                             }
//                             if (hasMessagesSnapshot.data == true) {
//                               return _buildUserListItem(doc);
//                             }
//                             return Container();
//                           }))
//                       .toList(),
//                 ),
//               ),
//             ],
//           );
//         });
//   }

//   Widget _buildUserListItem(DocumentSnapshot document) {
//     Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
//     if (currentUid != document.id) {
//       return Padding(
//         padding: const EdgeInsets.only(top: 20.0),
//         child: ListTile(
//             leading: ClipRRect(
//               borderRadius: BorderRadius.circular(100),
//               child: Image.network(
//                 '${data['profile url']}',
//                 errorBuilder: (BuildContext context, Object exception,
//                     StackTrace? stackTrace) {
//                   return Image.asset(
//                       'assets/images/profilePlaceholder.png'); // Fallback image
//                 },
//               ),
//             ),
//             title: Text(data['username']),
//             onTap: () async {
//               String username = await userRep.getUserName(currentUid);
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => IndividualChatPage(
//                       receiverUserId: document.id,
//                       receiverUsername: data['username'],
//                       senderUsername: username,
//                     ),
//                   ));
//             }),
//       );
//     } else {
//       return Container();
//     }
//   }

//   Future<bool> _hasMessages(String userId) async {
//     final querySnapshot =
//         await FirebaseFirestore.instance.collection('chat_rooms').get();
//     for (var doc in querySnapshot.docs) {
//       var text = doc.id.split('_');

//       if ((text[0] == userId && text[1] == currentUid) ||
//           (text[0] == currentUid && text[1] == userId)) {
//         return true;
//       }
//     }

//     return false;
//   }
// }
