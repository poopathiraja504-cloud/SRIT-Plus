import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/campus_links.dart';

class CampusSection {
  const CampusSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.intro,
    required this.highlights,
    this.actionLabel,
    this.actionUri,
    this.secondaryActionLabel,
    this.secondaryActionUri,
    this.requiresStudentData = false,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String intro;
  final List<CampusHighlight> highlights;
  final String? actionLabel;
  final Uri? actionUri;
  final String? secondaryActionLabel;
  final Uri? secondaryActionUri;
  final bool requiresStudentData;
}

class CampusHighlight {
  const CampusHighlight(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}

const sritFeePortal = 'https://www.sritcbe.ac.in/online-feepayment';
const sritContactPage = 'https://www.sritcbe.ac.in/contact';
const sritMapsLocation = 'https://maps.app.goo.gl/ke2dh1Dg5inRdNHp8';

final campusSections = <CampusSection>[
  CampusSection(
    title: 'Academics',
    icon: Icons.menu_book_rounded,
    color: const Color(0xFF006B50),
    intro:
        'Explore academic resources and the latest information from SRIT. '
        'Use the official site for current schedules and documents.',
    highlights: const [
      CampusHighlight(
        'Departments',
        'Explore engineering and technology departments and their programmes.',
        Icons.account_tree_outlined,
      ),
      CampusHighlight(
        'Academic Calendar',
        'Find semester dates, holidays and key academic activities.',
        Icons.calendar_month_outlined,
      ),
      CampusHighlight(
        'Syllabus',
        'Access programme curricula and course details.',
        Icons.library_books_outlined,
      ),
      CampusHighlight(
        'Examination Details',
        'Check examination notices, schedules and related information.',
        Icons.fact_check_outlined,
      ),
      CampusHighlight(
        'Examination Cell',
        'Review examination-cell notices and assessment information.',
        Icons.assignment_turned_in_outlined,
      ),
      CampusHighlight(
        'Academic Regulations',
        'Read the regulations governing programmes and academic progression.',
        Icons.rule_outlined,
      ),
    ],
    actionLabel: 'Visit SRIT website',
    actionUri: Uri.parse(sritWebsite),
  ),
  CampusSection(
    title: 'Admission',
    icon: Icons.assignment_turned_in_rounded,
    color: const Color(0xFF15906F),
    intro:
        'Find programme and admission information. Eligibility, fees and '
        'scholarship terms may change; confirm current details with SRIT.',
    highlights: const [
      CampusHighlight(
        'Courses Offered',
        'Review undergraduate and postgraduate engineering programmes.',
        Icons.school_outlined,
      ),
      CampusHighlight(
        'Eligibility Criteria',
        'Check the latest academic and admission requirements.',
        Icons.rule_outlined,
      ),
      CampusHighlight(
        'Fee Structure',
        'Confirm tuition and other charges with the admissions office.',
        Icons.currency_rupee,
      ),
      CampusHighlight(
        'Scholarships',
        'Ask about available scholarships and applicable eligibility.',
        Icons.workspace_premium_outlined,
      ),
    ],
    actionLabel: 'View admission information',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/admission'),
  ),
  CampusSection(
    title: 'About Us',
    icon: Icons.account_balance_rounded,
    color: const Color(0xFF4E9A76),
    intro:
        'Sri Ramakrishna Institute of Technology is an autonomous engineering '
        'institution in Coimbatore, established in 2002.',
    highlights: const [
      CampusHighlight(
        'Vision',
        'To develop into a World Class Technological Institute with centres '
            'of excellence in various disciplines.',
        Icons.visibility_outlined,
      ),
      CampusHighlight(
        'Mission',
        'To produce Quality Engineers, Scientists and Managers equipped with '
            'unbounded technical skills, domain knowledge and excellent moral '
            'values.',
        Icons.flag_outlined,
      ),
      CampusHighlight(
        'Management',
        'SRIT is governed by the SNR Sons Charitable Trust. The official '
            'management page identifies Shri Sundar Ramakrishnan as Managing '
            'Trustee.',
        Icons.groups_2_outlined,
      ),
      CampusHighlight(
        'Managing Trustee',
        'Read the official message from the Managing Trustee of SNR Sons '
            'Charitable Trust.',
        Icons.record_voice_over_outlined,
      ),
      CampusHighlight(
        'Principal Message',
        'Message from Dr. J. David Rathnaraj, Principal of SRIT.',
        Icons.person_outline_rounded,
      ),
      CampusHighlight(
        'College History',
        'Established in 2002 and governed by the SNR Sons Charitable Trust.',
        Icons.history_edu_outlined,
      ),
      CampusHighlight(
        'Campus Overview',
        'Explore SRIT’s 49.99-acre Coimbatore campus and facilities.',
        Icons.landscape_outlined,
      ),
    ],
    actionLabel: 'More about SRIT',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/about'),
    secondaryActionLabel: 'Management',
    secondaryActionUri: Uri.parse('https://www.sritcbe.ac.in/management'),
  ),
  CampusSection(
    title: 'Placement',
    icon: Icons.work_outline_rounded,
    color: const Color(0xFF65A653),
    intro:
        'Discover career preparation and placement resources. For current '
        'statistics and recruiter lists, visit the official placement pages.',
    highlights: const [
      CampusHighlight(
        'Placement Statistics',
        'View the latest placement outcomes published by the institution.',
        Icons.bar_chart_rounded,
      ),
      CampusHighlight(
        'Top Recruiters',
        'Explore organisations participating in campus recruitment.',
        Icons.business_center_outlined,
      ),
      CampusHighlight(
        'Recruiters',
        'Explore organisations participating in campus recruitment.',
        Icons.apartment_outlined,
      ),
      CampusHighlight(
        'Training Programs',
        'Learn about employability, aptitude and technical training.',
        Icons.model_training_outlined,
      ),
      CampusHighlight(
        'Success Stories',
        'Read student and alumni stories from the official SRIT website.',
        Icons.emoji_events_outlined,
      ),
      CampusHighlight(
        'Placement Officer',
        'Contact details are available through the official SRIT website.',
        Icons.support_agent_rounded,
      ),
    ],
    actionLabel: 'Explore placements',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/placement'),
  ),
  CampusSection(
    title: 'Research',
    icon: Icons.science_outlined,
    color: const Color(0xFF77AA67),
    intro:
        'Learn about research activity and innovation at SRIT. Browse the '
        'official site for updated publications and project information.',
    highlights: const [
      CampusHighlight(
        'Research Centers',
        'Explore research facilities and areas of institutional focus.',
        Icons.hub_outlined,
      ),
      CampusHighlight(
        'Research Centres',
        'Explore research facilities and centres at the institution.',
        Icons.science_outlined,
      ),
      CampusHighlight(
        'Publications',
        'Find faculty and student research publications.',
        Icons.article_outlined,
      ),
      CampusHighlight(
        'Patents',
        'Discover intellectual property and patent activity.',
        Icons.lightbulb_outline_rounded,
      ),
      CampusHighlight(
        'Projects',
        'Explore funded, academic and collaborative research projects.',
        Icons.biotech_outlined,
      ),
      CampusHighlight(
        'Funded Projects',
        'Explore externally funded and sponsored research projects.',
        Icons.account_balance_outlined,
      ),
    ],
    actionLabel: 'Explore research',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/research'),
  ),
  CampusSection(
    title: 'COE',
    icon: Icons.stars_rounded,
    color: const Color(0xFF318F6D),
    intro:
        'Centres of Excellence provide opportunities for applied learning, '
        'experimentation and emerging technology exploration.',
    highlights: const [
      CampusHighlight(
        'AI & ML COE',
        'Explore artificial intelligence and machine learning.',
        Icons.psychology_outlined,
      ),
      CampusHighlight(
        'IoT COE',
        'Discover connected devices, sensors and Internet of Things projects.',
        Icons.sensors_outlined,
      ),
      CampusHighlight(
        'Cloud Computing COE',
        'Learn about cloud platforms and distributed applications.',
        Icons.cloud_outlined,
      ),
      CampusHighlight(
        'Cyber Security COE',
        'Explore security awareness, defensive technologies and labs.',
        Icons.security_outlined,
      ),
    ],
    actionLabel: 'Explore SRIT',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/centre-of-excellence-coe'),
  ),
  CampusSection(
    title: 'Online Fee Payment',
    icon: Icons.payments_outlined,
    color: const Color(0xFF2C9B6F),
    intro:
        'Continue to the SRIT website to access the current online fee '
        'payment service. Verify the destination before entering payment '
        'details.',
    highlights: const [
      CampusHighlight(
        'Secure payment',
        'Use only payment links published by the institution and retain your '
            'transaction receipt.',
        Icons.verified_user_outlined,
      ),
    ],
    actionLabel: 'Open fee payment',
    actionUri: Uri.parse(sritFeePortal),
  ),
  CampusSection(
    title: 'Contact Us',
    icon: Icons.contact_page_outlined,
    color: const Color(0xFF267F5D),
    intro:
        'Sri Ramakrishna Institute of Technology, Coimbatore, Tamil Nadu, '
        'India. Visit the official contact page for current phone and email '
        'details.',
    highlights: const [
      CampusHighlight(
        'College Address',
        'Pachapalayam (Post), Perur Chettipalayam, Coimbatore - 641 010, India.',
        Icons.location_on_outlined,
      ),
      CampusHighlight('Phone Number', '+91-422-2605577', Icons.call_outlined),
      CampusHighlight('Email', 'principal@sritcbe.ac.in', Icons.email_outlined),
      CampusHighlight(
        'Website',
        'Official SRIT website: www.sritcbe.ac.in',
        Icons.language_rounded,
      ),
    ],
    actionLabel: 'Open in Google Maps',
    actionUri: Uri.parse(sritMapsLocation),
    secondaryActionLabel: 'Contact SRIT',
    secondaryActionUri: Uri.parse(sritContactPage),
  ),
  CampusSection(
    title: 'Programs and Courses',
    icon: Icons.school_outlined,
    color: const Color(0xFF006B50),
    intro:
        'Explore SRIT’s published undergraduate, postgraduate and research '
        'programmes. Confirm current offerings and eligibility with the '
        'official admissions information.',
    highlights: const [
      CampusHighlight(
        'Undergraduate programmes',
        'Computer Science and Engineering, Electronics and Communication '
            'Engineering, Electrical and Electronics Engineering, Mechanical '
            'Engineering, Information Technology, and Artificial Intelligence '
            'and Data Science are listed on SRIT’s departments page.',
        Icons.school_outlined,
      ),
      CampusHighlight(
        'Postgraduate and research programmes',
        'The official programmes page lists postgraduate and Anna University '
            'research options. Programme availability may change.',
        Icons.menu_book_outlined,
      ),
      CampusHighlight(
        'Curriculum and syllabus',
        'Use each official department page for its published curriculum and '
            'programme information.',
        Icons.library_books_outlined,
      ),
    ],
    actionLabel: 'Browse official programmes',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/departments'),
  ),
  CampusSection(
    title: 'Facilities',
    icon: Icons.apartment_outlined,
    color: const Color(0xFF328261),
    intro:
        'SRIT’s official facilities pages describe campus learning spaces, '
        'student amenities and support services.',
    highlights: const [
      CampusHighlight(
        'Innovation and entrepreneurship',
        'HIVE supports innovation, research and entrepreneurial activities.',
        Icons.lightbulb_outline_rounded,
      ),
      CampusHighlight(
        'Smart classrooms',
        'The facilities page describes technology-enabled classrooms and an '
            'EDUSAT hall.',
        Icons.cast_for_education_outlined,
      ),
      CampusHighlight(
        'Campus amenities',
        'Review official information about hostels, cafeteria, transport and '
            'other campus facilities.',
        Icons.domain_outlined,
      ),
    ],
    actionLabel: 'Explore official facilities',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/facilities'),
  ),
  CampusSection(
    title: 'Laboratories and Research Facilities',
    icon: Icons.science_outlined,
    color: const Color(0xFF77AA67),
    intro:
        'SRIT describes department laboratories and an e-Yantra robotics and '
        'embedded-systems laboratory established in association with IIT '
        'Bombay. Refer to official department pages for current details.',
    highlights: const [
      CampusHighlight(
        'Department laboratories',
        'Laboratory facilities are described on the official facilities and '
            'department pages.',
        Icons.biotech_outlined,
      ),
      CampusHighlight(
        'e-Yantra Lab',
        'The official facilities page describes a robotics and embedded '
            'systems laboratory in association with IIT Bombay.',
        Icons.precision_manufacturing_outlined,
      ),
      CampusHighlight(
        'Research',
        'Research activity, centres and publications are maintained by SRIT.',
        Icons.science_outlined,
      ),
    ],
    actionLabel: 'View facilities and research',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/facilities'),
    secondaryActionLabel: 'Research at SRIT',
    secondaryActionUri: Uri.parse('https://www.sritcbe.ac.in/research'),
  ),
  CampusSection(
    title: 'Library',
    icon: Icons.local_library_outlined,
    color: const Color(0xFF4E946D),
    intro:
        'SRIT’s library supports academic, research and professional '
        'development for undergraduate and postgraduate students.',
    highlights: const [
      CampusHighlight(
        'Library information',
        'Refer to the official library page for services and current access '
            'information.',
        Icons.menu_book_outlined,
      ),
    ],
    actionLabel: 'Open the official library page',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/library'),
  ),
  CampusSection(
    title: 'Hostel',
    icon: Icons.hotel_outlined,
    color: const Color(0xFF168A5C),
    intro:
        'The official SRIT facilities page describes separate hostels for '
        'women and men, with campus support amenities.',
    highlights: const [
      CampusHighlight(
        'Hostel facilities',
        'See SRIT’s official page for current facilities, availability and '
            'contact information.',
        Icons.bed_outlined,
      ),
    ],
    actionLabel: 'View official hostel information',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/facilities'),
  ),
  CampusSection(
    title: 'Transportation',
    icon: Icons.directions_bus_outlined,
    color: const Color(0xFF168A5C),
    intro:
        'SRIT publishes bus-route information through its official contact '
        'page. Check the latest document before planning travel.',
    highlights: const [
      CampusHighlight(
        'Bus routes',
        'Current routes and timings are published by SRIT and may be updated.',
        Icons.route_outlined,
      ),
    ],
    actionLabel: 'View contact and transport information',
    actionUri: Uri.parse(sritContactPage),
  ),
  CampusSection(
    title: 'Sports and Activities',
    icon: Icons.sports_basketball_outlined,
    color: const Color(0xFF65A653),
    intro:
        'SRIT’s facilities page describes indoor and outdoor sports, physical '
        'education and student activities.',
    highlights: const [
      CampusHighlight(
        'Sports facilities',
        'Read the official page for sports amenities and reported activities.',
        Icons.sports_outlined,
      ),
      CampusHighlight(
        'Student activities',
        'Official events and activities are published by SRIT.',
        Icons.celebration_outlined,
      ),
    ],
    actionLabel: 'Explore facilities and activities',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/facilities'),
    secondaryActionLabel: 'News and events',
    secondaryActionUri: Uri.parse('https://www.sritcbe.ac.in/news-events'),
  ),
  CampusSection(
    title: 'Internships',
    icon: Icons.work_history_outlined,
    color: const Color(0xFF65A653),
    intro:
        'SRIT’s Training and Placement Office describes internship and '
        'industrial-training support among its activities. Check the official '
        'page for current opportunities.',
    highlights: const [
      CampusHighlight(
        'Placement and training',
        'The official office supports career development, industry '
            'engagement, internships and campus recruitment.',
        Icons.model_training_outlined,
      ),
    ],
    actionLabel: 'Visit Training and Placement',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/placement'),
  ),
  CampusSection(
    title: 'Student Achievements',
    icon: Icons.emoji_events_outlined,
    color: const Color(0xFF4A9A75),
    intro:
        'Browse official SRIT announcements for academic, sports, cultural '
        'and technical achievements.',
    highlights: const [
      CampusHighlight(
        'Verified updates',
        'Only announcements published by SRIT are linked here; no unverified '
            'results or statistics are displayed.',
        Icons.verified_outlined,
      ),
    ],
    actionLabel: 'Read official news and events',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/news-events'),
  ),
  CampusSection(
    title: 'Clubs and Associations',
    icon: Icons.groups_2_outlined,
    color: const Color(0xFF4E946D),
    intro:
        'Department associations and student clubs publish their activities '
        'through SRIT’s official news and events pages.',
    highlights: const [
      CampusHighlight(
        'Student clubs',
        'Find current club details and activities through the official SRIT '
            'website.',
        Icons.groups_outlined,
      ),
    ],
    actionLabel: 'Explore clubs',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/clubs'),
    secondaryActionLabel: 'News and events',
    secondaryActionUri: Uri.parse('https://www.sritcbe.ac.in/news-events'),
  ),
  CampusSection(
    title: 'Gallery',
    icon: Icons.photo_library_outlined,
    color: const Color(0xFF267F5D),
    intro:
        'Open the official SRIT news and events pages for institution-published '
        'campus photographs and event coverage.',
    highlights: const [
      CampusHighlight(
        'Official campus gallery',
        'The college website is the source for the latest campus and event '
            'photographs.',
        Icons.photo_camera_outlined,
      ),
    ],
    actionLabel: 'Open official SRIT gallery',
    actionUri: Uri.parse('https://www.srit.org/gallery.html'),
    secondaryActionLabel: 'Latest news and events',
    secondaryActionUri: Uri.parse('https://www.sritcbe.ac.in/news-events'),
  ),
  CampusSection(
    title: 'Faculty and Staff',
    icon: Icons.people_alt_outlined,
    color: const Color(0xFF328261),
    intro:
        'Faculty details and departmental contacts should be taken from the '
        'official department pages to keep roles and contact information '
        'current.',
    highlights: const [
      CampusHighlight(
        'Department faculty',
        'Open an official department page for its published faculty, '
            'department contacts and academic information.',
        Icons.person_search_outlined,
      ),
    ],
    actionLabel: 'Browse official departments',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/departments'),
  ),
  CampusSection(
    title: 'Attendance',
    icon: Icons.fact_check_outlined,
    color: const Color(0xFF168A5C),
    intro:
        'Attendance is personal student information. This app has no '
        'administrator-approved SRIT student-record connection configured, '
        'so it does not display attendance data.',
    highlights: const [
      CampusHighlight(
        'Secure student records',
        'Attendance will only appear after SRIT provides the approved data '
            'source and access rules.',
        Icons.lock_outline,
      ),
    ],
    requiresStudentData: true,
  ),
  CampusSection(
    title: 'Internal Marks',
    icon: Icons.grading_outlined,
    color: const Color(0xFF4E946D),
    intro:
        'Internal marks are personal academic records. They are not stored in '
        'the current app database.',
    highlights: const [
      CampusHighlight(
        'Secure student records',
        'Marks will only appear after SRIT provides the approved data source '
            'and access rules.',
        Icons.lock_outline,
      ),
    ],
    requiresStudentData: true,
  ),
  CampusSection(
    title: 'Exam Results',
    icon: Icons.assessment_outlined,
    color: const Color(0xFF006B50),
    intro:
        'Examination results are personal academic records. No SRIT results '
        'service is configured in the current app.',
    highlights: const [
      CampusHighlight(
        'Secure student records',
        'Results will only appear after SRIT provides the approved data source '
            'and access rules.',
        Icons.lock_outline,
      ),
    ],
    requiresStudentData: true,
  ),
  CampusSection(
    title: 'Timetable',
    icon: Icons.calendar_month_outlined,
    color: const Color(0xFF65A653),
    intro:
        'Personal class and examination timetables are not connected to the '
        'current app database.',
    highlights: const [
      CampusHighlight(
        'Secure student records',
        'A timetable will only appear after SRIT provides the approved data '
            'source.',
        Icons.lock_outline,
      ),
    ],
    requiresStudentData: true,
  ),
  CampusSection(
    title: 'Study Materials',
    icon: Icons.library_books_outlined,
    color: const Color(0xFF328261),
    intro:
        'Study materials are not connected to the current app. Use official '
        'SRIT course and department pages for published academic resources.',
    highlights: const [
      CampusHighlight(
        'Official academic resources',
        'Programme and syllabus information is published on SRIT’s official '
            'department pages.',
        Icons.menu_book_outlined,
      ),
    ],
    actionLabel: 'Browse departments',
    actionUri: Uri.parse('https://www.sritcbe.ac.in/departments'),
    requiresStudentData: true,
  ),
  CampusSection(
    title: 'Student Profile',
    icon: Icons.account_circle_outlined,
    color: const Color(0xFF267F5D),
    intro:
        'This page shows only the name and email provided by the currently '
        'authenticated SRIT PORTAL account. Register number, department and year '
        'are not connected.',
    highlights: const [
      CampusHighlight(
        'Privacy',
        'No student information is fabricated or looked up from an '
            'unconfigured database.',
        Icons.verified_user_outlined,
      ),
    ],
    requiresStudentData: true,
  ),
  ...sritDepartmentSections,
];

CampusSection _departmentSection({
  required String title,
  required IconData icon,
  required Color color,
  required String introduction,
  required String vision,
  required String mission,
  required String pageUrl,
  required String pageLabel,
}) {
  return CampusSection(
    title: title,
    icon: icon,
    color: color,
    intro: introduction,
    highlights: [
      CampusHighlight('Vision', vision, Icons.visibility_outlined),
      CampusHighlight('Mission', mission, Icons.flag_outlined),
      CampusHighlight(
        'Courses and curriculum',
        'See the official department page for its current programmes, '
            'curriculum and syllabi.',
        Icons.menu_book_outlined,
      ),
      CampusHighlight(
        'Faculty, laboratories and research',
        'The department website is the source for current faculty, facilities '
            'and research information.',
        Icons.science_outlined,
      ),
      CampusHighlight(
        'Achievements and events',
        'Check the official SRIT news and events page for institution-published '
            'updates.',
        Icons.emoji_events_outlined,
      ),
      CampusHighlight(
        'Department contact',
        'Use the official department page for current faculty and contact '
            'details. General college contacts are on the official contact '
            'page.',
        Icons.contact_mail_outlined,
      ),
    ],
    actionLabel: pageLabel,
    actionUri: Uri.parse(pageUrl),
    secondaryActionLabel: 'Official news and events',
    secondaryActionUri: Uri.parse('https://www.sritcbe.ac.in/news-events'),
  );
}

final sritDepartmentSections = <CampusSection>[
  _departmentSection(
    title: 'Computer Science and Engineering',
    icon: Icons.computer_rounded,
    color: const Color(0xFF006B50),
    introduction:
        'Established in 2002, SRIT’s Computer Science and Engineering '
        'department offers an autonomous programme affiliated with Anna '
        'University and approved by AICTE.',
    vision:
        'To develop into a globally visible knowledge community, imparting '
        'technical training and research advancements with high technical '
        'competency and moral values.',
    mission:
        'Produce quality engineers, entrepreneurs, researchers and technical '
        'consultants; enhance programming skills, domain knowledge and moral '
        'values; and contribute to sustainable societal needs.',
    pageUrl: 'https://www.sritcbe.ac.in/be-cse',
    pageLabel: 'Open official CSE page',
  ),
  _departmentSection(
    title: 'Electronics and Communication Engineering',
    icon: Icons.memory_rounded,
    color: const Color(0xFF15906F),
    introduction:
        'Established in 2002, the Electronics and Communication Engineering '
        'department offers a four-year B.E. programme affiliated with Anna '
        'University and accredited by NBA.',
    vision:
        'To produce professionally challenging and socially profound '
        'engineers, capable of working in a global environment with a centre '
        'of excellence in Communication Engineering.',
    mission:
        'Produce quality engineers with managerial skills and ethical '
        'standards; nurture originality and creativity; and teach the modern '
        'skills needed by industry and society.',
    pageUrl: 'https://www.sritcbe.ac.in/be-ece',
    pageLabel: 'Open official ECE page',
  ),
  _departmentSection(
    title: 'Electrical and Electronics Engineering',
    icon: Icons.electric_bolt_rounded,
    color: const Color(0xFF4A9A75),
    introduction:
        'Established in 2002, the EEE department offers undergraduate and '
        'postgraduate study and is a recognised Anna University research '
        'centre.',
    vision:
        'To produce holistic electrical and electronics engineers who excel '
        'in interdisciplinary domains.',
    mission:
        'Develop competent EEE graduates through technology-oriented '
        'education, and empower students with domain knowledge, creativity '
        'and skills.',
    pageUrl: 'https://www.sritcbe.ac.in/be-eee',
    pageLabel: 'Open official EEE page',
  ),
  _departmentSection(
    title: 'Mechanical Engineering',
    icon: Icons.precision_manufacturing_rounded,
    color: const Color(0xFF77AA67),
    introduction:
        'Established in 2005, the department offers undergraduate Mechanical '
        'Engineering study spanning engineering fundamentals and practical '
        'applications.',
    vision:
        'Develop world-class engineers skilled in contemporary mechanical '
        'engineering technologies, able to meet industry and societal needs '
        'and promote entrepreneurship.',
    mission:
        'Provide quality, value-based education; foster innovative research '
        'and lifelong learning; and build industry interaction, teamwork, '
        'entrepreneurship and ethical values.',
    pageUrl: 'https://www.sritcbe.ac.in/be-mech',
    pageLabel: 'Open official Mechanical page',
  ),
  _departmentSection(
    title: 'Information Technology',
    icon: Icons.devices_rounded,
    color: const Color(0xFF4E946D),
    introduction:
        'SRIT’s Information Technology department was established in the '
        '2006–2007 academic year. Its official page describes the programme '
        'and department facilities.',
    vision:
        'Develop the department as a centre of excellence in Information '
        'Technology by upgrading hardware, software and faculty quality.',
    mission:
        'Develop quality IT professionals with domain knowledge, analytical '
        'skills, creativity and high moral values.',
    pageUrl: 'https://www.sritcbe.ac.in/btech-it',
    pageLabel: 'Open official IT page',
  ),
  _departmentSection(
    title: 'Artificial Intelligence and Data Science',
    icon: Icons.psychology_outlined,
    color: const Color(0xFF267F5D),
    introduction:
        'Established in 2025, the Artificial Intelligence and Data Science '
        'department follows an outcome-based curriculum in AI, data science '
        'and emerging technologies.',
    vision:
        'Develop a centre of excellence in Artificial Intelligence and Data '
        'Science through quality multidisciplinary education and prepare '
        'skilled, ethical professionals.',
    mission:
        'Teach strong AI and data-science foundations; promote innovation, '
        'research and entrepreneurship; and develop skilled, ethical '
        'professionals through industry interaction and lifelong learning.',
    pageUrl: 'https://www.sritcbe.ac.in/ai-in-ds',
    pageLabel: 'Open official AI and DS page',
  ),
];

class CampusSectionPage extends StatelessWidget {
  const CampusSectionPage({required this.section, super.key});

