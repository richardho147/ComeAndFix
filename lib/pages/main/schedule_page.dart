import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:come_n_fix/components/loading_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final currentId = FirebaseAuth.instance.currentUser!.uid;
  
  DateTime today = DateTime.now();

  void _onDaySelected(DateTime day, DateTime focusedDay){
    setState(() {
      today = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
                .collection('transactions')
                .where('provider_id', isEqualTo: currentId)
                .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Container();
          } else {
            List<Map<String, dynamic>> transactions = snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

            return _viewSchedule(transactions);
          }
        });
  }

  Widget _viewSchedule(List<Map<String, dynamic>> transactions) {
    List<Map<String, dynamic>> filteredTransactions = transactions.where((transaction) {
      Timestamp transactionTime = transaction['time'];
      DateTime transactionDate = transactionTime.toDate();

      return transactionDate.year == today.year &&
            transactionDate.month == today.month &&
            transactionDate.day == today.day;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            child: TableCalendar(
              locale:"en_US",
              rowHeight: 43,
              headerStyle: 
                HeaderStyle(formatButtonVisible: false, titleCentered: true),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, today),
              focusedDay: today,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2050, 1, 1),
              onDaySelected: _onDaySelected,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color.fromARGB(255, 212, 190, 169),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color.fromARGB(255, 124, 102, 89),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(height: 13.0,),
          Container(
            height: 30.0,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 124, 102, 89),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                'Your Schedule',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          (filteredTransactions.isEmpty)?
          Container(
            height: 250.0,
            child: Center(
              child: Text(
                'You have no schedule for this date'
              ),
            ),
          )
          :
          Expanded(
            child: ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> transaction = filteredTransactions[index];
                  return ListTile(
                    title: Text('Customer: ${transaction['customer name']}'),
                    subtitle: Text('Service: ${transaction['service'].toString()}'),
                    trailing: Text((transaction['status'] == 'rated') ? 
                                    'Finished':'Unfinish'),
                  );
              },
            ),
          ),
        ],
      )
    );
  }
}