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
}

class CampusHighlight {
  const CampusHighlight(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}

const sritFeePortal = 'https://www.sritcbe.ac.in/';
const sritContactPage = 'https://www.sritcbe.ac.in/contact';
const sritMapsLocation =
    'https://www.google.com/maps/search/?api=1&query=Sri+Ramakrishna+Institute+of+Technology+Coimbatore';

final campusSections = <CampusSection>[
  CampusSection(
    title: 'Academics',
    icon: Icons.menu_book_rounded,
    color: const Color(0xFF2467CF),
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
    color: const Color(0xFF0F9D8A),
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
    actionLabel: 'Apply online',
    actionUri: Uri.parse(sritWebsite),
  ),
  CampusSection(
    title: 'About Us',
    icon: Icons.account_balance_rounded,
    color: const Color(0xFF8A5CC4),
    intro:
        'Sri Ramakrishna Institute of Technology is an autonomous engineering '
        'institution in Coimbatore, established in 2002.',
    highlights: const [
      CampusHighlight(
        'Vision',
        'To develop into a world-class technological institute with centres '
            'of excellence through quality, value-based education and '
            'continuous improvement.',
        Icons.visibility_outlined,
      ),
      CampusHighlight(
        'Mission',
        'To produce quality engineers, scientists and managers with strong '
            'technical skills, domain knowledge and moral values.',
        Icons.flag_outlined,
      ),
      CampusHighlight(
        'Management',
        'SRIT is governed by the SNR Sons Charitable Trust.',
        Icons.groups_2_outlined,
      ),
      CampusHighlight(
        'Chairman Message',
        'Read the institution leadership message on the official website.',
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
    actionUri: Uri.parse(sritWebsite),
  ),
  CampusSection(
    title: 'Placement',
    icon: Icons.work_outline_rounded,
    color: const Color(0xFFEF8A32),
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
    actionUri: Uri.parse(sritWebsite),
  ),
  CampusSection(
    title: 'Research',
    icon: Icons.science_outlined,
    color: const Color(0xFFDF4E6A),
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
    actionUri: Uri.parse(sritWebsite),
  ),
  CampusSection(
    title: 'COE',
    icon: Icons.stars_rounded,
    color: const Color(0xFF5969D9),
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
    actionUri: Uri.parse(sritWebsite),
  ),
  CampusSection(
    title: 'Online Fee Payment',
    icon: Icons.payments_outlined,
    color: const Color(0xFF28A66A),
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
    color: const Color(0xFF2388A8),
    intro:
        'Sri Ramakrishna Institute of Technology, Coimbatore, Tamil Nadu, '
        'India. Visit the official contact page for current phone and email '
        'details.',
    highlights: const [
      CampusHighlight(
        'College Address',
        'Vattamalaipalayam, NGGO Colony Post, Coimbatore, Tamil Nadu, India.',
        Icons.location_on_outlined,
      ),
      CampusHighlight(
        'Phone Number',
        'Open the official contact page for the latest phone numbers.',
        Icons.call_outlined,
      ),
      CampusHighlight(
        'Email',
        'Open the official contact page for current email addresses.',
        Icons.email_outlined,
      ),
      CampusHighlight('Website', 'www.sritcbe.ac.in', Icons.language_rounded),
    ],
    actionLabel: 'Open in Google Maps',
    actionUri: Uri.parse(sritMapsLocation),
    secondaryActionLabel: 'Contact SRIT',
    secondaryActionUri: Uri.parse(sritContactPage),
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
