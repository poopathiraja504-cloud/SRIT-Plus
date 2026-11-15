import 'dart:async';

import 'package:flutter/material.dart';

import '../services/campus_links.dart';

class OfficialSritGallery extends StatefulWidget {
  const OfficialSritGallery({super.key, this.expanded = false});

  final bool expanded;

  @override
  State<OfficialSritGallery> createState() => _OfficialSritGalleryState();
}

class _OfficialSritGalleryState extends State<OfficialSritGallery> {
  static const _galleryBase = 'https://www.srit.org/images/gallery/';
  static const _legacyImageBase = 'https://www.srit.org/images/';
  static const _webflowBase =
      'https://cdn.prod.website-files.com/69ba31e796b16c01f4b12199/';
  static const _eventBase =
      'https://cdn.prod.website-files.com/69ba31e896b16c01f4b1219e/';
  static final _photos = <_GalleryPhoto>[
    const _GalleryPhoto.asset(
      'SRIT main campus',
      'assets/images/srit_campus_background.jpg',
    ),
    const _GalleryPhoto.network(
      'SRIT campus infrastructure',
      '${_legacyImageBase}facilities/infrasture-03.jpg',
    ),
    const _GalleryPhoto.network(
      'Smart classrooms',
      '${_legacyImageBase}facilities/classrooms-01.jpg',
    ),
    const _GalleryPhoto.network(
      'e-Yantra laboratory',
      '${_legacyImageBase}facilities/lab-01.jpg',
    ),
    const _GalleryPhoto.network(
      'SRIT central library',
      '${_legacyImageBase}facilities/Lib_2.jpg',
    ),
    const _GalleryPhoto.network(
      'SRIT sports and games',
      '${_legacyImageBase}facilities/sports-01.jpg',
    ),
    const _GalleryPhoto.network(
      'Laboratory facilities',
      '${_webflowBase}69dcc90417f6ffd629d7d113_LABOR-FACILITIES.webp',
    ),
    const _GalleryPhoto.network(
      'Innovation centre',
      '${_webflowBase}69dcc09fc206c62b83fbd243_Inovation-center.webp',
    ),
    const _GalleryPhoto.network(
      'Sports facilities',
      '${_webflowBase}69dcc1c4fc48fd7e347f2eaa_sports-facilities.webp',
    ),
    const _GalleryPhoto.network(
      'SRIT library',
      '${_webflowBase}6a1587f357834eb8c733d620_SRIT%20(2).webp',
    ),
    const _GalleryPhoto.network(
      'Computer Science and Engineering',
      '${_webflowBase}69d8f51b78981a2ebf63e4cd_computer-lab.webp',
    ),
    const _GalleryPhoto.network(
      'Electronics and Communication Engineering',
      '${_webflowBase}69d8f57b01c5f46083b7ad32_electronic-communication.webp',
    ),
    const _GalleryPhoto.network(
      'Electrical and Electronics Engineering',
      '${_webflowBase}69d8f5cd3cc2467f7e58b9e4_EEE.webp',
    ),
    const _GalleryPhoto.network(
      'Mechanical Engineering',
      '${_webflowBase}69dcb06f3a78cf7413039a27_Mech-it.webp',
    ),
    const _GalleryPhoto.network(
      'Information Technology',
      '${_webflowBase}69dcb0c439df261e74835f57_IT.webp',
    ),
    const _GalleryPhoto.network(
      'The DoIT Association',
      '${_eventBase}6a796bf35a03d7f75b76e9f7_10.jpeg',
    ),
    const _GalleryPhoto.network(
      'Inauguration of ASCONIC 2026',
      '${_eventBase}6a796908fc9a6c8683f5a829_IMG-20260806-WA0156.jpg',
    ),
    const _GalleryPhoto.network(
      'Adhithya Alumni Inter-College Meet',
      '${_eventBase}69fb3006c2dda93780c25858_13.jpeg',
    ),
    const _GalleryPhoto.network(
      'Seminar on Innovation Using AI',
      '${_eventBase}69fb2dd7693f25a949875afa_9.jpeg',
    ),
    const _GalleryPhoto.network(
      'SRIT Alumni Association',
      '${_eventBase}69fb2cbf5add882b486fd7b9_5%20(1).jpeg',
    ),
    const _GalleryPhoto.network(
      'SRIT student achievements',
      '${_legacyImageBase}other-activites/17.jpg',
    ),
    const _GalleryPhoto.network(
      'Tamil Mandram student chapter',
      '${_legacyImageBase}other-activites/19.jpg',
    ),
    const _GalleryPhoto.network(
      'TechXplore School Visit',
      '${_eventBase}69fb241e52770b5c5b4e07ab_222.jpeg',
    ),
    const _GalleryPhoto.network(
      'National Coffee Table Book',
      '${_eventBase}69fb2274ee0b30b801db2758_Coffee%20table%20(1).jpg',
    ),
    ...List<_GalleryPhoto>.generate(23, (index) {
      final number = index + 1;
      return _GalleryPhoto.network(
        'Official SRIT gallery photo $number',
        '${_galleryBase}0$number.jpg',
      );
    }),
  ];

