/// Sealed failure hierarchy used across all layers.
/// Each failure carries a human-readable [message] for display purposes.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// No internet connectivity
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// Server responded with an error or unexpected data
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

/// API returned an empty or unusable hadith list
class EmptyResponseFailure extends Failure {
  const EmptyResponseFailure(
      [super.message = 'No suitable hadith found. Try again later.']);
}

/// Local storage read/write error
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error.']);
}

/// Image generation failed
class ImageFailure extends Failure {
  const ImageFailure([super.message = 'Failed to generate hadith image.']);
}

/// Wallpaper could not be set
class WallpaperFailure extends Failure {
  const WallpaperFailure([super.message = 'Failed to set wallpaper.']);
}

/// Generic / unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
