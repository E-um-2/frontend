import '../../models/course_model.dart';

final List<ChallengeCourseModel> challengeCourseList = [
  ChallengeCourseModel(
    id: 'c1',
    title: '월미도 하트',
    location: '월미도',
    distance: '8km',
    duration: '1시간 0분',
    imageUrl: 'assets/images/challenge_course1.png',
    isCompleted: false,
    eumPoint: 5000,
    description: '사랑의 섬, 월미도를 따라 그리는 하트 코스!\n커플과 함께라면 인생샷도, 추억도 동시에 완성됩니다.',
    challengers: 132,
  ),
  ChallengeCourseModel(
    id: 'c2',
    title: '사람 얼굴',
    location: '청라 부근',
    distance: '15km',
    duration: '1시간 30분',
    imageUrl: 'assets/images/challenge_course2.png',
    isCompleted: false,
    eumPoint: 10000,
    description: '청라 도심을 따라 그리는 사람의 얼굴 윤곽선!\n개성 넘치는 라인을 따라가다 보면 신선한 재미가 기다리고 있어요.',
    challengers: 78,
  ),
  ChallengeCourseModel(
    id: 'c3',
    title: '송도 해마',
    location: '송도',
    distance: '10km',
    duration: '1시간 0분',
    imageUrl: 'assets/images/challenge_course3.png',
    isCompleted: true,
    eumPoint: 10000,
    description: '해양생물 해마를 닮은 송도의 특별한 루트!\n센트럴파크부터 바다 옆 코스까지 이색적인 도심 라이딩을 즐겨보세요.',
    challengers: 52,
  ),
  ChallengeCourseModel(
    id: 'c4',
    title: '네잎클로버',
    location: '문학경기장 일대',
    distance: '22km',
    duration: '2시간 0분',
    imageUrl: 'assets/images/challenge_course4.png',
    isCompleted: false,
    eumPoint: 20000,
    description:
    '미추홀구 중심을 네 방향으로 펼치는 행운의 클로버!\n도심 속 구석구석을 달리며 정비된 자전거길을 경험해보세요.',
    challengers: 23,
  ),
  ChallengeCourseModel(
    id: 'c5',
    title: '물고기 모양',
    location: '인천 전역',
    distance: '50km',
    duration: '5시간 30분',
    imageUrl: 'assets/images/challenge_course5.png',
    isCompleted: false,
    eumPoint: 30000,
    description: '인천 전역을 누비며 완성하는 물고기 모양의 코스!\n넓은 구간을 달리며 도심과 자연을 모두 경험할 수 있는 장거리 챌린지입니다.',
    challengers: 7,
  ),
];
