// lib/models/course_model.dart
import 'package:flutter/material.dart';

// ✅ 일반 코스 모델 (사용자 개발 코스 & 저장된 코스)
class CourseModel {
  final String id;
  final String title;
  final String location;
  final String distance;
  final String duration;
  final String imageUrl;
  final bool isCompleted;
  final Color? completedColor;

  // 사용자 개발 코스에서 쓰이는 요소
  final int? likes;
  final int? scraps;
  final int? reports;
  final bool? isUploadedByUser;

  const CourseModel({
    required this.id,
    required this.title,
    required this.location,
    required this.distance,
    required this.duration,
    required this.imageUrl,
    required this.isCompleted,
    this.completedColor,
    this.likes,
    this.scraps,
    this.reports,
    this.isUploadedByUser,
  });
}

// ✅ 챌린지 코스 모델 (코스 챌린지 전용)
class ChallengeCourseModel {
  final String id;
  final String title;
  final String location;
  final String distance;
  final String duration;
  final String imageUrl;
  final bool isCompleted;
  final int eumPoint; // 보상 포인트
  final String description; // 도전 설명
  final int challengers; // 도전 성공자 수

  const ChallengeCourseModel({
    required this.id,
    required this.title,
    required this.location,
    required this.distance,
    required this.duration,
    required this.imageUrl,
    required this.isCompleted,
    required this.eumPoint,
    required this.description,
    required this.challengers,
  });
}
