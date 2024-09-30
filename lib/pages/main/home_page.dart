import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:come_n_fix/components/loading_animation.dart';
import 'package:come_n_fix/components/promo_box.dart';
import 'package:come_n_fix/pages/necessary/find_page.dart';
import 'package:come_n_fix/pages/necessary/select_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentId = FirebaseAuth.instance.currentUser!.uid;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  final List<Map<String, dynamic>> services = [
    {'service': 'Plumbing', 'icon': Icons.plumbing},
    {'service': 'Electrical', 'icon': Icons.electric_bolt},
    {'service': 'HVAC', 'icon': Icons.wind_power},
    {'service': 'Roofing', 'icon': Icons.roofing},
    {'service': 'Painting', 'icon': Icons.format_paint},
    {'service': 'Yardwork', 'icon': Icons.grass},
    {'service': 'Pest', 'icon': Icons.pest_control},
    {'service': 'Cleaning', 'icon': Icons.cleaning_services},
  ];

  final List<Map<String, dynamic>> promos = [
    {
      'promo': 'Diskon 40%',
      'description': 'Pembayaran menggunakan Livin Mandiri',
      'photo':
          'https://i.pinimg.com/originals/f9/c6/db/f9c6db38f1aff57e6881994f261c81f1.jpg',
    },
    {
      'promo': 'Diskon hingga 66%',
      'description': 'Khusus penggunaan Debit / Credit BCA',
      'photo':
          'https://statik.tempo.co/data/2023/02/20/id_1182500/1182500_720.jpg',
    },
    {
      'promo': 'Potongan Harga sampai Rp50.000',
      'description': 'Gunakan Permata untuk potongan harga',
      'photo': 'https://pbs.twimg.com/media/FcRu2fjaQAApJrZ.jpg:large',
    },
  ];

  Future<void> _checkLocation(String service) async {
    try {
      DocumentSnapshot documentSnapshot =
          await usersCollection.doc(currentId).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> userDetail =
            documentSnapshot.data() as Map<String, dynamic>;
        if (userDetail['location'] == '-' || userDetail['address'] == '-') {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectLocationPage(),
              ));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FindPage(
                    service: service,
                    location: userDetail['location']['geopoint']),
              ));
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
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
            return (userDetail['role'] == 'Provider')
                ? _providerView(userDetail)
                : _customerView(userDetail);
          }
        });
  }

  Widget _providerView(Map<String, dynamic> userDetail) {
    return Center(
      child: Text('Home Page'),
    );
  }

  Widget _customerView(Map<String, dynamic> userDetail) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Text(
              'Hi ${userDetail['username']},\nWelcome to BantuAja',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Text(
              'What can we help you on?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            width: double.infinity,
            height: 192,
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                itemCount: (services.length / 4).ceil(),
                itemBuilder: (BuildContext context, int index) {
                  int startIndex = index * 4;
                  int endIndex = startIndex + 4;
                  if (endIndex > services.length) endIndex = services.length;

                  List<Map<String, dynamic>> sublist =
                      services.sublist(startIndex, endIndex);

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: sublist.map((map) {
                        return Container(
                          width: 70.0,
                          height: 90.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _checkLocation(map['service']),
                                child: Container(
                                  width: 70.0,
                                  height: 70.0,
                                  child: Icon(map['icon']),
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 212, 190, 169),
                                      border: Border.all(
                                        color: Color.fromARGB(255, 72, 71, 76),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                              Text(map['service']!),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 10.0),
            child: Text(
              'Promo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: promos.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                      child: PromoBox(
                          padding: EdgeInsets.fromLTRB(20.0, 0,
                              index == promos.length - 1 ? 20.0 : 0.0, 0),
                          promoPhoto: promos[index]['photo'],
                          promo: promos[index]['promo'],
                          promoDescription: promos[index]['description']));
                }),
          ),
          SizedBox(
            height: 40.0,
          )
        ],
      ),
    );
  }
}
