import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      imagePath: 'assets/images/onboarding1.png',
      subtitle: '이음이',
      subsubtitle: '도시와 사람을 잇는 자전거',
      title: '다양한 자전거 경로 주행',
      description: '간단한 정사각형부터 물고기 모양까지 !\n앱에서 제공하는 다양한 경로를 달려보세요',
    ),
    _OnboardingPageData(
      imagePath: 'assets/images/onboarding2.png',
      subtitle: '이음이',
      subsubtitle: '도시와 사람을 잇는 자전거',
      title: '인천 자전거 경로 AI 추천',
      description: '인천의 구석구석 멋진 관광지와 함께하는\n사용자 맞춤 경로를 추천받아요',
    ),
    _OnboardingPageData(
      imagePath: 'assets/images/onboarding3.png',
      subtitle: '이음이',
      subsubtitle: '도시와 사람을 잇는 자전거',
      title: '쌓여가는 e음 카드 포인트',
      description: '자전거를 많이 탈수록 포인트가 쌓여요\n환경을 지키고 혜택은 이음카드로!',
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onStartPressed() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),
            const SizedBox(height: 20),
            _buildIndicator(),
            const SizedBox(height: 20),
            if (_currentPage == _pages.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: CommonButton(
                  text: '시작하기',
                  onPressed: _onStartPressed,
                  color: const Color(0xFF3BD7CC),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPageData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // ✅ 콘텐츠 중앙 정렬
        children: [
          // 타이틀
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0085FF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.subsubtitle,
            style: const TextStyle(fontSize: 18, color: Color(0xFF8DC3E3)),
          ),
          const SizedBox(height: 32),

          // 이미지 크기 조금 키움
          Image.asset(
            data.imagePath,
            width: 280,
            height: 280,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 36),

          // 설명
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF007FC8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? const Color(0xFF0085FF)
                : Colors.black26,
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String imagePath;
  final String subtitle;
  final String subsubtitle;
  final String title;
  final String description;

  _OnboardingPageData({
    required this.imagePath,
    required this.subtitle,
    required this.subsubtitle,
    required this.title,
    required this.description,
  });
}
