import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:judica/profile.dart';
import 'package:judica/slpash_screen.dart';
import 'FIRpage.dart'; // Import your FIR page

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _selectedIndex = 0; // Tracks the selected tab
  bool _isUserDataChecked = false; // Flag to track if user data has been checked

  // Define the pages for navigation
  static final List<Widget> _pages = <Widget>[
    const Center(child: Text('Home Page Content')), // Placeholder for Home Page
    const FirComponent(), // FIR-related component
    const ProfilePage(), // Profile Page
  ];

  // Function to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Logout function
  void _logout() async {
    await FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.push(context, MaterialPageRoute(builder: (context)=>const SplashScreen()));
  }

  // Check user data in Firestore
  Future<void> _checkUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !_isUserDataChecked) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.email);
      final docSnapshot = await userDoc.get();

      // If document exists and all required data is present, set to Home page
      if (docSnapshot.exists &&
          docSnapshot.data()?['Mobile Number'] != null &&
          docSnapshot.data()?['email'] != null &&
          docSnapshot.data()?['username'] != null && // Fixed typo ('usernanme' to 'username')
          docSnapshot.data()?['role'] != null) {
        // User has complete data, stay on Home page
        setState(() {
          _selectedIndex = 0; // Set to Home tab if data is valid
          _isUserDataChecked = true;
        });
      } else {
        // If any data is missing, set to Profile page
        setState(() {
          _selectedIndex = 2; // Navigate to Profile Page if data is incomplete
          _isUserDataChecked = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserDetails(); // Check user details only once during initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Judica"),
        backgroundColor: const Color.fromRGBO(255, 125, 41, 1),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment), // Updated icon for FIR
            label: 'FIR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // Highlight the selected tab
        selectedItemColor: Colors.orange, // Selected icon color
        onTap: _onItemTapped, // Handle tab selection
      ),
    );
  }
}
