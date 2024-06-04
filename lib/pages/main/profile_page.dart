import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:come_n_fix/components/loading_animation.dart';
import 'package:come_n_fix/components/profile_box.dart';
import 'package:come_n_fix/components/services_edit.dart';
import 'package:come_n_fix/pages/necessary/select_location.dart';
import 'package:come_n_fix/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentId = FirebaseAuth.instance.currentUser!.uid;
  final currentEmail = FirebaseAuth.instance.currentUser!.email;
  final UserRepository userRep = new UserRepository();
  final usersCollection = FirebaseFirestore.instance.collection('users');

  var _providerServices = [];

  Future<void> editField(String field) async {
    String newValue = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 72, 71, 76),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          "Edit $field",
          style: TextStyle(color: Colors.white),
        ),
        content: (field == 'services')
            ? ServicesEdit(
                onServiceSelected: (selectedServices) {
                  setState(() {
                    _providerServices = selectedServices;
                  });
                },
              )
            : TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter new $field",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  newValue = value;
                },
              ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white))),
          (field == 'services')
              ? TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(_providerServices);
                    if (_providerServices.isNotEmpty) {
                      await usersCollection
                          .doc(currentId)
                          .update({field: _providerServices});
                    }
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white)))
              : TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(newValue);
                    if (newValue.trim().length > 0) {
                      await usersCollection
                          .doc(currentId)
                          .update({field: newValue});
                    }
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

  Future<void> _onProfileEdit() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imageBytes = await image.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return;

    img.Image resizedImage =
        img.copyResize(originalImage, width: 200, height: 200);
    final resizedImageBytes = img.encodeJpg(resizedImage);

    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child("profile_pictures/$currentId.jpg");
    await imageRef.putData(Uint8List.fromList(resizedImageBytes));

    final imageUrl = await imageRef.getDownloadURL();

    usersCollection.doc(currentId).update({'profile url': imageUrl});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentId)
          .snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingAnimation();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('No data found for user');
        } else {
          Map<String, dynamic> userDetail =
              snapshot.data!.data() as Map<String, dynamic>;
          List<String> detailKeys = userDetail.keys.toList();
          return Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Stack(
                children: [
                  SizedBox(
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        '${userDetail['profile url']}',
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Image.asset(
                              'assets/images/profilePlaceholder.png'); // Fallback image
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _onProfileEdit,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Color.fromARGB(255, 212, 190, 169),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text('$currentEmail'),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My Profile',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    )),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: userDetail.length,
                    itemBuilder: (BuildContext context, int index) {
                      return (userDetail['role'] == 'Provider')
                          ? _providerView(userDetail, detailKeys, index)
                          : _customerView(userDetail, detailKeys, index);
                    }),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _providerView(
      Map<String, dynamic> userDetail, List<String> detailKeys, int index) {
    if (detailKeys[userDetail.length - 1 - index] == 'profile url' ||
        detailKeys[userDetail.length - 1 - index] == 'role' ||
        detailKeys[userDetail.length - 1 - index] == 'location' ||
        detailKeys[userDetail.length - 1 - index] == 'rate amount') {
      return Container();
    } else if (detailKeys[userDetail.length - 1 - index] == 'rating') {
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
                  'Rating',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.star),
                  color: Colors.grey[400],
                )
              ],
            ),
            Text(
                'Total Rating: ${userDetail['rating']}/5 by ${userDetail['rate amount']} User'),
          ],
        ),
      );
    } else if (detailKeys[userDetail.length - 1 - index] == 'services') {
      String services = userDetail['services'].join(', ');

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
                  'Services',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                IconButton(
                  onPressed: () => editField('services'),
                  icon: Icon(Icons.settings),
                  color: Colors.grey[400],
                )
              ],
            ),
            Text(services),
          ],
        ),
      );
    } else {
      return ProfileBox(
          section: detailKeys[userDetail.length - 1 - index].capitalize(),
          text: userDetail[detailKeys[userDetail.length - 1 - index]],
          onPressed: () =>
              (detailKeys[userDetail.length - 1 - index] == 'address')
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectLocationPage(),
                      ))
                  : editField(detailKeys[userDetail.length - 1 - index]));
    }
  }

  Widget _customerView(
      Map<String, dynamic> userDetail, List<String> detailKeys, int index) {
    return (detailKeys[userDetail.length - 1 - index] == 'profile url' ||
            detailKeys[userDetail.length - 1 - index] == 'role' ||
            detailKeys[userDetail.length - 1 - index] == 'location')
        ? Container()
        : ProfileBox(
            section: detailKeys[userDetail.length - 1 - index].capitalize(),
            text: userDetail[detailKeys[userDetail.length - 1 - index]],
            onPressed: () =>
                (detailKeys[userDetail.length - 1 - index] == 'address')
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectLocationPage(),
                        ))
                    : editField(detailKeys[userDetail.length - 1 - index]));
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + this.substring(1).toLowerCase();
  }
}
