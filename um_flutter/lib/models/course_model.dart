import 'package:flutter/material.dart';

// ✅ [1] 일반 코스 모델 (기본 속성)
abstract class CourseModel {
  final String id;
  final String title;
  final String location;
  final String distance;
  final String duration;
  final String imageUrl;
  final bool isCompleted;
  final String description;
  final Color? completedColor;

  const CourseModel({
    required this.id,
    required this.title,
    required this.location,
    required this.distance,
    required this.duration,
    required this.imageUrl,
    required this.isCompleted,
    required this.description,
    this.completedColor,
  });
}

// ✅ [2] 사용자 개발 코스 모델
class UserDevelopedCourseModel extends CourseModel {
  final int likes;
  final int scraps;
  final int reports;
  final bool isUploadedByUser;
  final String authorName; // 👈 사용자 이름
  final String createdAt; // 👈 작성 시간 (예: "05/20 13:22")

  const UserDevelopedCourseModel({
    required super.id,
    required super.title,
    required super.location,
    required super.distance,
    required super.duration,
    required super.imageUrl,
    required super.isCompleted,
    required super.description,
    required this.likes,
    required this.scraps,
    required this.reports,
    required this.isUploadedByUser,
    required this.authorName,
    required this.createdAt,
    super.completedColor,
  });
}

// ✅ [3] 저장된 코스 모델 (일반 코스 속성 그대로 사용 가능하므로 BaseCourseModel 사용)
// 필요시 추가 확장 가능

// ✅ [4] 코스 챌린지 모델
class ChallengeCourseModel extends CourseModel {
  final int eumPoint; // 보상 포인트
  final int challengers; // 도전 성공자 수

  const ChallengeCourseModel({
    required super.id,
    required super.title,
    required super.location,
    required super.distance,
    required super.duration,
    required super.imageUrl,
    required super.isCompleted,
    required super.description,
    required this.eumPoint,
    required this.challengers,
    super.completedColor,
  });
}

class DrawnCourseModel extends CourseModel {
  const DrawnCourseModel({
    required super.id,
    required super.title,
    required super.location,
    required super.distance,
    required super.duration,
    required super.imageUrl,
    required super.isCompleted,
    required super.description,
    super.completedColor,
  });
}

class SavedCourseModel extends CourseModel {
  const SavedCourseModel({
    required super.id,
    required super.title,
    required super.location,
    required super.distance,
    required super.duration,
    required super.imageUrl,
    required super.isCompleted,
    required super.description,
    super.completedColor,
  });
}
