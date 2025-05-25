import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final VoidCallback? onLeftClick;
  final VoidCallback? onRightClick;

  const NavHeader({
    super.key,
    required this.title,
    this.leftIcon,
    this.rightIcon,
    this.onLeftClick,
    this.onRightClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 가운데 타이틀
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // 왼쪽 아이콘
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onLeftClick ?? () => context.pop(), // ✅ go_router에 맞게 수정
              child: leftIcon ?? const Icon(Icons.chevron_left, size: 28),
            ),
          ),

          // 오른쪽 아이콘 또는 Spacer
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onRightClick,
              child: rightIcon ?? const SizedBox(width: 28),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
