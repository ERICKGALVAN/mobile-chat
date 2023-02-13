import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Profile extends StatefulWidget {
  const Profile({
    Key? key,
    required this.name,
    required this.email,
  }) : super(key: key);
  final String name;
  final String email;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  void uploadImage() async {
    final firebaseStorage = FirebaseStorage.instance;
    final imagePicker = ImagePicker();
    //Check Permissions
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        Permission.storage.request();
        var permissionStatus = await Permission.storage.status;

        if (permissionStatus.isGranted) {
          final image =
              await imagePicker.pickImage(source: ImageSource.gallery);
          var file = File(image!.path);

          try {
            var snapshot = await firebaseStorage
                .ref()
                .child('profilePic/${FirebaseAuth.instance.currentUser!.uid}')
                .putFile(file);

            var downloadUrl = await snapshot.ref.getDownloadURL();
            await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                .changeProfilePicture(downloadUrl);
          } catch (e) {
            log(e.toString());
          }
        } else {
          log('Permission not granted. Try Again with permission access');
        }
      } else {
        Permission.photos.request();
        var permissionStatus = await Permission.photos.status;

        if (permissionStatus.isGranted) {
          final image =
              await imagePicker.pickImage(source: ImageSource.gallery);
          var file = File(image!.path);

          try {
            var snapshot = await firebaseStorage
                .ref()
                .child('profilePic/${FirebaseAuth.instance.currentUser!.uid}')
                .putFile(file);

            var downloadUrl = await snapshot.ref.getDownloadURL();
            await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                .changeProfilePicture(downloadUrl);
          } catch (e) {
            log(e.toString());
          }
        } else {
          log('Permission not granted. Try Again with permission access');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Center(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          uploadImage();
                        },
                        child: CircleAvatar(
                          radius: 100,
                          backgroundImage: !snapshot.hasData ||
                                  snapshot.data!['photoURL'].toString().isEmpty
                              ? null
                              : NetworkImage(snapshot.data!['photoURL']),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.email,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
