import 'package:flutter/material.dart';
import '../../models/course_model.dart';

final List<UserDevelopedCourseModel> mockUserDevelopedCourses = [
  UserDevelopedCourseModel(
    id: 'u1',
    title: '너구리',
    location: '송도 센트럴파크',
    distance: '1.5km',
    duration: '10분',
    imageUrl: 'assets/images/course1.png',
    isCompleted: true,
    isAnyoneCompleted: true, // ✅ 추가
    completedColor: Color(0xFF38CCBE),
    likes: 41,
    scraps: 10,
    reports: 0,
    isUploadedByUser: true,
    description: '센트럴파크를 누비는 귀염뽀짝 너구리 한 마리!\n짧지만 정성껏 그렸어요. 한 바퀴 돌고 나면 절로 웃음 나실 거예요.',
    authorName: '재웅',
    createdAt: '05/20 13:22',
  ),
  UserDevelopedCourseModel(
    id: 'u2',
    title: '카피바라',
    location: '',
    distance: '30km',
    duration: '3시간 0분',
    imageUrl: 'assets/images/course2.png',
    isCompleted: false,
    isAnyoneCompleted: false, // ✅ 추가
    completedColor: Color(0xFF38CCBE),
    likes: 22,
    scraps: 6,
    reports: 1,
    isUploadedByUser: true,
    description: '카피바라를 그려보고 싶었어요.\n느긋한 발걸음처럼 천천히, 귀엽게 한 바퀴 돌아보세요.',
    authorName: '민서',
    createdAt: '05/20 13:22',
  ),
  UserDevelopedCourseModel(
    id: 'u3',
    title: '정사각형의 미학',
    location: '인천대학교',
    distance: '1.6km',
    duration: '15분',
    imageUrl: 'assets/images/course3.png',
    isCompleted: true,
    isAnyoneCompleted: true, // ✅ 추가
    completedColor: Color(0xFF38CCBE),
    likes: 18,
    scraps: 7,
    reports: 0,
    isUploadedByUser: true,
    description: '기하학적인 아름다움에 도전했어요.\n인천대 캠퍼스를 사각형으로 감싸듯 정확하게 그려봤습니다.',
    authorName: '재일',
    createdAt: '05/20 13:22',
  ),
];

final List<DrawnCourseModel> mockDrawnCourses = [
  DrawnCourseModel(
    id: 's1',
    title: '너구리',
    location: '인천 청라 부근',
    distance: '20km',
    duration: '2시간 10분',
    imageUrl: 'assets/images/course1.png',
    isCompleted: true,
    completedColor: Color(0xFF00A2FF),
    description: '테스트 주행 후 업로드할 예정입니다.',
  ),
  DrawnCourseModel(
    id: 's2',
    title: '키피바라',
    location: '인천 문학산 부근',
    distance: '22km',
    duration: '2시간 20분',
    imageUrl: 'assets/images/course2.png',
    isCompleted: false,
    completedColor: Color(0xFF00A2FF),
    description: '정사각형 모양을 만들기 위해 여러 번 그렸어요!',
  ),
];

// 저장된 코스
final List<SavedCourseModel> mocksavedCourses = [];
