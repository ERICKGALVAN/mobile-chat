import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  Future<void> updateUserData(
      String? name, String? email, String? photoUrl) async {
    return await userCollection.doc(uid).set({
      'name': name ?? '',
      'email': email ?? '',
      'photoURL': photoUrl ?? '',
      'groups': [],
      'requestSent': [],
      'requestReceived': [],
      'friends': [],
      'uid': uid,
    });
  }

  Future<QuerySnapshot<Object?>> getUserData(String email) async {
    QuerySnapshot querySnapshot = await userCollection
        .where('email', isEqualTo: email)
        .get()
        .catchError((error) {
      log(error.toString());
      return null;
    });
    return querySnapshot;
  }

  Future<Stream<DocumentSnapshot<Object?>>> getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  Future createGroup(
    String userName,
    String id,
    String groupName,
    String description,
  ) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': '',
      'chatColor': '',
      'admin': '${id}_$userName',
      'members': [],
      'groupDescription': '',
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': '',
      'recentMessageTime': '',
    });
    await groupDocumentReference.update({
      'members': FieldValue.arrayUnion(['${id}_$userName']),
      'groupId': '${groupDocumentReference.id}_$groupName',
      'groupDescription': description,
    });
    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      'groups':
          FieldValue.arrayUnion(['${groupDocumentReference.id}_$groupName']),
    });
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getMessages(
      String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentSnapshot documentSnapshot =
        await groupCollection.doc(groupId).get();
    return documentSnapshot['admin'];
  }

  Future getGroupMembers(String groupId) async {
    DocumentSnapshot documentSnapshot =
        await groupCollection.doc(groupId).get();
    return documentSnapshot['members'];
  }

  Future searchUserByName(String userName) async {
    QuerySnapshot querySnapshot = await userCollection
        .where('name', isEqualTo: userName)
        .get()
        .catchError((error) {
      log(error.toString());
      return null;
    });
    return querySnapshot;
  }

  Future searchUserByEmail(String userName) async {
    QuerySnapshot querySnapshot = await userCollection
        .where('email', isEqualTo: userName)
        .get()
        .catchError((error) {
      log(error.toString());
      return null;
    });
    return querySnapshot;
  }

  Future searchGroup(String groupName) async {
    QuerySnapshot querySnapshot = await groupCollection
        .where('groupName', isEqualTo: groupName)
        .get()
        .catchError((error) {
      log(error.toString());
      return null;
    });
    return querySnapshot;
  }

  Future toggleJoinGroup(
      String groupId, String userName, String groupName) async {
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List groups = documentSnapshot['groups'];

    if (groups.contains('${groupId}_$groupName')) {
      await groupDocumentReference.update({
        'members': FieldValue.arrayRemove(['${uid}_$userName']),
      });
      return await userDocumentReference.update({
        'groups': FieldValue.arrayRemove(['${groupId}_$groupName']),
      });
    } else {
      await groupDocumentReference.update({
        'members': FieldValue.arrayUnion(['${uid}_$userName']),
      });
      return await userDocumentReference.update({
        'groups': FieldValue.arrayUnion(['${groupId}_$groupName']),
      });
    }
  }

  Future sendRequest(String senderId, String receiverId) async {
    DocumentReference senderDocumentReference = userCollection.doc(senderId);
    DocumentReference receiverDocumentReference =
        userCollection.doc(receiverId);
    await senderDocumentReference.update({
      'requestSent': FieldValue.arrayUnion([receiverId]),
    });
    await receiverDocumentReference.update({
      'requestReceived': FieldValue.arrayUnion([senderId]),
    });
  }

  Future acceptRequest(String senderId, String receiverId) async {
    DocumentReference senderDocumentReference = userCollection.doc(senderId);
    DocumentReference receiverDocumentReference =
        userCollection.doc(receiverId);
    await senderDocumentReference.update({
      'requestSent': FieldValue.arrayRemove([receiverId]),
      'friends': FieldValue.arrayUnion([receiverId]),
    });
    await receiverDocumentReference.update({
      'requestReceived': FieldValue.arrayRemove([senderId]),
      'friends': FieldValue.arrayUnion([senderId]),
    });
  }

  Future rejectRequest(String senderId, String receiverId) async {
    DocumentReference senderDocumentReference = userCollection.doc(senderId);
    DocumentReference receiverDocumentReference =
        userCollection.doc(receiverId);
    await senderDocumentReference.update({
      'requestSent': FieldValue.arrayRemove([receiverId]),
    });
    await receiverDocumentReference.update({
      'requestReceived': FieldValue.arrayRemove([senderId]),
    });
  }

  Future<bool> checkIfIsFriend(String userId) async {
    DocumentSnapshot documentSnapshot = await userCollection.doc(uid).get();
    final List friends = documentSnapshot['friends'];
    if (friends.contains(userId)) {
      return true;
    } else {
      return false;
    }
  }

  Future findUserById(String userId) async {
    DocumentSnapshot documentSnapshot = await userCollection.doc(userId).get();
    log(documentSnapshot['friends'].toString());
    return documentSnapshot;
  }

  Future<Stream> getUserFriends() async {
    return userCollection.doc(uid).snapshots();
  }
}
