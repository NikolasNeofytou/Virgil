/// Row from `public.players`. Lightweight DTO — no codegen yet so we can
/// scaffold without running `build_runner`. We'll convert to `freezed` in A2.
class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.username,
    required this.locale,
    required this.elo,
    required this.xp,
    required this.level,
    required this.gamesPlayed,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String locale; // 'el' | 'en'
  final int elo;
  final int xp;
  final int level;
  final int gamesPlayed;

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      locale: (json['locale'] as String?) ?? 'el',
      elo: (json['elo'] as int?) ?? 1200,
      xp: (json['xp'] as int?) ?? 0,
      level: (json['level'] as int?) ?? 1,
      gamesPlayed: (json['games_played'] as int?) ?? 0,
    );
  }

  PlayerProfile copyWith({
    String? username,
    String? displayName,
    String? avatarUrl,
    String? locale,
  }) {
    return PlayerProfile(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      locale: locale ?? this.locale,
      elo: elo,
      xp: xp,
      level: level,
      gamesPlayed: gamesPlayed,
    );
  }
}
