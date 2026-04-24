import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single message in the chat (from either user or AI)
class MessageModel {
  final String id;
  final String sender; // "user" or "ai"
  final String message;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  /// Convenience getter — true if this message was sent by the user
  bool get isUser => sender == 'user';

  /// Convert to Firestore map for saving
  Map<String, dynamic> toFirestore() {
    return {
      'sender': sender,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Create a MessageModel from a Firestore document
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      sender: data['sender'] ?? 'ai',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
