import 'package:flutter/material.dart';
import 'package:bubble/theme/app_theme.dart';

class ProfileCard extends StatefulWidget {
  final String name;
  final String age;
  final String college;
  final String department;
  final String bio;
  final List<String> images;
  final List<Map<String, String>> prompts; // e.g. {'question': 'My secret talent...', 'answer': 'Cooking'}
  final String lookingFor;
  final String personalityType; // e.g. 'ENFP'
  final List<String> topArtists;

  const ProfileCard({
    super.key,
    required this.name,
    required this.age,
    required this.college,
    required this.department,
    required this.bio,
    required this.images,
    required this.prompts,
    required this.lookingFor,
    required this.personalityType,
    required this.topArtists,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  int _currentImageIndex = 0;

  void _nextImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % widget.images.length;
    });
  }

  void _prevImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex - 1 + widget.images.length) % widget.images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // 1. Base Image
                Image.asset(
                  widget.images[_currentImageIndex],
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.backgroundNavy,
                    child: const Center(child: Icon(Icons.person, size: 100, color: AppTheme.textGray)),
                  ),
                ),

                // 2. Gradient Overlay (On top of image, below interactions)
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.2, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. Indicators (Top)
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: IgnorePointer(
                    child: Row(
                      children: List.generate(
                        widget.images.length,
                        (index) => Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: index == _currentImageIndex 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                if (index == _currentImageIndex)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Detailed Profile Info (Scrollable Bottom Area)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: constraints.maxHeight * 0.4, // Use card height fraction
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        key: ValueKey(_currentImageIndex),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildDetailContent(),
                      ),
                    ),
                  ),
                ),

                // 5. Interaction Layers (Top Scroll-Free Area)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: constraints.maxHeight * 0.6, // Upper 60% for photo switching
                  child: Row(
                    children: [
                      // Left Tap Area
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if (_currentImageIndex > 0) _prevImage();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _currentImageIndex > 0 
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 8.0, top: 40),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.chevron_left, color: Colors.white70, size: 28),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                      // Right Tap Area
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if (_currentImageIndex < widget.images.length - 1) _nextImage();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _currentImageIndex < widget.images.length - 1
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 8.0, top: 40),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.chevron_right, color: Colors.white70, size: 28),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildDetailContent() {
    // If it's the first photo, show name, age, bio, chips, music
    if (_currentImageIndex == 0 || widget.images.length == 1) {
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${widget.name}, ${widget.age}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(Icons.verified, color: AppTheme.accentLightBlue, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${widget.department} • ${widget.college}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(widget.personalityType, Icons.psychology, AppTheme.accentPurple),
            _buildChip(widget.lookingFor, Icons.search, AppTheme.primaryCoral),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          widget.bio,
          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.music_note, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Top Artists: ${widget.topArtists.join(", ")}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ];
    } else {
      // For Pic 2+ show Prompts
      // We'll show all prompts with healthy spacing for easy scrolling
      return [
        const SizedBox(height: 40), // Push the first prompt down a bit as requested
        ...widget.prompts.map((prompt) {
          final bool isLast = widget.prompts.last == prompt;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 40.0 : 80.0), // Large spacing between prompts
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prompt['question'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  prompt['answer'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ];
    }
  }


  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
