import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/home/pages/home_page.dart';
import 'package:flutter_chat/widgets/main_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/services/database_service.dart';

class ChatGroupInfo extends StatefulWidget {
  const ChatGroupInfo({
    Key? key,
    required this.admin,
    required this.userName,
    required this.groupMembers,
    required this.groupId,
    required this.groupName,
    required this.profilePic,
  }) : super(key: key);
  final String userName;
  final String groupName;
  final String groupId;
  final String admin;
  final List groupMembers;
  final String profilePic;

  @override
  State<ChatGroupInfo> createState() => _ChatGroupInfoState();
}

class _ChatGroupInfoState extends State<ChatGroupInfo> {
  @override
  void didChangeDependencies() async {
    final List uidList = [];
    for (var i = 0; i < widget.groupMembers.length; i++) {
      uidList.add(widget.groupMembers[i]['uid']);
    }
    if (uidList.contains(FirebaseAuth.instance.currentUser!.uid)) {
      _isMember = true;
    } else {
      _isMember = false;
    }
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name')!;
    super.didChangeDependencies();
  }

  bool _isLoading = false;
  final _email = FirebaseAuth.instance.currentUser!.email;
  String _name = '';
  bool _isMember = false;
  String getName(String value) {
    return value.split('_')[1];
  }

  Future<void> _leaveGroup() async {
    setState(() {
      _isLoading = true;
    });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .toggleJoinGroup(
      widget.groupId,
      _name,
      widget.groupName,
      _email!,
    )
        .then((value) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isMember
              ? 'Has salido del grupo'
              : 'Ahora eres miembro del grupo'),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ha ocurrido un error'),
        ),
      );
    });
    setState(() {
      _isLoading = false;
    });
  }

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
                .child('profilePic/${widget.groupId}')
                .putFile(file);
            var downloadUrl = await snapshot.ref.getDownloadURL();
            await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                .changeProfilePictureGroup(
              downloadUrl,
              widget.groupId,
            );
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
                .child('profilePic/${widget.groupId}')
                .putFile(file);

            var downloadUrl = await snapshot.ref.getDownloadURL();
            await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                .changeProfilePictureGroup(
              downloadUrl,
              widget.groupId,
            );
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
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            _isMember ? uploadImage() : null;
                          },
                          child: CircleAvatar(
                            radius: 90,
                            backgroundColor: Theme.of(context).primaryColor,
                            backgroundImage: widget.profilePic.isEmpty
                                ? null
                                : NetworkImage(widget.profilePic),
                          ),
                        ),
                        Text(
                          widget.groupName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                    Text(
                      '${widget.groupMembers.length.toString()} miembros',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 236, 236, 236)
                                .withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.groupMembers.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          bool isAdmin = widget.groupMembers[index]['uid'] ==
                              widget.admin.split('_')[0];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(
                                  widget.groupMembers[index]['name'].toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: isAdmin
                                        ? Theme.of(context).primaryColor
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  widget.groupMembers[index]['email']
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: isAdmin
                                        ? Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.8)
                                        : Colors.black.withOpacity(0.8),
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    MainButton(
                      text: _isMember ? 'Salir del grupo' : 'Unirse al grupo',
                      onPressed: () async {
                        await _leaveGroup();
                      },
                      backgroundColor: _isMember
                          ? const Color.fromARGB(255, 226, 26, 12)
                          : Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
