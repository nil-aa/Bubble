import 'package:flutter/material.dart';

/// Simple rounded button matching reference design
/// No glow effects, just clean rounded button with solid color or gradient
class SimpleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color textColor;
  final double height;
  final double borderRadius;
  final bool isOutlined;
  final Color? borderColor;

  const SimpleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.gradient,
    this.textColor = Colors.white,
    this.height = 56.0,
    this.borderRadius = 28.0,
    this.isOutlined = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: borderColor ?? textColor,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: gradient,
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
