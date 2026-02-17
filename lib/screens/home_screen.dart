import 'package:flutter/material.dart';
import 'package:bubble/theme/app_theme.dart';
import 'package:bubble/screens/messages_screen.dart';
import 'package:bubble/widgets/profile_card.dart';
import 'package:bubble/widgets/swipe_stack.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isStackFinished = false;

  // Classic placeholder for a clean, professional look
  static const String _placeholderImg = 'https://ui-avatars.com/api/?name=User&background=2A314E&color=fff&size=512';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(context),
      body: _isStackFinished 
        ? Center(child: _buildEmptyState())
        : Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SwipeStack(
                    onStackFinished: () {
                      setState(() {
                        _isStackFinished = true;
                      });
                    },
                    children: [
                      const ProfileCard(
                        name: 'Nandhana',
                        age: '19',
                        college: 'SSN College of Engineering',
                        department: 'IT',
                        bio: 'Living life one Taylor Swift bridge at a time. ✨',
                        images: ['assets/images/user1_pic1.png', 'assets/images/user1_pic2.png'],
                        prompts: [
                          {'question': 'The best way to win me over is...', 'answer': 'A warm croissant and a perfectly curated sunset playlist.'},
                          {'question': 'My most useless skill is...', 'answer': 'I can identify any Taylor Swift song by the first 0.5 seconds.'},
                        ],
                        lookingFor: 'Long Term',
                        personalityType: 'ENFP',
                        topArtists: ['Taylor Swift', 'Lana Del Rey', 'The Weeknd'],
                        compatibilityPercent: 92,
                        sharedArtists: ['Taylor Swift'],
                        sharedGenres: ['Pop', 'Indie Pop'],
                      ),
                      const ProfileCard(
                        name: 'Mandy K',
                        age: '20',
                        college: 'SSN College of Engineering',
                        department: 'IT',
                        bio: 'If you like space, Lofi, and late night drives, we\'ll get along.',
                        images: ['assets/images/user2_pic1.png'],
                        prompts: [
                          {'question': 'A controversial opinion I have is...', 'answer': 'Cold coffee is better than hot coffee, even in winter.'},
                          {'question': 'My zombie apocalypse plan is...', 'answer': 'Hide in the library. Zombies don\'t read, right?'},
                        ],
                        lookingFor: 'New Friends',
                        personalityType: 'INFJ',
                        topArtists: ['Arctic Monkeys', 'Chase Atlantic', 'Drake'],
                        compatibilityPercent: 84,
                        sharedArtists: ['Arctic Monkeys'],
                        sharedGenres: ['Alt Rock', 'Lofi'],
                      ),
                      const ProfileCard(
                        name: 'Jai',
                        age: '21',
                        college: 'SSN College of Engineering',
                        department: 'CSE',
                        bio: 'Code by day, chaos by night. 💻🔥',
                        images: [_placeholderImg], // Using classic placeholder for Jai
                        prompts: [
                          {'question': 'You\'ll know I like you if...', 'answer': 'I share my VS Code shortcuts with you.'},
                          {'question': 'Don\'t talk to me if...', 'answer': 'You think dark mode is overrated.'},
                        ],
                        lookingFor: 'Hackathon Partner',
                        personalityType: 'ENTP',
                        topArtists: ['Daft Punk', 'Kanye West', 'The Strokes'],
                        compatibilityPercent: 76,
                        sharedArtists: ['The Strokes'],
                        sharedGenres: ['Electronic', 'Hip Hop'],
                      ),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
              const SizedBox(height: 24),
            ],
          ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_pin_circle_outlined, 
              size: 80, color: AppTheme.textGray.withOpacity(0.5)),
          const SizedBox(height: 24),
          const Text(
            'No more profiles for today',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Check back soon for more wavelengths!',
            style: TextStyle(color: AppTheme.textGray, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCircleButton(Icons.close, Colors.redAccent, 56, () {}),
          const SizedBox(width: 20),
          _buildCircleButton(Icons.favorite, AppTheme.primaryCoral, 72, () {}),
          const SizedBox(width: 20),
          _buildCircleButton(Icons.star, Colors.blueAccent, 56, () {}),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, Color color, double size, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.backgroundNavy,
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
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
