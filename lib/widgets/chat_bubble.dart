import 'package:flutter/material.dart';
import 'package:bubble/theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primaryCoral : AppTheme.backgroundDark.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
              border: isMe 
                ? null 
                : Border.all(color: AppTheme.backgroundNavy, width: 1),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : AppTheme.textWhite,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : 4,
              right: isMe ? 4 : 0,
            ),
            child: Text(
              time,
              style: TextStyle(
                color: AppTheme.textGray.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
