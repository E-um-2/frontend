import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onDone;

  const NavHeader({super.key, required this.title, this.onBack, this.onDone});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 왼쪽 뒤로가기 아이콘
            GestureDetector(
              onTap: onBack ?? () => context.pop(),
              child: const Icon(Icons.chevron_left, size: 28),
            ),

            // 타이틀
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // 오른쪽 완료 버튼 (옵셔널)
            onDone != null
                ? GestureDetector(
                    onTap: onDone,
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  )
                : const SizedBox(width: 28), // 공간 맞추기용 빈 박스
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
