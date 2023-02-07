import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');
  final CollectionReference messageCollection =
      FirebaseFirestore.instance.collection('messages');

  Future<void> updateUserData(
    String? name,
    String? email,
    String? photoUrl,
  ) async {
    return await userCollection.doc(uid).set({
      'name': name ?? '',
      'email': email ?? '',
      'photoURL': photoUrl ?? '',
      'groups': [],
      'requestSent': [],
      'requestReceived': [],
      'friends': [],
      'uid': uid,
      'chats': [],
    });
  }

  Future<QuerySnapshot<Object?>> getUserData(
    String email,
  ) async {
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
    String email,
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
      'messages': [],
    });
    await groupDocumentReference.update({
      'members': FieldValue.arrayUnion([
        {'uid': uid, 'name': userName, 'email': email}
      ]),
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
    String groupId,
    String userName,
    String groupName,
    String email,
  ) async {
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List groups = documentSnapshot['groups'];

    if (groups.contains('${groupId}_$groupName')) {
      await groupDocumentReference.update({
        'members': FieldValue.arrayRemove([
          {'uid': uid, 'name': userName, 'email': email}
        ]),
      });
      return await userDocumentReference.update({
        'groups': FieldValue.arrayRemove(['${groupId}_$groupName']),
      });
    } else {
      await groupDocumentReference.update({
        'members': FieldValue.arrayUnion([
          {'uid': uid, 'name': userName, 'email': email},
        ]),
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

  Future<bool> acceptRequest(
    String senderId,
    String receiverId,
    String receiverName,
    String senderName,
    String receiverEmail,
    String senderEmail,
  ) async {
    try {
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
      DocumentReference messagesReference = await messageCollection.add({
        'messages': [],
        'recentMessage': '',
        'recentMessageSender': '',
        'recentMessageTime': '',
      });

      await messagesReference.update({
        'chatId': messagesReference.id,
        'members': FieldValue.arrayUnion([
          {'name': senderName, 'email': senderEmail, 'uid': senderId},
          {'name': receiverName, 'email': receiverEmail, 'uid': receiverId},
        ]),
      });

      await senderDocumentReference.update({
        'chats': FieldValue.arrayUnion([
          {
            'chatId': messagesReference.id,
            'chatWith': {
              'name': receiverName,
              'email': receiverEmail,
              'uid': receiverId
            },
          }
        ]),
      });

      await receiverDocumentReference.update({
        'chats': FieldValue.arrayUnion([
          {
            'chatId': messagesReference.id,
            'chatWith': {
              'name': senderName,
              'email': senderEmail,
              'uid': senderId
            },
          }
        ]),
      });

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> rejectRequest(
    String senderId,
    String receiverId,
  ) async {
    try {
      DocumentReference senderDocumentReference = userCollection.doc(senderId);
      DocumentReference receiverDocumentReference =
          userCollection.doc(receiverId);
      await senderDocumentReference.update({
        'requestSent': FieldValue.arrayRemove([receiverId]),
      });
      await receiverDocumentReference.update({
        'requestReceived': FieldValue.arrayRemove([senderId]),
      });
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
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

  Future sendMessageToGroup(
      String groupId, String message, String sender, String email) async {
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    groupDocumentReference.update({
      'recentMessage': message,
      'recentMessageSender': sender,
      'recentMessageTime': DateTime.now().toUtc(),
    });
    await groupDocumentReference.update(
      {
        'messages': FieldValue.arrayUnion(
          [
            {
              'message': message,
              'sender': sender,
              'senderEmail': email,
              'time': DateTime.now().toUtc(),
            }
          ],
        ),
      },
    );
  }

  Future sendMessageToChat(
      String chatId, String message, String sender, String email) async {
    DocumentReference groupDocumentReference = messageCollection.doc(chatId);
    groupDocumentReference.update({
      'recentMessage': message,
      'recentMessageSender': sender,
      'recentMessageSenderEmail': email,
      'recentMessageTime': DateTime.now().toUtc(),
    });
    await groupDocumentReference.update(
      {
        'messages': FieldValue.arrayUnion(
          [
            {
              'message': message,
              'sender': sender,
              'senderEmail': email,
              'time': DateTime.now().toUtc(),
            }
          ],
        ),
      },
    );
  }

  Future<Stream> getGroupMessages(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  Future<Stream> getChatMessages(String chatId) async {
    return messageCollection.doc(chatId).snapshots();
  }
}
