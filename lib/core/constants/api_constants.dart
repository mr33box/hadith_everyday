/// API-related constants for the Hadith API (https://hadithapi.com)
class ApiConstants {
  ApiConstants._(); // Private constructor — no instantiation

  static const String baseUrl = 'https://hadithapi.com/api';

  /// Endpoint to list hadiths with filters
  static const String hadithsEndpoint = '/hadiths';

  /// Supported book slugs (authentic collections only)
  static const String sahihBukhari = 'sahih-bukhari';
  static const String sahihMuslim = 'sahih-muslim';

  /// List of books to randomly pick from when fetching
  static const List<String> authenticBooks = [
    sahihBukhari,
    sahihMuslim,
  ];

  /// Maximum hadith text length (chars) to use in wallpaper
  /// Hadiths longer than this are skipped to avoid tiny text
  static const int maxHadithLength = 600;

  /// Minimum hadith text length — too short looks odd on wallpaper
  static const int minHadithLength = 40;

  /// Default number of results per API request
  static const int perPage = 20;

  /// How many times to retry a failed API call
  static const int maxRetries = 3;

  /// Timeout for API requests in seconds
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 20;
}