  late final PageController _controller;
  late final Timer _timer;
  var _currentIndex = 0;
  var _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _photos.length * 1000);
    _currentIndex = (_photos.length * 1000) % _photos.length;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_isHovered || !_controller.hasClients) return;
      final currentPage = _controller.page?.round() ?? 0;
      _controller.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _moveBy(int delta) {
    if (!_controller.hasClients) return;
    final currentPage = _controller.page?.round() ?? 0;
    _controller.animateToPage(
      currentPage + delta,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _openPhoto(_GalleryPhoto photo) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.6,
                maxScale: 4,
                child: Center(child: _photoImage(photo, BoxFit.contain)),
              ),
            ),
            Positioned(
              left: 16,
              right: 68,
              bottom: 14,
              child: Text(
                photo.caption,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                tooltip: 'Close gallery image',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoImage(_GalleryPhoto photo, BoxFit fit) {
    if (photo.assetPath != null) {
      return Image.asset(
        photo.assetPath!,
        fit: fit,
        errorBuilder: (_, _, _) => const _PhotoUnavailable(),
      );
    }

    return Image.network(
      photo.url!,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        final total = progress.expectedTotalBytes;
        return Center(
          child: SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              value: total == null
                  ? null
                  : progress.cumulativeBytesLoaded / total,
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => const _PhotoUnavailable(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.expanded ? 420.0 : 280.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'SRIT Campus Gallery',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: 'Previous photo',
              onPressed: () => _moveBy(-1),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            IconButton(
              tooltip: 'Next photo',
              onPressed: () => _moveBy(1),
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: height,
              child: PageView.builder(
                controller: _controller,
                itemBuilder: (context, page) {
                  final photo = _photos[page % _photos.length];
                  return Semantics(
                    label: photo.caption,
                    button: true,
                    child: GestureDetector(
                      onTap: () => _openPhoto(photo),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _photoImage(photo, BoxFit.cover),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                                stops: [0.45, 1],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 18,
                            child: Text(
                              photo.caption,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const Positioned(
                            right: 14,
                            top: 14,
                            child: CircleAvatar(
                              backgroundColor: Color(0x990A1A2F),
                              child: Icon(
                                Icons.open_in_full_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onPageChanged: (page) =>
                    setState(() => _currentIndex = page % _photos.length),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              '${_currentIndex + 1} / ${_photos.length}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => openCampusLink(
                context,
                Uri.parse('https://www.srit.org/gallery.html'),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Official SRIT gallery'),
            ),
          ],
        ),
      ],
    );
  }
}

class _GalleryPhoto {
  const _GalleryPhoto.asset(this.caption, this.assetPath) : url = null;
  const _GalleryPhoto.network(this.caption, this.url) : assetPath = null;

  final String caption;
  final String? assetPath;
  final String? url;
}

class _PhotoUnavailable extends StatelessWidget {
  const _PhotoUnavailable();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF003D2E),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white70,
          size: 44,
        ),
      ),
    );
  }
}
