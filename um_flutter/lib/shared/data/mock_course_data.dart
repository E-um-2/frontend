import 'package:flutter/material.dart';
import '../../models/course_model.dart';

final List<UserDevelopedCourseModel> mockUserDevelopedCourses = [
  UserDevelopedCourseModel(
    id: 'u1',
    title: '너구리',
    location: '인천 청라 부근',
    distance: '20km',
    duration: '2시간 10분',
    imageUrl: 'assets/images/course1.png',
    isCompleted: true,
    isAnyoneCompleted: true, // ✅ 추가
    completedColor: Color(0xFF38CCBE),
    likes: 41,
    scraps: 10,
    reports: 0,
    isUploadedByUser: true,
    description: '언덕이 높은 곳이 좀 있긴 한데 할만한 코스예요!',
    authorName: '재웅',
    createdAt: '05/20 13:22',
  ),
  UserDevelopedCourseModel(
    id: 'u2',
    title: '카피바라',
    location: '인천 문학산 부근',
    distance: '18km',
    duration: '1시간 50분',
    imageUrl: 'assets/images/course2.png',
    isCompleted: false,
    isAnyoneCompleted: false, // ✅ 추가
    completedColor: Color(0xFF38CCBE),
    likes: 22,
    scraps: 6,
    reports: 1,
    isUploadedByUser: true,
    description: '정확한 사각형 회전을 유지하며 타보세요!',
    authorName: '민서',
    createdAt: '05/20 13:22',
  ),
  UserDevelopedCourseModel(
    id: 'u3',
    title: '정사각형의 미학',
    location: '인천 송도 부근',
    distance: '24km',
    duration: '2시간 30분',
    imageUrl: 'assets/images/course3.png',
    isCompleted: true,
    isAnyoneCompleted: true, // ✅ 추가
    completedColor: Color(0xFF38CCBE),
    likes: 18,
    scraps: 7,
    reports: 0,
    isUploadedByUser: true,
    description: '강아지 옆모습처럼 귀여운 경로예요!',
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
