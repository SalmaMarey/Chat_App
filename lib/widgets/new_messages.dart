import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  _sendMessage() async {
    final enteredMessage = _messageController.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    _messageController.clear();
    final User user = FirebaseAuth.instance.currentUser!;
    final DocumentSnapshot<Map<String, dynamic>> userData =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    await FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()?['username'],
      'userImage': userData.data()?['image_url'],
      'time': DateTime.now().microsecondsSinceEpoch
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 1, right: 1, bottom: 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 220.5,
                      child: TextField(
                        controller: _messageController,
                        autocorrect: true,
                        textCapitalization: TextCapitalization.sentences,
                        enableSuggestions: true,
                        decoration: const InputDecoration(
                          labelText: '  Send a message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: _sendMessage,
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 25,
                  )),
            ),
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
    );
  }
}
