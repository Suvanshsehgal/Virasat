class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://localhost:8000';

  // Endpoints
  static const String predict = '/predict';
  static const String processYoutube = '/process-youtube';
  static const String compareMonuments = '/compare-monuments';
  static const String searchMonument = '/search-monument';
  static const String chat = '/chat';
  static const String heritageQuiz = '/heritage-quiz';
  static const String heritageTimeline = '/heritage-timeline';
  static const String monumentStory = '/monument-story';
  static const String travelItinerary = '/travel-itinerary';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
