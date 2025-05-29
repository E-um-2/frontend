import 'package:flutter/material.dart';

// 일반 코스 모델 (기본 속성)
abstract class CourseModel {
  final String id;
  String title;
  final String location;
  final String distance;
  final String duration;
  final String imageUrl;
  final bool isCompleted;
  String description;
  final Color? completedColor;

  CourseModel({
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

// [1] 내가 그린 코스 모델 (기본 속성)
class DrawnCourseModel extends CourseModel {
  DrawnCourseModel({
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

// [2] 사용자 개발 코스 모델
class UserDevelopedCourseModel extends CourseModel {
  final int likes;
  final int scraps;
  final int reports;
  final bool isUploadedByUser;
  final String authorName; // 사용자 이름
  final String createdAt; // 작성 시간

  UserDevelopedCourseModel({
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

// [3] 저장된 코스 – 따로 모델 없이 List<String> savedCourseIds 로만 관리
class SavedCourseModel extends CourseModel {
  SavedCourseModel({
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

// [4] 코스 챌린지 모델
class ChallengeCourseModel extends CourseModel {
  final int eumPoint; // 보상 포인트
  final int challengers; // 도전 성공자 수

  ChallengeCourseModel({
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
