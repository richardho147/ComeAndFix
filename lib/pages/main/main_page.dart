import "package:come_n_fix/components/loading_animation.dart";
import "package:come_n_fix/pages/chat/chat_page.dart";
import "package:come_n_fix/pages/main/order_page.dart";
import "package:come_n_fix/pages/main/home_page.dart";
import "package:come_n_fix/pages/main/profile_page.dart";
import "package:come_n_fix/pages/main/schedule_page.dart";
import "package:come_n_fix/repository/user_repository.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final user = FirebaseAuth.instance.currentUser;
  List<Widget> pages = [];
  final UserRepository userRep = new UserRepository();
  int index = 0;
  String role = '';

  void _logUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> _fetchUserRole() async {
    String currentUid = user!.uid;
    String temp = await userRep.getUserRole(currentUid);
    setState(() {
      role = temp;
      if(role == 'Provider'){
        pages = [
          OrderPage(),
          // SchedulePage(),
          ChatPage(),
          ProfilePage(),
        ];
      }
      else{
        pages = [
          HomePage(),
          ChatPage(),
          OrderPage(),
          ProfilePage(),
        ];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BantuAja',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(onPressed: _logUserOut, icon: Icon(Icons.logout))],
        backgroundColor: Color.fromARGB(255, 124, 102, 89),
        foregroundColor: Colors.white,
      ),
      body: role == '' ? Center(child: LoadingAnimation()) : pages[index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Color.fromARGB(255, 212, 190, 169),
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
        child: NavigationBar(
          height: 60,
          backgroundColor: Color.fromARGB(255, 124, 102, 89),
          selectedIndex: index,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          animationDuration: Duration(seconds: 1),
          onDestinationSelected: (index) => setState(() {
            this.index = index;
          }),
          destinations: getNavigationDestinations(),
        ),
      ),
    );
  }

  List<NavigationDestination> getNavigationDestinations() {
    if (role == 'Provider') {
      return [
        NavigationDestination(
          icon: Icon(Icons.receipt, color: Colors.white),
          selectedIcon: Icon(Icons.receipt),
          label: 'Order',
        ),
        // NavigationDestination(
        //   icon: Icon(Icons.date_range_outlined, color: Colors.white),
        //   selectedIcon: Icon(Icons.date_range_rounded),
        //   label: 'Schedule',
        // ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
          selectedIcon: Icon(Icons.chat),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.person, color: Colors.white),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      return [
        NavigationDestination(
          icon: Icon(Icons.home, color: Colors.white),
          selectedIcon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
          selectedIcon: Icon(Icons.chat),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt, color: Colors.white),
          selectedIcon: Icon(Icons.receipt),
          label: 'Order',
        ),
        NavigationDestination(
          icon: Icon(Icons.person, color: Colors.white),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }
}
