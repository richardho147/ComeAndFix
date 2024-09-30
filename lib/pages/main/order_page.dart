import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:come_n_fix/components/loading_animation.dart';
import 'package:come_n_fix/components/payment_choice.dart';
import 'package:come_n_fix/pages/chat/individual_chat_page.dart';
import 'package:come_n_fix/repository/user_repository.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final currentId = FirebaseAuth.instance.currentUser!.uid;
  final _firestore = FirebaseFirestore.instance;
  final UserRepository userRep = new UserRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(currentId).snapshots(),
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
            if (userDetail['role'] == 'Provider' &&
                (userDetail['address'] == '-' ||
                    userDetail['description'] == '-' ||
                    userDetail['gender'] == '-' ||
                    userDetail['location'] == '-' ||
                    userDetail['phone number'] == '-' ||
                    userDetail['services'].isEmpty)) {
              return _fillInformation();
            } else {
              return _checkTransaction(userDetail);
            }
          }
        });
  }

  Widget _fillInformation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            image: AssetImage('assets/images/fillProfile.jpg'),
            width: 300,
          ),
          Text(
            'Fill all your information at Profile Page',
            style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 124, 102, 89),
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _checkTransaction(Map<String, dynamic> userDetail) {
    return StreamBuilder<QuerySnapshot>(
        stream: (userDetail['role'] == 'Provider')
            ? FirebaseFirestore.instance
                .collection('transactions')
                .where('provider_id', isEqualTo: currentId)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('transactions')
                .where('customer id', isEqualTo: currentId)
                .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingAnimation();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Text('No data found for user');
          } else {
            List<Map<String, dynamic>> transactions = snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
            return (transactions.isEmpty)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/noOrder.jpg'),
                          width: 400,
                        ),
                        Text(
                          (userDetail['role'] == 'Provider')
                              ? 'No Order Yet'
                              : 'You have not hired anyone',
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 124, 102, 89),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _orderBar(transactions[index], userDetail);
                    });
          }
        });
  }

  Widget _orderBar(
      Map<String, dynamic> transaction, Map<String, dynamic> userDetail) {
    String role = userDetail['role'];
    String title = (role == 'Provider')
        ? '${transaction['service']} Service to Customer ${transaction['customer name']}'
        : '${transaction['service']} Service by Fixer ${transaction['provider name']}';

    String subtitle = '';
    if (transaction['status'] == 'negotiation') {
      subtitle = (role == 'Provider')
          ? 'Discuss with your Customer, Set your Price'
          : 'Discuss with your Fixer';
    } else if (transaction['status'] == 'settlement') {
      subtitle = (role == 'Provider')
          ? 'Wait for Customer to pay'
          : 'Pay for the agreed price';
    } else if (transaction['status'] == 'settled') {
      subtitle = (role == 'Provider')
          ? 'Fixed Customer problem, then Confirm'
          : 'Wait for Fixer to fixed the problem';
    } else if (transaction['status'] == 'fixed') {
      subtitle = (role == 'Provider')
          ? 'Wait for Customer to confirm your work'
          : 'Confirm that Fixer have fixed the problem';
    } else if (transaction['status'] == 'done' ||
        transaction['status'] == 'rated') {
      title = (role == 'Provider')
          ? 'You have finished fixing ${transaction['customer name']} ${transaction['service']} problem'
          : '${transaction['provider name']} have finished fixing your ${transaction['service']} problem';
      subtitle =
          'Price: ${transaction['price']}, Paid by ${transaction['payment type']}';
    }

    Widget whatButton() {
      if (transaction['status'] == 'negotiation') {
        if (role == 'Provider') {
          return GestureDetector(
            onTap: () {
              _setPrice(
                  '${transaction['provider_id']}_${transaction['customer id']}');
            },
            child: Icon(Icons.monetization_on,
                color: Color.fromARGB(255, 124, 102, 89)),
          );
        } else {
          return GestureDetector(
            onTap: () {
              _tellSomething('negotiation');
            },
            child: Icon(Icons.hourglass_empty,
                color: Color.fromARGB(255, 124, 102, 89)),
          );
        }
      } else if (transaction['status'] == 'settlement') {
        if (role == 'Provider') {
          return GestureDetector(
            onTap: () {
              _tellSomething('settlement');
            },
            child: Icon(Icons.hourglass_empty,
                color: Color.fromARGB(255, 124, 102, 89)),
          );
        } else {
          return GestureDetector(
            onTap: () {
              _setPayment(
                  '${transaction['provider_id']}_${transaction['customer id']}',
                  transaction['price']);
            },
            child: Icon(Icons.handshake_outlined,
                color: Color.fromARGB(255, 124, 102, 89)),
          );
        }
      } else if (transaction['status'] == 'settled') {
        if (role == 'Provider') {
          return GestureDetector(
            onTap: () {
              _confirmTransaction(
                  '${transaction['provider_id']}_${transaction['customer id']}',
                  userDetail['role']);
            },
            child: Icon(Icons.check, color: Color.fromARGB(255, 124, 102, 89)),
          );
        } else {
          return GestureDetector(
            onTap: () {
              _tellSomething('settled');
            },
            child: Icon(Icons.hourglass_empty,
                color: Color.fromARGB(255, 124, 102, 89)),
          );
        }
      } else if (transaction['status'] == 'fixed') {
        if (role == 'Provider') {
          return GestureDetector(
            onTap: () {
              _tellSomething('fixed');
            },
            child: Icon(Icons.hourglass_empty,
                color: Color.fromARGB(255, 124, 102, 89)),
          );
        } else {
          return GestureDetector(
            onTap: () {
              _confirmTransaction(
                  '${transaction['provider_id']}_${transaction['customer id']}',
                  userDetail['role']);
            },
            child: Icon(Icons.check, color: Color.fromARGB(255, 124, 102, 89)),
          );
        }
      } else if (transaction['status'] == 'done' && role != 'Provider') {
        return GestureDetector(
          onTap: () {
            _rateProvider(
                transaction['provider_id'],
                transaction['provider name'],
                '${transaction['provider_id']}_${transaction['customer id']}');
          },
          child: Icon(Icons.star, color: Color.fromARGB(255, 124, 102, 89)),
        );
      } else {
        return Container();
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(
                255, 212, 190, 169), // Set the color of the border
            width: 1.0, // Set the width of the border
          ),
        ),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: (transaction['status'] == 'done' ||
                transaction['status'] == 'rated')
            ? (transaction['status'] == 'rated')
                ? SizedBox.shrink()
                : (userDetail['role'] == 'Provider') 
                  ? SizedBox.shrink()
                  : whatButton()
            : Container(
                width: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IndividualChatPage(
                                receiverUserId: (role == 'Provider')
                                    ? transaction['customer id']
                                    : transaction['provider_id'],
                                receiverUsername: (role == 'Provider')
                                    ? transaction['customer name']
                                    : transaction['provider name'],
                                senderUsername: (role == 'Provider')
                                    ? transaction['provider name']
                                    : transaction['customer name'],
                              ),
                            ));
                      },
                      child: Icon(Icons.chat,
                          color: Color.fromARGB(255, 124, 102, 89)),
                    ),
                    whatButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _tellSomething(String status) async {
    String text = '';
    if (status == 'negotiation')
      text = "Fixer need to set the price for this order";
    else if (status == 'settlement')
      text = "Wait for Customer to pay";
    else if (status == 'settled')
      text = "Wait for Fixer confirm that your problem have been fixed";
    else if (status == 'fixed')
      text = "Customer need to confirm to finish this order";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 124, 102, 89),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text('I Understand', style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

  Future<void> _rateProvider(
      String providerId, String providerName, String transactionId) async {
    double newValue = -1;
    double rating = await userRep.getUserRating(providerId);
    int rateAmount = await userRep.getUserRateAmount(providerId);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 124, 102, 89),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          "Rate $providerName",
          style: TextStyle(color: Colors.white),
        ),
        content: Container(
          height: 30,
          child: RatingBar(
            maxRating: 5,
            filledIcon: Icons.star,
            emptyIcon: Icons.star_border,
            onRatingChanged: (value) => newValue = value,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white))),
          TextButton(
              onPressed: () async {
                Navigator.of(context).pop(newValue);
                if (newValue >= 0) {
                  await _firestore.collection('users').doc(providerId).update({
                    'rating': ((newValue + (rating * rateAmount)) /
                        (rateAmount + 1)),
                    'rate amount': (rateAmount + 1)
                  });
                  await _firestore
                      .collection('transactions')
                      .doc(transactionId)
                      .update({'status': 'rated'});
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

  Future<void> _confirmTransaction(String transactionId, String role) async {
    String newValue = (role == 'Provider') ? 'fixed' : 'done';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 124, 102, 89),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          (role == 'Provider')
              ? 'Confirm that you finished fixing?'
              : 'Confirm your problem have been fixed?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No', style: TextStyle(color: Colors.white))),
          TextButton(
              onPressed: () async {
                Navigator.of(context).pop(newValue);
                await _firestore
                    .collection('transactions')
                    .doc(transactionId)
                    .update({'status': newValue});
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

  Future<void> _setPayment(String transactionId, int price) async {
    String newValue = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 124, 102, 89),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          "Choose Your Payment Method",
          style: TextStyle(color: Colors.white),
        ),
        content: Container(
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaymentChoice(
                onPaymentSelected: (selectedPayment) {
                  setState(() {
                    newValue = selectedPayment;
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Confirm your payment of ${price}?',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white))),
          TextButton(
              onPressed: () async {
                Navigator.of(context).pop(newValue);
                if (newValue.trim().length > 0) {
                  await _firestore
                      .collection('transactions')
                      .doc(transactionId)
                      .update({'payment type': newValue, 'status': 'settled'});
                }
              },
              child: Text('Yes', style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

  Future<void> _setPrice(String transactionId) async {
    int newValue = -1;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 124, 102, 89),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          "Set Price",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Enter price on negotiation",
            hintStyle: TextStyle(color: Colors.grey[600]),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          onChanged: (value) {
            if (value.isNotEmpty)
            newValue = int.parse(value);
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white))),
          TextButton(
              onPressed: () async {
                Navigator.of(context).pop(newValue);
                if (newValue >= 0) {
                  await _firestore
                      .collection('transactions')
                      .doc(transactionId)
                      .update({'price': newValue, 'status': 'settlement'});
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }
}
