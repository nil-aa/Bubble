import 'package:flutter/material.dart';
import 'package:bubble/theme/app_theme.dart';

/// A circular story widget with a colorful gradient ring
class StoryCircle extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isMe;

  const StoryCircle({
    super.key,
    required this.name,
    this.imageUrl,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isMe 
                  ? [AppTheme.textGray.withOpacity(0.3), AppTheme.textGray.withOpacity(0.3)]
                  : [AppTheme.primaryCoral, AppTheme.accentPurple, AppTheme.primaryPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2.0),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundNavy,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.backgroundDark.withOpacity(0.5),
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                child: imageUrl == null 
                  ? Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isMe ? 'Your Story' : name,
            style: TextStyle(
              color: isMe ? AppTheme.textGray : AppTheme.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
