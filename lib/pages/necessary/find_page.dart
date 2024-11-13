import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:come_n_fix/components/loading_animation.dart';
import 'package:come_n_fix/repository/user_repository.dart';
import 'package:come_n_fix/services/order_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class FindPage extends StatefulWidget {
  final String service;
  final GeoPoint location;
  const FindPage({super.key, required this.service, required this.location});

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  final TextEditingController _searchController = TextEditingController();
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  final OrderService orderService = new OrderService();
  final UserRepository userRep = new UserRepository();

  List _allResults = [];
  List _resultList = [];

  void _hire(String providerId) async {
    await orderService.hireProvider(providerId, widget.service);
    Navigator.pop(context);
  }

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  Stream<List<DocumentSnapshot>> _nearbyResultList() {
    final _geo = GeoFlutterFire();
    final _firestore = FirebaseFirestore.instance;
    GeoFirePoint center = _geo.point(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude);
    double radius = 250;

    var _collectionReference = _firestore.collection('users');
    Stream<List<DocumentSnapshot>> stream =
        _geo.collection(collectionRef: _collectionReference).within(
              center: center,
              radius: radius,
              field: 'location',
            );

    return stream;
  }

  _onSearchChanged() {
    print(_searchController.text);
    _searchResultList();
  }

  _searchResultList() {
    var showResults = [];
    if (_searchController.text != "") {
      for (var clientSnapShot in _allResults) {
        var username = clientSnapShot['username'].toString().toLowerCase();
        if (username.contains(_searchController.text.toLowerCase())) {
          showResults.add(clientSnapShot);
        }
      }
    }

    setState(() {
      _resultList = showResults;
    });
  }

  _getClientStream() async {
    var data = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Provider')
        .where('services', arrayContains: widget.service)
        .orderBy('username')
        .get();

    setState(() {
      _allResults = data.docs;
    });

    _searchResultList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _getClientStream();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: CupertinoSearchTextField(
            controller: _searchController,
            prefixIcon: Icon(Icons.search),
            suffixIcon: Icon(Icons.clear),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: _awaitData(),
    );
  }

  Widget _awaitData() {
    return StreamBuilder<List>(
        stream: _nearbyResultList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingAnimation();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Text('No data found for user');
          } else {
            List _nearbyList = snapshot.data!;
            return (_searchController.text.trim() == '')
                ? _nearYou(_nearbyList)
                : _searchResult();
          }
        });
  }

  Widget _nearYou(List _nearbyList) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text('Recommended: Near your Location'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _nearbyList.length,
            itemBuilder: (context, index) {
              return (_nearbyList[index]['role'] == 'Provider' &&
                      _nearbyList[index]['services'].contains(widget.service) &&
                      (_nearbyList[index]['address'] != '-' &&
                          _nearbyList[index]['description'] != '-' &&
                          _nearbyList[index]['gender'] != '-' &&
                          _nearbyList[index]['location'] != '-' &&
                          _nearbyList[index]['phoneNumber'] != '-'))
                  ? ListTile(
                      onTap: () {
                        _providerDetail(_nearbyList[index]);
                      },
                      title: Text(_nearbyList[index]['username']),
                      subtitle: Text(_nearbyList[index]['address']),
                      trailing: GestureDetector(
                        onTap: () {
                          if (_nearbyList[index]['active'])
                            _hire(_nearbyList[index].id);
                        },
                        child: Text(
                          (_nearbyList[index]['active']) ? 'Hire' : 'Busy',
                          style: TextStyle(
                              color: Color.fromARGB(255, 143, 90, 38),
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                    )
                  : Container();
            },
          ),
        ),
      ],
    );
  }

  Widget _searchResult() {
    return ListView.builder(
      itemCount: _resultList.length,
      itemBuilder: (context, index) {
        return (_resultList[index]['address'] != '-' &&
                _resultList[index]['description'] != '-' &&
                _resultList[index]['gender'] != '-' &&
                _resultList[index]['location'] != '-' &&
                _resultList[index]['phoneNumber'] != '-')
            ? ListTile(
                onTap: () {
                  _providerDetail(_resultList[index]);
                },
                title: Text(_resultList[index]['username']),
                subtitle: Text(_resultList[index]['address']),
                trailing: GestureDetector(
                  onTap: () {
                    if (_resultList[index]['active'])
                      _hire(_resultList[index].id);
                  },
                  child: Text(
                    (_resultList[index]['active']) ? 'Hire' : 'Busy',
                    style: TextStyle(
                        color: Color.fromARGB(255, 143, 90, 38),
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              )
            : Container();
      },
    );
  }

  _providerDetail(var userDetail) async {
    var reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('providerId', isEqualTo: userDetail.id)
        .get();

    List<Map<String, dynamic>> reviews =
        reviewsSnapshot.docs.map((doc) => doc.data()).toList();

    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            width: double.infinity,
            height: 800,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                children: [
                  Container(
                    height: 8,
                    width: 90,
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 72, 71, 76),
                        border: Border.all(
                          color: Color.fromARGB(255, 72, 71, 76),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text('${userDetail['services'].join(', ')}'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          '${userDetail['profileUrl']}',
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Image.asset(
                                'assets/images/profilePlaceholder.png'); // Fallback image
                          },
                        ),
                      ),
                    ),
                  ),
                  Text(userDetail['username']),
                  Text('Location: ${userDetail['address']}'),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Container(
                      height: 70,
                      width: 260,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          border: Border.all(
                            color: Color.fromARGB(255, 72, 71, 76),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          userDetail['description'],
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  (userDetail['rating'] == 0)
                      ? Text('No rating yet')
                      : Text(
                          'Total Rating: ${userDetail['rating']}/5 by ${userDetail['rateAmount']} User'),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        var review = reviews[index];
                        return ListTile(
                          leading: Icon(Icons.star, color: Colors.amber),
                          title: Text(
                              '${review['rating']}/5 by ${review['customerName']}'),
                          subtitle: Text((review['comment'] != "") ? '${review['comment']}' : '-'),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