  final CampusSection section;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(section.title)),
      body: CampusSectionContent(section: section),
    );
  }
}

class CampusSectionContent extends StatelessWidget {
  const CampusSectionContent({required this.section, super.key});

  final CampusSection section;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: section.color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(section.icon, color: section.color, size: 34),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  section.intro,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (section.requiresStudentData) _StudentDataCard(section: section),
        ...section.highlights.map(
          (highlight) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: section.color.withValues(alpha: 0.1),
                foregroundColor: section.color,
                child: Icon(highlight.icon),
              ),
              title: Text(
                highlight.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(highlight.description),
              ),
            ),
          ),
        ),
        if (section.actionUri != null) ...[
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => openCampusLink(context, section.actionUri!),
            icon: Icon(
              section.title == 'Contact Us'
                  ? Icons.map_outlined
                  : Icons.open_in_new_rounded,
            ),
            label: Text(section.actionLabel ?? 'Open link'),
          ),
        ],
        if (section.secondaryActionUri != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                openCampusLink(context, section.secondaryActionUri!),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(section.secondaryActionLabel ?? 'More information'),
          ),
        ],
      ],
    );
  }
}

class _StudentDataCard extends StatelessWidget {
  const _StudentDataCard({required this.section});

  final CampusSection section;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (section.title != 'Student Profile') {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('SRIT student records are not connected'),
          subtitle: Text(
            user == null
                ? 'Sign in and contact the SRIT administrator to connect an '
                      'approved student data source.'
                : 'Signed in as ${user.email ?? 'your SRIT PORTAL account'}. '
                      'Contact the SRIT administrator to connect an approved '
                      'student data source.',
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: Text(user?.displayName ?? 'No display name provided'),
            subtitle: Text(user?.email ?? 'No email provided'),
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Academic profile not connected'),
            subtitle: Text(
              'Register number, department, year and academic records are not '
              'available from the current Firebase configuration.',
            ),
          ),
        ],
      ),
    );
  }
}
