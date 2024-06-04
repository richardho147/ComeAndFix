import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:come_n_fix/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserRepository userRep = new UserRepository();

  Future<void> hireProvider(String providerId, String service) async {
    final String customerId = _firebaseAuth.currentUser!.uid;

    List<String> ids = [providerId, customerId];
    String transactionId = ids.join("_");

    String providerName = await userRep.getUserName(providerId);
    String customerName = await userRep.getUserName(customerId);

    await _fireStore.collection('transactions').doc(transactionId).set({
      'provider id': providerId,
      'customer id': customerId,
      'provider name': providerName,
      'customer name': customerName,
      'status': 'negotiation',
      'service': service,
      'payment type': '-',
      'price': '-',
    });
  }
}
