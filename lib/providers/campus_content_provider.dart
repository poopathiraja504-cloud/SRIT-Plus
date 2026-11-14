import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/campus_update.dart';
import '../services/campus_content_service.dart';

class CampusContentProvider extends ChangeNotifier {
  CampusContentProvider({CampusContentService? service})
    : _service = service ?? CampusContentService() {
    _subscribe();
  }

  final CampusContentService _service;
  StreamSubscription<List<CampusUpdate>>? _announcementsSubscription;
  StreamSubscription<List<CampusUpdate>>? _newsSubscription;
  StreamSubscription<List<CampusUpdate>>? _eventsSubscription;

  List<CampusUpdate> _announcements = const [];
  List<CampusUpdate> _news = const [];
  List<CampusUpdate> _events = const [];
  bool _isLoadingAnnouncements = true;
  bool _isLoadingNews = true;
  bool _isLoadingEvents = true;
  Object? _announcementsError;
  Object? _newsError;
  Object? _eventsError;

  List<CampusUpdate> get announcements => _announcements;
  List<CampusUpdate> get news => _news;
  List<CampusUpdate> get events => _events;
  bool get isLoadingAnnouncements => _isLoadingAnnouncements;
  bool get isLoadingNews => _isLoadingNews;
  bool get isLoadingEvents => _isLoadingEvents;
  bool get isLoading =>
      _isLoadingAnnouncements || _isLoadingNews || _isLoadingEvents;
  Object? get announcementsError => _announcementsError;
  Object? get newsError => _newsError;
  Object? get eventsError => _eventsError;

  void _subscribe() {
    _announcementsSubscription = _service.watchAnnouncements().listen(
      (items) {
        _announcements = items;
        _isLoadingAnnouncements = false;
        _announcementsError = null;
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        _isLoadingAnnouncements = false;
        _announcementsError = error;
        notifyListeners();
      },
    );
    _newsSubscription = _service.watchNews().listen(
      (items) {
        _news = items;
        _isLoadingNews = false;
        _newsError = null;
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        _isLoadingNews = false;
        _newsError = error;
        notifyListeners();
      },
    );
    _eventsSubscription = _service.watchEvents().listen(
      (items) {
        _events = items;
        _isLoadingEvents = false;
        _eventsError = null;
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        _isLoadingEvents = false;
        _eventsError = error;
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    await Future.wait([
      _announcementsSubscription?.cancel() ?? Future<void>.value(),
      _newsSubscription?.cancel() ?? Future<void>.value(),
      _eventsSubscription?.cancel() ?? Future<void>.value(),
    ]);
    _isLoadingAnnouncements = true;
    _isLoadingNews = true;
    _isLoadingEvents = true;
    _announcementsError = null;
    _newsError = null;
    _eventsError = null;
    notifyListeners();
    _subscribe();
  }

  @override
  void dispose() {
    unawaited(_announcementsSubscription?.cancel());
    unawaited(_newsSubscription?.cancel());
    unawaited(_eventsSubscription?.cancel());
    super.dispose();
  }
}
