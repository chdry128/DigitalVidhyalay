// Chhote tests — "flutter test" se chalte hain
import 'package:digital_vidyalaya/config/app_config.dart';
import 'package:digital_vidyalaya/data/models/certificate.dart';
import 'package:digital_vidyalaya/data/models/course.dart';
import 'package:digital_vidyalaya/data/models/internship.dart';
import 'package:digital_vidyalaya/data/models/quiz.dart';
import 'package:digital_vidyalaya/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatCount number me comma lagata hai', () {
    expect(formatCount(4860), '4,860');
    expect(formatCount(123456), '123,456');
    expect(formatCount(9), '9');
  });

  test('Course discount sahi nikalta hai', () {
    final Course course = Course.fromJson({'id': 1, 'title': 'Java', 'price': 9, 'mrp': 499});
    expect(course.discountPercent, 98);
    expect(course.priceLabel, '₹9');
  });

  test('Playlist: lessons + khaali module dono chalte hain', () {
    final Course course = Course.fromJson({
      'id': 7,
      'title': 'Demo',
      'price': 9,
      'modules': [
        {
          'title': 'Module 1',
          'lessons': [
            'Intro',
            {'title': 'Setup', 'videoId': 'abc123', 'duration': '5:00'},
          ],
        },
        {'title': 'Module 2', 'lessons': []},
      ],
    });
    final List<PlaylistItem> list = course.playlist;
    expect(list.length, 3);
    expect(list[0].videoId, AppConfig.demoVideoId); // videoId nahi diya → demo
    expect(list[1].videoId, 'abc123');
    expect(list[2].title, 'Module 2'); // khaali module khud lesson ban gaya
    expect(list[0].isFree, true);
    expect(list[1].isFree, false);
    expect(list.map((p) => p.key).toSet().length, 3); // har key alag
  });

  test('Quiz catalog JSON se padhta hai', () {
    final Map<int, List<QuizQuestion>> quizzes = QuizQuestion.catalogFromJson({
      'quizzes': {
        '1': [
          {'question': 'Q?', 'options': ['a', 'b', 'c', 'd'], 'answer': 2},
        ],
      },
    });
    expect(quizzes[1]!.first.options[quizzes[1]!.first.answer], 'c');
  });

  test('Certificate save karke wapas padh sakte hain', () {
    final CertificateRecord c = CertificateRecord(
      id: 'DV-2026-123456',
      type: 'course',
      itemId: 1,
      title: 'Java Programming',
      studentName: 'Rahul',
      date: DateTime(2026, 10, 26),
      scorePercent: 80,
    );
    final CertificateRecord back = CertificateRecord.fromJson(c.toJson());
    expect(back.id, c.id);
    expect(back.scorePercent, 80);
    expect(back.dateLabel, '26 October 2026');
    expect(back.verifyUrl.endsWith('?id=DV-2026-123456'), true);
  });

  test('Internship price label', () {
    final Internship stipend = Internship.fromJson(
      {'id': 1, 'title': 'X', 'type': 'stipend', 'stipend': '₹1,000/week', 'weeks': 4},
    );
    final Internship free = Internship.fromJson({'id': 2, 'title': 'Y', 'type': 'free', 'fee': 0});
    expect(stipend.priceLabel, '₹1,000/week');
    expect(free.priceLabel, 'FREE');
    expect(free.actionLabel, 'Enroll Free');
  });
}
