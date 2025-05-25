import 'package:flutter/material.dart';
import '../widgets/button.dart'; // 기존에 만든 버튼 컴포넌트 참조

class EmptyState extends StatelessWidget {
  final String imagePath;
  final String description;
  final String subDescription;
  final String buttonLabel;
  final VoidCallback onPressed;
  final Color buttonColor;

  const EmptyState({
    super.key,
    required this.imagePath,
    required this.description,
    required this.subDescription,
    required this.buttonLabel,
    required this.onPressed,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, width: 140, height: 140),
            const SizedBox(height: 24),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subDescription,
              style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            ),
            const SizedBox(height: 24),
            CommonButton(
              text: buttonLabel,
              color: buttonColor,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
