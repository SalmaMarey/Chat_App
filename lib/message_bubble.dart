import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// A MessageBubble for showing a single chat message on the ChatScreen.
class MessageBubble extends StatelessWidget {
  // Create a message bubble which is meant to be the first in the sequence.
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
    required this.time,
  }) : isFirstInSequence = true;

  // Create a amessage bubble that continues the sequence.
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  final bool isFirstInSequence;

  final String? userImage;
  final DateTime time;
  final String? username;
  final String message;

  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        if (userImage != null)
          Padding(
              padding: const EdgeInsets.only(
                top: 10,
              ),
              child: !isMe
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(
                        userImage!,
                      ),
                      backgroundColor: theme.colorScheme.primary.withAlpha(180),
                      radius: 23,
                    )
                  : null),
        Container(
          margin: const EdgeInsets.only(left: 50, right: 10),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (isFirstInSequence) const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.white
                          : theme.colorScheme.primary.withAlpha(200),
                      borderRadius: BorderRadius.only(
                        topLeft: !isMe && isFirstInSequence
                            ? const Radius.circular(15)
                            : const Radius.circular(15),
                        topRight: isMe && isFirstInSequence
                            ? const Radius.circular(15)
                            : const Radius.circular(15),
                        bottomLeft: const Radius.circular(15),
                        bottomRight: isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(15),
                      ),
                    ),
                    constraints: const BoxConstraints(maxWidth: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 1,
                      horizontal: 0,
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        height: 1.3,
                        color: isMe
                            ? Colors.black87
                            : theme.colorScheme.onSecondary,
                      ),
                      softWrap: true,
                    ),
                  ),
                  Text(
                    (DateFormat.jm()).format(time),
                    style: TextStyle(color: Colors.grey[800], fontSize: 13),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
