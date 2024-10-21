import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class UserRepository {
  Future<String> getUserRole(String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (documentSnapshot.exists) {
      return documentSnapshot.get('role') as String;
    } else {
      print('No user data found for the current user.');
      return 'null';
    }
  }

  Future<double> getUserRating(String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (documentSnapshot.exists) {
      if(documentSnapshot.get('rating').runtimeType == int){
        return (documentSnapshot.get('rating') as int).toDouble();
      }
      return documentSnapshot.get('rating');
    } else {
      print('No user data found for the current user.');
      return 0;
    }
  }

  Future<int> getUserRateAmount(String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (documentSnapshot.exists) {
      return documentSnapshot.get('rateAmount');
    } else {
      print('No user data found for the current user.');
      return 0;
    }
  }

  Future<String> getUserName(String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (documentSnapshot.exists) {
      return documentSnapshot.get('username') as String;
    } else {
      print('No user data found for the current user.');
      return 'null';
    }
  }

  Future<List> getNearbyUser(var data, GeoPoint location) async {
    final _geo = GeoFlutterFire();
    final _firestore = FirebaseFirestore.instance;
    GeoFirePoint center =
        _geo.point(latitude: location.latitude, longitude: location.longitude);
    double radius = 50;

    var _collectionReference = _firestore.collection('users');
    List<DocumentSnapshot> nearbyUsers = [];
    Stream<List<DocumentSnapshot>> stream =
        _geo.collection(collectionRef: _collectionReference).within(
              center: center,
              radius: radius,
              field: 'location',
              strictMode: true,
            );

    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((DocumentSnapshot document) {
        print('${document.data()}');
      });
    });

    await for (List<DocumentSnapshot> snapshotList in stream) {
      nearbyUsers.addAll(snapshotList);
    }
    

    return nearbyUsers;
  }
}
