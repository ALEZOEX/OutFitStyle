bool onboardingIncomplete(Map<String, dynamic>? profile) {
  if (profile == null) return true;

  final user = (profile['user'] as Map?)?.cast<String, dynamic>();
  if (user == null) return true;

  // location
  final lat = user['default_latitude'];
  final lon = user['default_longitude'];
  final hasLocation = lat != null && lon != null;

  // preferences
  final prefs = (user['preferences'] as Map?)?.cast<String, dynamic>();
  final preferredStyles = (prefs?['preferred_styles'] as List?)?.map((e) => e.toString()).toList() ?? const [];
  final hasStyles = preferredStyles.isNotEmpty;

  // temp sensitivity (может быть 0 — это ок, поэтому не требуем)
  // colors optional

  return !(hasLocation && hasStyles);
}