import 'package:flutter/material.dart';
import 'package:bubble/theme/app_theme.dart';

/// A widget that displays a recommended user profile as an Instagram-style post
class ProfileRecommendationWidget extends StatelessWidget {
  final String username;
  final String college;
  final String department;
  final List<String> images;
  final String? bio;
  final List<String> commonInterests;

  const ProfileRecommendationWidget({
    super.key,
    required this.username,
    required this.college,
    required this.department,
    required this.images,
    this.bio,
    this.commonInterests = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      color: AppTheme.backgroundNavy.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Profile Pic, Username, College
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryCoral.withOpacity(0.2),
                  child: Text(
                    username[0].toUpperCase(),
                    style: const TextStyle(color: AppTheme.primaryCoral, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '$department • $college',
                        style: TextStyle(
                          color: AppTheme.textGray.withOpacity(0.8),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: AppTheme.textWhite),
              ],
            ),
          ),

          // Main Content: Image(s)
          if (images.length > 1)
            SizedBox(
              height: 400,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                  );
                },
              ),
            )
          else
            Image.asset(
              images[0],
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
            ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.favorite_border, color: AppTheme.textWhite, size: 28),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, color: AppTheme.textWhite, size: 26),
                const SizedBox(width: 16),
                const Icon(Icons.send_outlined, color: AppTheme.textWhite, size: 26),
                const Spacer(),
                const Icon(Icons.bookmark_border, color: AppTheme.textWhite, size: 28),
              ],
            ),
          ),

          // Captions & Bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bio != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                        children: [
                          TextSpan(
                            text: '$username ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: bio!),
                        ],
                      ),
                    ),
                  ),
                
                // Common Interests / Bubble Tags
                if (commonInterests.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: commonInterests.map((interest) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCoral.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryCoral.withOpacity(0.3)),
                      ),
                      child: Text(
                        interest,
                        style: const TextStyle(
                          color: AppTheme.primaryCoral,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 400,
      width: double.infinity,
      color: AppTheme.backgroundDark,
      child: const Center(
        child: Icon(Icons.person, color: AppTheme.textGray, size: 80),
      ),
    );
  }
}
