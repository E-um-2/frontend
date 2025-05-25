// lib/data/mock_course_data.dart

import 'package:flutter/material.dart';
import '../../models/course_model.dart';

// ✅ 사용자 개발 코스 (3개)
final List<CourseModel> mockUserDevelopedCourses = [
  CourseModel(
    id: 'u1',
    title: '사람 옆모습',
    location: '인천 청라 부근',
    distance: '20km',
    duration: '2시간 10분',
    imageUrl: 'assets/images/course1.png',
    isCompleted: true,
    completedColor: Color(0xFF38CCBE),
    likes: 41,
    scraps: 10,
    reports: 0,
    isUploadedByUser: true,
  ),
  CourseModel(
    id: 'u2',
    title: '정사각형 경로',
    location: '인천 문학산 부근',
    distance: '18km',
    duration: '1시간 50분',
    imageUrl: 'assets/images/course2.png',
    isCompleted: false,
    completedColor: Color(0xFF38CCBE),
    likes: 22,
    scraps: 6,
    reports: 1,
    isUploadedByUser: true,
  ),
  CourseModel(
    id: 'u3',
    title: '강아지 경로',
    location: '인천 송도 부근',
    distance: '24km',
    duration: '2시간 30분',
    imageUrl: 'assets/images/course3.png',
    isCompleted: true,
    completedColor: Color(0xFF38CCBE),
    likes: 18,
    scraps: 7,
    reports: 0,
    isUploadedByUser: true,
  ),
];

// ✅ 내가 그린 코스 (0개, 틀만 존재)
final List<CourseModel> mockDrawnCourses = [];

// ✅ 저장된 코스 (2개)
final List<CourseModel> mocksavedCourses = [
  CourseModel(
    id: 's1',
    title: '사람 옆모습',
    location: '인천 청라 부근',
    distance: '20km',
    duration: '2시간 10분',
    imageUrl: 'assets/images/course1.png',
    isCompleted: true,
    completedColor: Color(0xFF00A2FF),
    likes: 12,
    scraps: 5,
    reports: 0,
    isUploadedByUser: false,
  ),
  CourseModel(
    id: 's2',
    title: '정사각형 경로',
    location: '인천 문학산 부근',
    distance: '22km',
    duration: '2시간 20분',
    imageUrl: 'assets/images/course2.png',
    isCompleted: false,
    completedColor: Color(0xFF00A2FF),
    likes: 8,
    scraps: 3,
    reports: 0,
    isUploadedByUser: false,
  ),
];
