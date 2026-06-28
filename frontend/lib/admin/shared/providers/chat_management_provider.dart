// lib/admin/shared/providers/chat_management_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_management_repository.dart';
import '../models/chat_session_item.dart';

typedef SessionFilter = ({String search, bool? isFlagged});

final chatSessionsProvider = FutureProvider.autoDispose
    .family<List<ChatSessionItem>, SessionFilter>(
  (ref, filter) async {
    final repo = ref.watch(chatRepositoryProvider);
    return repo.listSessions(
      search: filter.search,
      isFlagged: filter.isFlagged,
    );
  },
);

final chatSessionMessagesProvider = FutureProvider.autoDispose.family<
    ({Map<String, dynamic> session, List<ChatMessageModel> messages}),
    String>(
  (ref, sessionId) async {
    final repo = ref.watch(chatRepositoryProvider);
    return repo.getSessionMessages(sessionId);
  },
);

final unansweredQuestionsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async {
    final repo = ref.watch(chatRepositoryProvider);
    return repo.listUnansweredQuestions();
  },
);
