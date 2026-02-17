import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bubble/theme/app_theme.dart';
import 'package:bubble/screens/messages_screen.dart';
import 'package:bubble/screens/login_screen.dart';
import 'package:bubble/widgets/profile_card.dart';
import 'package:bubble/widgets/swipe_stack.dart';
import 'package:bubble/services/auth_service.dart';
import 'package:bubble/services/firestore_service.dart';
import 'package:bubble/services/compatibility_engine.dart';
import 'package:bubble/models/user_model.dart';
import 'package:bubble/models/match_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isStackFinished = false;
  bool _isLoading = true;
  List<_ScoredUser> _scoredUsers = [];
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadDiscoveryQueue();
  }

  /// Load campus users, compute compatibility, and build discovery queue
  Future<void> _loadDiscoveryQueue() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);
      final uid = authService.uid;
      if (uid == null) return;

      // 1. Get current user's profile
      final currentUser = await firestoreService.getUser(uid);
      if (currentUser == null) return;

      // 2. Get all campus users
      final campusUsers = await firestoreService.getCampusUsers(
        campusId: currentUser.campusId,
        excludeUid: uid,
      );

      // 3. Get already-swiped user IDs
      final swipedIds = await firestoreService.getSwipedUserIds(uid);

      // 4. Compute compatibility scores for unswiped users
      final scored = <_ScoredUser>[];
      for (final user in campusUsers) {
        if (swipedIds.contains(user.uid)) continue; // Skip already swiped

        double musicScore = 0;
        List<String> sharedArtists = [];
        List<String> sharedGenres = [];

        if (currentUser.musicVector != null && user.musicVector != null) {
          musicScore = CompatibilityEngine.computeMusicSimilarity(
            currentUser.musicVector!,
            user.musicVector!,
          );
          sharedArtists = CompatibilityEngine.findSharedArtists(
            currentUser.musicVector!,
            user.musicVector!,
          );
          sharedGenres = CompatibilityEngine.findSharedGenres(
            currentUser.musicVector!,
            user.musicVector!,
          );
        }

        scored.add(_ScoredUser(
          user: user,
          musicSimilarity: musicScore,
          sharedArtists: sharedArtists,
          sharedGenres: sharedGenres,
        ));
      }

      // 5. Sort by compatibility (highest first)
      scored.sort((a, b) => b.musicSimilarity.compareTo(a.musicSimilarity));

      if (mounted) {
        setState(() {
          _currentUser = currentUser;
          _scoredUsers = scored;
          _isLoading = false;
          _isStackFinished = scored.isEmpty;
        });
      }
    } catch (e) {
      debugPrint('Error loading discovery queue: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle swipe right — create match in Firestore
  void _onSwipeRight(int index) async {
    if (index >= _scoredUsers.length) return;
    final targetUser = _scoredUsers[index];

    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final uid = authService.uid;
    if (uid == null) return;

    try {
      // Check if target already swiped right on us
      final existingMatch =
          await firestoreService.findMatchBetweenUsers(targetUser.user.uid, uid);

      if (existingMatch != null && existingMatch.status.startsWith('pending')) {
        // It's a match! Update to matched
        await firestoreService.updateMatchStatus(existingMatch.matchId, 'matched');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 You matched with ${targetUser.user.name}!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (existingMatch == null) {
        // Create new pending match
        final matchId =
            '${uid}_${targetUser.user.uid}_${DateTime.now().millisecondsSinceEpoch}';
        final match = MatchModel(
          matchId: matchId,
          userId1: uid,
          userId2: targetUser.user.uid,
          musicSimilarity: targetUser.musicSimilarity,
          totalCompatibility: targetUser.musicSimilarity,
          sharedArtists: targetUser.sharedArtists,
          sharedGenres: targetUser.sharedGenres,
          status: 'pending_1',
          createdAt: DateTime.now(),
        );
        await firestoreService.createMatch(match);
      }
    } catch (e) {
      debugPrint('Error creating match: $e');
    }
  }

  /// Handle swipe left — just skip for now
  void _onSwipeLeft(int index) {
    // Could store rejections in Firestore to prevent reshowing
    debugPrint('Swiped left on ${_scoredUsers[index].user.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryCoral))
          : Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _scoredUsers.isEmpty
                        ? _buildEmptyState()
                        : SwipeStack(
                            onSwipeRight: _onSwipeRight,
                            onSwipeLeft: _onSwipeLeft,
                            onStackFinished: () {
                              setState(() => _isStackFinished = true);
                            },
                            children: _scoredUsers.map((scored) {
                              final user = scored.user;
                              return ProfileCard(
                                name: user.name,
                                age: _calculateAge(user),
                                college: user.college,
                                department: user.department,
                                bio: user.bio ?? '',
                                images: user.topArtistNames.isEmpty
                                    ? ['assets/images/hero_illustration.png']
                                    : ['assets/images/hero_illustration.png'],
                                prompts: user.prompts,
                                lookingFor: user.lookingFor.isNotEmpty
                                    ? user.lookingFor.first
                                    : 'Friends',
                                personalityType:
                                    user.personalityType ?? 'XXXX',
                                topArtists: user.topArtistNames.isNotEmpty
                                    ? user.topArtistNames.take(3).toList()
                                    : ['No artists yet'],
                                compatibilityPercent:
                                    scored.musicSimilarity,
                                sharedArtists: scored.sharedArtists,
                                sharedGenres: scored.sharedGenres,
                                vibeSummary: user.vibeSummary,
                              );
                            }).toList(),
                          ),
                  ),
                ),
                if (!_isStackFinished && _scoredUsers.isNotEmpty)
                  _buildActionButtons(),
                const SizedBox(height: 24),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_outlined,
              size: 80, color: AppTheme.textGray.withOpacity(0.5)),
          const SizedBox(height: 24),
          const Text(
            'No more profiles nearby',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new people on your campus!',
            style: TextStyle(
              color: AppTheme.textGray.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () {
              setState(() => _isLoading = true);
              _loadDiscoveryQueue();
            },
            child: const Text(
              'Refresh',
              style: TextStyle(
                color: AppTheme.primaryCoral,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(UserModel user) {
    // For now, return year as age placeholder
    // Will be computed from birthday once stored
    return user.year.replaceAll(RegExp(r'[^0-9]'), '');
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
        // Sign out button
        IconButton(
          onPressed: () async {
            final authService =
                Provider.of<AuthService>(context, listen: false);
            await authService.signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.logout, color: AppTheme.textGray, size: 20),
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

/// Internal helper holding a user with their computed compatibility score
class _ScoredUser {
  final UserModel user;
  final double musicSimilarity;
  final List<String> sharedArtists;
  final List<String> sharedGenres;

  const _ScoredUser({
    required this.user,
    required this.musicSimilarity,
    required this.sharedArtists,
    required this.sharedGenres,
  });
}
