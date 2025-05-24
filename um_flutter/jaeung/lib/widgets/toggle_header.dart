import 'package:flutter/material.dart';

class CustomToggleHeader extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final int selectedIndex;
  final void Function(int) onTap;
  final Color activeColor;

  const CustomToggleHeader({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.selectedIndex,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: activeColor, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(0),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == 0 ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(32),
                ),
                alignment: Alignment.center,
                child: Text(
                  leftLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedIndex == 0 ? Colors.white : activeColor,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(1),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == 1 ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(32),
                ),
                alignment: Alignment.center,
                child: Text(
                  rightLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedIndex == 1 ? Colors.white : activeColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
