/// One row from the `friends_in_play()` RPC: an accepted friend who's
/// currently sitting at an estimation table (status `waiting` or `active`).
class FriendInPlay {
  const FriendInPlay({
    required this.friendId,
    required this.username,
    required this.gameId,
    required this.roomCode,
    required this.gameStatus,
  });

  final String friendId;
  final String username;
  final String gameId;
  final String roomCode;
  final String gameStatus; // waiting | active

  bool get isWaiting => gameStatus == 'waiting';
  bool get isActive  => gameStatus == 'active';

  factory FriendInPlay.fromJson(Map<String, dynamic> json) => FriendInPlay(
        friendId:   json['friend_id']   as String,
        username:   json['username']    as String,
        gameId:     json['game_id']     as String,
        roomCode:   json['room_code']   as String,
        gameStatus: json['game_status'] as String,
      );
}
