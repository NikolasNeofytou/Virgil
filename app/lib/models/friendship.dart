/// Row from `public.friendships`. Asymmetric by design: `requester_id`
/// sent the request, `addressee_id` received it. Status transitions:
///
///   pending  → accepted (addressee taps ✓)
///   pending  → (deleted) (addressee declines, requester cancels)
///   accepted → (deleted) (either party unfriends)
///   * → blocked (block flow — not built yet)
class Friendship {
  const Friendship({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String requesterId;
  final String addresseeId;
  final String status; // pending | accepted | blocked
  final DateTime createdAt;

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isBlocked => status == 'blocked';

  /// The player id that isn't me.
  String otherParty(String me) => requesterId == me ? addresseeId : requesterId;

  /// Did *I* send this request (vs receive it)?
  bool iRequested(String me) => requesterId == me;

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      addresseeId: json['addressee_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
