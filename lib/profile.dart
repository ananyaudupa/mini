import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditMode = false;

  // User fields
  String? userName;
  String? email;
  String? role;
  String? mobileNumber;
  String? imageUrl;

  // Controllers for editable fields
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _requestPermissions();
  }
  Future<void> fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users') // Replace with your collection name
            .doc(currentUser.email) // Use email as the document ID
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc.data()?['username'];
            email = userDoc.data()?['email'];
            role = userDoc.data()?['role'];
            mobileNumber = userDoc.data()?['Mobile Number'];
            imageUrl = userDoc.data()?['imageUrl']; 
          });

          // Populate controllers for editing
          userNameController.text = userName ?? "";
          mobileNumberController.text = mobileNumber ?? "";
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
    }
  }
  Future<void> saveUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.email)
            .update({
          'username': userNameController.text.isNotEmpty
              ? userNameController.text
              : userName,
          'Mobile Number': mobileNumberController.text.isNotEmpty
              ? mobileNumberController.text
              : mobileNumber,
          'imageUrl': imageUrl, // Save the image URL
        });

        setState(() {
          userName = userNameController.text;
          mobileNumber = mobileNumberController.text;
          isEditMode = false; // Exit edit mode after saving
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving user data: $e");
      }
    }
  }

  // Toggle between edit mode and save mode
  void toggleEditMode() {
    if (isEditMode) {
      saveUserData(); // Save changes if in edit mode
    } else {
      setState(() {
        isEditMode = true; // Enter edit mode
      });
    }
  }

  // Request permissions for camera and storage
  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  // Pick an image from the gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, // You can also use ImageSource.camera
        maxWidth: 500,
        maxHeight: 500);

    if (pickedFile != null) {
      setState(() {
        imageUrl = pickedFile.path;
      });
      // Optionally, you can upload the image to Firebase Storage and save the URL
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 249, 246, 1),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // User avatar with enhanced style
                GestureDetector(
                  onTap: isEditMode ? _pickImage : null, // Allow picking image in edit mode
                  child: CircleAvatar(
                    radius: 85,  // Circle Avatar radius
                    backgroundColor: const Color.fromRGBO(255, 125, 41, 1), // Background color of the avatar
                    child: Padding(
                      padding: const EdgeInsets.all(8),  // Padding to create space between the border and the image
                      child: ClipOval(
                        // Clip the content to make it round
                        child: imageUrl != null
                            ? FractionallySizedBox(
                          alignment: Alignment.center,  // Centers the image within the CircleAvatar
                          widthFactor: 0.9,  // Scales down the width of the image (80% of the CircleAvatar size)
                          heightFactor: 0.9,  // Scales down the height of the image (80% of the CircleAvatar size)
                          child: Image.file(
                            // If an image URL is provided, display the image from the file
                            File(imageUrl!),
                            fit: BoxFit.cover,  // Ensures the image covers the entire CircleAvatar area
                          ),
                        )
                            : FractionallySizedBox(
                          alignment: Alignment.center,  // Centers the default image within the CircleAvatar
                          widthFactor: 0.9,  // Scales down the default image width (80% of the CircleAvatar size)
                          heightFactor: 0.9,  // Scales down the default image height (80% of the CircleAvatar size)
                          child:Icon(Icons.person,size: 80,),
                        ),
                      ),
                    ),
                  )

                ),
                const SizedBox(height: 30),
                // User name
                isEditMode
                    ? TextField(
                  controller: userNameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                )
                    : Text(
                  userName ?? "Your Name",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 30),
                // Email (Read-only)
                buildReadOnlyField("Email", email),
                // Role (Read-only)
                buildReadOnlyField("Role", role),
                // Mobile Number (Editable)
                isEditMode
                    ? buildEditableField(
                    "Mobile Number", mobileNumberController)
                    : buildReadOnlyField("Mobile Number", mobileNumber),
                const SizedBox(height: 30),
                // Save/Edit button with wider width
                ElevatedButton(
                  onPressed: toggleEditMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 125, 41, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50), // Increased width
                  ),
                  child: Text(isEditMode ? 'Save' : 'Edit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for read-only fields
  Widget buildReadOnlyField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Text(
          value ?? "Not provided",
          style: const TextStyle(fontSize: 15.0),
        ),
      ),
    );
  }
  // Widget for editable fields
  Widget buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}