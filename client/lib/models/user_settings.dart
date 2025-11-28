class UserSettings {
  final int userId;
  final String name;
  final String email;
  final String avatarUrl;

  /// 'cold' | 'normal' | 'warm'
  final String temperatureSensitivity;

  /// 'casual' | 'business' | 'sporty' | 'elegant' ...
  final String stylePreference;

  /// '18-25' | '25-35' | '35-45' | '45+'
  final String ageRange;

  /// ['outerwear', 'upper', 'lower', 'footwear', ...]
  final List<String> preferredCategories;

  final bool notificationsEnabled;
  final bool autoSaveOutfits;

  /// 'celsius' | 'fahrenheit'
  final String temperatureUnit;

  /// 'ru' | 'en'
  final String language;

  const UserSettings({
    required this.userId,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.temperatureSensitivity,
    required this.stylePreference,
    required this.ageRange,
    this.preferredCategories = const <String>[],
    this.notificationsEnabled = false,
    this.autoSaveOutfits = false,
    this.temperatureUnit = 'celsius',
    this.language = 'ru',
  });

  UserSettings copyWith({
    int? userId,
    String? name,
    String? email,
    String? avatarUrl,
    String? temperatureSensitivity,
    String? stylePreference,
    String? ageRange,
    List<String>? preferredCategories,
    bool? notificationsEnabled,
    bool? autoSaveOutfits,
    String? temperatureUnit,
    String? language,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      temperatureSensitivity:
      temperatureSensitivity ?? this.temperatureSensitivity,
      stylePreference: stylePreference ?? this.stylePreference,
      ageRange: ageRange ?? this.ageRange,
      preferredCategories:
      preferredCategories ?? List<String>.from(this.preferredCategories),
      notificationsEnabled:
      notificationsEnabled ?? this.notificationsEnabled,
      autoSaveOutfits: autoSaveOutfits ?? this.autoSaveOutfits,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      language: language ?? this.language,
    );
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    // preferredCategories / preferred_categories могут быть либо List<String>, либо List<dynamic>
    final rawCategories =
        json['preferredCategories'] ?? json['preferred_categories'] ?? const <dynamic>[];
    final categories = (rawCategories as List)
        .map((e) => e.toString())
        .toList();

    return UserSettings(
      userId: (json['userId'] ?? json['user_id']) as int,
      name: (json['name'] ?? json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url'] ?? '') as String,
      temperatureSensitivity:
      (json['temperatureSensitivity'] ?? json['temperature_sensitivity'] ?? 'normal')
      as String,
      stylePreference:
      (json['stylePreference'] ?? json['style_preference'] ?? 'casual')
      as String,
      ageRange:
      (json['ageRange'] ?? json['age_range'] ?? '25-35') as String,
      preferredCategories: categories,
      notificationsEnabled:
      (json['notificationsEnabled'] as bool?) ?? false,
      autoSaveOutfits:
      (json['autoSaveOutfits'] as bool?) ?? false,
      temperatureUnit:
      (json['temperatureUnit'] ?? 'celsius') as String,
      language: (json['language'] ?? 'ru') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'temperatureSensitivity': temperatureSensitivity,
      'stylePreference': stylePreference,
      'ageRange': ageRange,
      'preferredCategories': preferredCategories,
      'notificationsEnabled': notificationsEnabled,
      'autoSaveOutfits': autoSaveOutfits,
      'temperatureUnit': temperatureUnit,
      'language': language,
    };
  }
}