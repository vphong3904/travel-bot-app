// lib/admin/web/widgets/unanswered_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/chat_management_provider.dart';
import '../../shared/data/chat_management_repository.dart';
import '../../shared/models/auth_user.dart';
import '../../shared/providers/auth_provider.dart';

class UnansweredList extends ConsumerWidget {
  final ValueChanged<String>? onSelect;
  const UnansweredList({super.key, this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(unansweredQuestionsProvider);
    final role = ref.watch(authProvider).user?.role;
    final canPromote =
        role == AdminRole.admin || role == AdminRole.superAdmin;

    return questionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (questions) {
        if (questions.isEmpty) {
          return const Center(
            child: Text(
              'Không có câu hỏi chưa trả lời 🎉',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: questions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final q = questions[i];
            final isPromoted = q['is_promoted'] as bool? ?? false;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q['question'] as String? ?? '',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  if (isPromoted || canPromote)
                    Row(
                      children: [
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: isPromoted
                              ? null
                              : () => _promoteToKb(
                                  context, ref, q['id'] as String),
                          icon: Icon(
                            isPromoted ? Icons.check : Icons.add,
                            size: 14,
                          ),
                          label: Text(
                            isPromoted
                                ? 'Đã thêm vào KB'
                                : '+ Thêm vào KB',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 30),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _promoteToKb(
      BuildContext context, WidgetRef ref, String questionId) async {
    try {
      await ref.read(chatRepositoryProvider).promoteToKb(questionId);
      ref.invalidate(unansweredQuestionsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đã tạo Knowledge Entry draft!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra')),
        );
      }
    }
  }
}
