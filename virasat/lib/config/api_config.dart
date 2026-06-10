class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://parent-pacific-sanyo-blessed.trycloudflare.com';

  // Endpoints
  static const String health = '/health';
  static const String predict = '/predict';
  static const String identifySpecific = '/identify-specific';
  static const String processYoutube = '/process-youtube';
  static const String monuments = '/monuments';
  static const String monumentDetail = '/monument';
  static const String nearbyMonuments = '/nearby-monuments';
  static const String compareMonuments = '/compare-monuments';
  static const String searchMonument = '/search-monument';
  static const String chat = '/chat';
  static const String heritageQuiz = '/heritage-quiz';
  static const String heritageTimeline = '/heritage-timeline';
  static const String monumentStory = '/monument-story';
  static const String travelItinerary = '/travel-itinerary';
  static const String nearbyHeritage = '/nearby-heritage';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 75);
}
