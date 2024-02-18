import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_practice_app/widgets/rounded_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageScreen extends StatefulWidget {
  static const id = 'upload_image_screen';
  const UploadImageScreen({Key? key}) : super(key: key);

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? myImage; //File to be picker from Gallery
  String? profileImage; // downloadUrl String to be fetched form Firestore later

  Future<void> pickImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        myImage = File(pickedImage.path);
      });
    } else {
      print('image is null');
    }
  }

  //FirebaseAuth, FirebaseFirestore, FirebaseStorage
  Future<void> uploadImageToFirebaseStorage() async {
    Reference storageRef = _firebaseStorage.ref();
    final imagesRef = storageRef.child("images/nature");

    UploadTask uploadTask = imagesRef.putFile(myImage!.absolute);
    Future.value(uploadTask).then((value) async {
      final downloadURL = await imagesRef.getDownloadURL();
      print(
          'image successfully uploaded to firebase storage with download url:$downloadURL');
      //store download url in Firestore for future use
      storeDownloadURLInFirestore(downloadURL!);
      print('successfully stored download url in Firestore for future use');
    });
  }

  Future<void> storeDownloadURLInFirestore(String? downloadURL) async {
    final data = {
      'profile_image': downloadURL,
    };
    await _firestore.collection('users').add(data);
  }

  Future<void> getUserDataFromFirestore() async {
    final users = await _firestore.collection('users').get();
    final firstUserData = users.docs[0].data();
    if (firstUserData != null) {
      profileImage = firstUserData['profile_image'];
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    //NOTE: call the below function if you want to initially display the uploaded profile from Firestore in the bottom container
    // getUserDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Text widget
          const Text('Pick image and upload to Firebase Storage'),
          const SizedBox(
            height: 12,
          ),
          //pick image from gallery widget
          Center(
            child: InkWell(
              onTap: () {
                pickImageFromGallery();
              },
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: myImage != null
                    ? Image.file(
                        myImage!) //Note: This is the myImage picked from gallery FileSystem. This is not permanently stored in firebaseStorage yet
                    : const Icon(Icons.upload),
              ),
            ),
          ),
          //  upload button
          RoundedButton(
            buttonColor: Colors.blue,
            buttonText: 'Upload',
            onPress: () {
              if (myImage != null) {
                uploadImageToFirebaseStorage();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please pick an image first'),
                ));
              }
            },
          ),
          const SizedBox(
            height: 30,
            child: Divider(thickness: 2),
          ),

          //uploaded image: Network image from firestore
          const Center(
            child: Text(
                'Upload Profile Picture and Display from Firestore Database'),
          ),
          const SizedBox(
            height: 12,
          ),
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: profileImage != null
                  ? Image.network(
                      profileImage!) //note: This is a network image url stored in Firestore database
                  : InkWell(
                      onTap: () async {
                        if (profileImage == null) {
                          await pickImageFromGallery();
                          await uploadImageToFirebaseStorage();
                          await getUserDataFromFirestore();
                        }
                      },
                      child: const Center(
                        child: Text('Upload your Profile Picture'),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
