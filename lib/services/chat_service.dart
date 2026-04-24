import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

/// Service for all Firestore database operations.
///
/// Firestore Structure:
/// /chats
///   /chatId
///     language: string
///     createdAt: timestamp
///     /messages
///       /messageId
///         sender: "user" | "ai"
///         message: string
///         timestamp: timestamp
class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Creates a new chat document in Firestore.
  /// Returns the generated chatId.
  Future<String> createChat(String language) async {
    final docRef = await _db.collection('chats').add({
      'language': language,
      'createdAt': Timestamp.now(),
    });
    return docRef.id;
  }

  /// Saves a single message to the messages subcollection of a chat.
  Future<void> saveMessage(MessageModel message, String chatId) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toFirestore());
  }

  /// Returns a real-time stream of messages for a given chatId,
  /// ordered by timestamp ascending.
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }
}
