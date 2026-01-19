import 'package:flutter/material.dart';
import 'package:bubble/theme/app_theme.dart';
import 'package:bubble/screens/chat_detail_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  final List<Map<String, dynamic>> _chats = const [
    {
      'name': 'Maggi',
      'lastMsg': 'That sounds like a plan! See ya.',
      'time': '2m ago',
      'unread': 2,
    },
    {
      'name': 'Madhav',
      'lastMsg': 'Did you finish the lab report?',
      'time': '1h ago',
      'unread': 0,
    },
    {
      'name': 'Nishanth',
      'lastMsg': 'I love that song too!',
      'time': '3h ago',
      'unread': 0,
    },
    {
      'name': 'Jai',
      'lastMsg': 'Let\'s play the game tonight!',
      'time': 'Yesterday',
      'unread': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: AppTheme.textWhite, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: ListView.separated(
              itemCount: _chats.length,
              separatorBuilder: (context, index) => const Divider(
                color: AppTheme.backgroundNavy,
                height: 1,
                indent: 80,
              ),
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryCoral.withOpacity(0.1),
                        child: Text(
                          chat['name'][0],
                          style: const TextStyle(color: AppTheme.primaryCoral, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      const Positioned(
                        right: 2,
                        bottom: 2,
                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor: AppTheme.backgroundDark,
                          child: CircleAvatar(radius: 5, backgroundColor: Colors.green),
                        ),
                      ),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['name'],
                        style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        chat['time'],
                        style: TextStyle(color: AppTheme.textGray.withOpacity(0.7), fontSize: 12),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chat['lastMsg'],
                            style: TextStyle(
                              color: chat['unread'] > 0 ? AppTheme.textWhite : AppTheme.textGray,
                              fontSize: 14,
                              fontWeight: chat['unread'] > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chat['unread'] > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryCoral,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${chat['unread']}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(username: chat['name']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundNavy.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.backgroundNavy),
        ),
        child: const TextField(
          style: TextStyle(color: AppTheme.textWhite),
          decoration: InputDecoration(
            hintText: 'Search friends...',
            hintStyle: TextStyle(color: AppTheme.textGray),
            icon: Icon(Icons.search, color: AppTheme.textGray),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
