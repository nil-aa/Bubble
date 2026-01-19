import 'package:flutter/material.dart';
import 'package:bubble/theme/app_theme.dart';
import 'package:bubble/widgets/story_circle.dart';
import 'package:bubble/widgets/profile_recommendation_widget.dart';
import 'package:bubble/screens/messages_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Daily Game Card
              _buildDailyGameCard(),
              
              // 3. Recommended Feed
              _buildFeedHeader(),
              _buildMainFeed(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundDark,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Bubble',
        style: TextStyle(
          color: AppTheme.textWhite,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.0,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add_box_outlined, color: AppTheme.textWhite),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border, color: AppTheme.textWhite),
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagesScreen()),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.textWhite),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryCoral,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStoriesBar() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: const [
          StoryCircle(name: 'Me', isMe: true),
          StoryCircle(name: 'Sarah', imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60'),
          StoryCircle(name: 'Mike', imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop&q=60'),
          StoryCircle(name: 'Chloe', imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500&auto=format&fit=crop&q=60'),
          StoryCircle(name: 'Alex', imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop&q=60'),
        ],
      ),
    );
  }

  Widget _buildDailyGameCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryCoral,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Vibe Check',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'See your matches for today by playing the daily game!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryCoral,
                      elevation: 0,
                      shadowColor: Colors.transparent, // Ensure no glow/shadow
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Play Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.videogame_asset, size: 80, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Text(
        'Recommended for You',
        style: TextStyle(
          color: AppTheme.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMainFeed() {
    return Column(
      children: const [
        ProfileRecommendationWidget(
          username: 'Nandhana',
          college: 'SSN College of Engineering',
          department: 'IT',
          bio: 'Always looking for new coffee shops and Taylor Swift playlists ✨',
          images: [
            'assets/images/user1_pic1.png',
            'assets/images/user1_pic2.png',
          ],
          commonInterests: ['Cat Lover', 'Coffee', 'Graphic Design'],
        ),
        ProfileRecommendationWidget(
          username: 'Mandy K',
          college: 'SSN College of Engineering',
          department: 'IT',
          bio: 'If you like space and late night drives, let\'s chat!',
          images: [
            'assets/images/user2_pic1.png',
          ],
          commonInterests: ['Lofi Hip Hop', 'Space', 'Hackathons'],
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(top: BorderSide(color: AppTheme.backgroundNavy, width: 0.5)),
      ),
      child: BottomNavigationBar(
        backgroundColor: AppTheme.backgroundDark,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryCoral,
        unselectedItemColor: AppTheme.textGray,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
