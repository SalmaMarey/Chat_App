import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    fcm.subscribeToTopic('chat');
    // final token = await fcm.getToken();
    // print(token);
  }

  @override
  void initState() {
    super.initState();

    setupPushNotifications();
  }

  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('users');
  Future<String> _getUsernames() async {
    QuerySnapshot querySnapshot = await _collectionReference.get();
    List<UserModel> userModelList = [];

    for (var doc in querySnapshot.docs) {
      final user = UserModel(
          id: doc['id'],
          username: doc['username'],
          userImage: doc['image_url'],
          email: doc['email']);
      userModelList.add(user);
    }

    final myUserId = FirebaseAuth.instance.currentUser!.uid;
    final otherUser = userModelList.firstWhere(
        (element) => myUserId != element.id,
        orElse: () => UserModel(
            username: 'username',
            userImage: 'userImage',
            email: 'email',
            id: 'id'));
    return otherUser.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBar: AppBar(
        title: FutureBuilder<String>(
            future: _getUsernames(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading...');
              }

              if (snapshot.hasError ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                return const Text('Error');
              }
              return Text(
                snapshot.data!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 25,
                ),
              );
            }),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessage(),
        ],
      ),
    );
  }
}
