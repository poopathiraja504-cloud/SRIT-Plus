// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:srit_connect/screens/campus_pages.dart';
import 'package:srit_connect/screens/splash_screen.dart';

void main() {
  testWidgets('splash shows SRIT Plus branding', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('SRIT Plus'), findsOneWidget);
    expect(
      find.text('Sri Ramakrishna Institute of Technology'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('campus information page renders requested academics items', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CampusSectionPage(section: campusSections.first)),
    );
    expect(find.text('Academics'), findsOneWidget);
    expect(find.text('Departments'), findsOneWidget);
    expect(find.text('Academic Calendar'), findsOneWidget);
    expect(find.text('Syllabus'), findsOneWidget);
    expect(find.text('Examination Details'), findsOneWidget);
  });

  test('all requested dashboard sections and page topics are present', () {
    expect(
      campusSections.map((section) => section.title),
      containsAll([
        'Academics',
        'Admission',
        'About Us',
        'Placement',
        'Research',
        'COE',
        'Online Fee Payment',
        'Contact Us',
      ]),
    );

    final allTopics = campusSections
        .expand((section) => section.highlights)
        .map((highlight) => highlight.title)
        .toSet();
    expect(
      allTopics,
      containsAll([
        'Departments',
        'Academic Calendar',
        'Syllabus',
        'Examination Details',
        'Examination Cell',
        'Academic Regulations',
        'Courses Offered',
        'Eligibility Criteria',
        'Fee Structure',
        'Scholarships',
        'Vision',
        'Mission',
        'Management',
        'Managing Trustee',
        'Principal Message',
        'College History',
        'Campus Overview',
        'Placement Statistics',
        'Top Recruiters',
        'Recruiters',
        'Training Programs',
        'Success Stories',
        'Placement Officer',
        'Research Centers',
        'Research Centres',
        'Publications',
        'Patents',
        'Projects',
        'Funded Projects',
        'AI & ML COE',
        'IoT COE',
        'Cloud Computing COE',
        'Cyber Security COE',
      ]),
    );
  });

  test(
    'official department pages are available for each listed department',
    () {
      const requiredTopics = {
        'Vision',
        'Mission',
        'Courses and curriculum',
        'Faculty, laboratories and research',
        'Achievements and events',
        'Department contact',
      };
      expect(
        sritDepartmentSections.map((section) => section.title),
        containsAll([
          'Computer Science and Engineering',
          'Electronics and Communication Engineering',
          'Electrical and Electronics Engineering',
          'Mechanical Engineering',
          'Information Technology',
          'Artificial Intelligence and Data Science',
        ]),
      );
      for (final section in sritDepartmentSections) {
        expect(section.actionUri?.scheme, 'https');
        expect(
          section.highlights.map((highlight) => highlight.title),
          containsAll(requiredTopics),
        );
      }
    },
  );
}
